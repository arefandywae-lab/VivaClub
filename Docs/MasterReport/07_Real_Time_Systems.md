# บทที่ 7: ระบบเรียลไทม์
# Chapter 7: Real-Time Systems

---

## สารบัญบท / Chapter Contents

7.1 ภาพรวมระบบเรียลไทม์  
7.2 LiveKit WebRTC Integration  
7.3 Django Channels & WebSocket  
7.4 Chat WebSocket  
7.5 Bot Audio Service — Timing-Sensitive System  
7.6 TURN Server และปัญหา Thai Carriers

---

## 7.1 ภาพรวมระบบเรียลไทม์

VivaClub มี **2 ระบบเรียลไทม์** ที่ทำงานแยกกันตามวัตถุประสงค์:

| ระบบ | Technology | วัตถุประสงค์ | Latency Target |
|------|-----------|------------|---------------|
| **LiveKit WebRTC** | LiveKit SFU + livekit_client | Audio/Video streaming | < 100ms |
| **Django Channels** | Channels + Redis + Daphne | Application events (notifications, chat) | < 500ms |

**ทำไมต้องแยก 2 ระบบ:**
- WebRTC ออกแบบมาสำหรับ real-time media — มี adaptive bitrate, packet loss concealment, echo cancellation
- WebSocket (Channels) เหมาะกับ application-level events ที่ไม่ต้องการ ultra-low latency
- การรวมกันจะทำให้ LiveKit ต้อง handle application logic ที่ไม่ใช่ media — ผิดวัตถุประสงค์

---

## 7.2 LiveKit WebRTC Integration

### LiveKit คืออะไร

LiveKit เป็น **SFU (Selective Forwarding Unit)** — server กลางที่รับ audio/video stream จาก participant หนึ่ง แล้ว forward ไปยัง participants อื่นๆ โดยไม่ mix/encode ใหม่ (ต่างจาก MCU — Multipoint Control Unit)

**ข้อดีของ SFU:**
- Server CPU ต่ำกว่า (ไม่ต้อง transcode)
- ปรับ bitrate แต่ละ participant ได้อิสระ
- Scale ได้ดีกว่าเมื่อมีห้องใหญ่

### การสร้าง LiveKit JWT Token (Server Side)

เมื่อ user ขอเข้าห้อง Django จะสร้าง JWT token ให้ LiveKit:

```python
# apps/utils/livekit_utils.py
from livekit.api import AccessToken, VideoGrants

def generate_livekit_token(room_name: str, identity: str, metadata: dict) -> str:
    token = AccessToken(
        api_key=settings.LIVEKIT_API_KEY,
        api_secret=settings.LIVEKIT_API_SECRET
    )
    token.identity = identity  # ghost_id ของ user
    token.name = metadata.get("display_name", "Unknown")
    token.metadata = json.dumps(metadata)
    
    grants = VideoGrants(
        room_join=True,
        room=room_name,
        can_publish=metadata.get("can_publish", False),  # speaker only
        can_subscribe=True,
        can_publish_data=True,
    )
    token.add_grants(grants)
    
    return token.to_jwt()
```

**Metadata ที่ฝังใน token:**
```json
{
  "ghost_id": "uuid-of-ghost-profile",
  "display_name": "Happy Panda #42",
  "role": "host|speaker|listener",
  "is_host": true,
  "handRaised": false
}
```

**ทำไม ghost_id อยู่ใน metadata:**
- Flutter ใน live room ต้องรู้ ghost_id ของ participant อื่น เพื่อ Follow/Report
- LiveKit ไม่รู้จัก concept "ghost profile" — ต้องฝัง custom data ผ่าน metadata
- เมื่อ Flutter รับ `ParticipantMetadataChangedEvent` สามารถ extract ghost_id และเรียก Follow API ได้

---

### Room Control via LiveKit API (Twirp)

Django ควบคุม room ผ่าน LiveKit REST API:

```python
# ตัวอย่าง: Invite speaker (เปลี่ยน listener เป็น speaker)
from livekit.api import LiveKitAPI, UpdateParticipantRequest, ParticipantPermission

async def invite_speaker(room_name: str, identity: str):
    async with LiveKitAPI(
        url=settings.LIVEKIT_API_URL,
        api_key=settings.LIVEKIT_API_KEY,
        api_secret=settings.LIVEKIT_API_SECRET
    ) as api:
        request = UpdateParticipantRequest(
            room=room_name,
            identity=identity,
            permission=ParticipantPermission(
                can_publish=True,
                can_subscribe=True,
            ),
            metadata=json.dumps({"role": "speaker", "handRaised": False})
        )
        await api.room.update_participant(request)
```

**Operations ที่ Django ทำผ่าน LiveKit API:**

| Operation | LiveKit API Call | ใช้เมื่อ |
|-----------|-----------------|---------|
| Invite to speak | `UpdateParticipant(can_publish=True)` | Host drag-invite listener |
| Demote speaker | `UpdateParticipant(can_publish=False)` | Host removes speaker |
| Mute participant | `MutePublishedTrack(muted=True)` | Force mute by host |
| Kick participant | `RemoveParticipant(identity)` | Host/Moderator kick |
| Update metadata | `UpdateParticipant(metadata=...)` | Role change, hand raise update |

---

### LiveKit Webhook (LiveKit → Django)

LiveKit ส่ง webhook events มาที่ Django เมื่อ room state เปลี่ยน:

```
POST /api/community/webhook/livekit/
Content-Type: application/webhook+json
Authorization: <LiveKit-signed JWT>
```

**Events ที่ handle:**

| Event | Django Action |
|-------|--------------|
| `participant_joined` | `room.participant_count += 1`, update `peak_listeners` |
| `participant_left` | `room.participant_count -= 1` |
| `room_started` | Mark room `is_active = True` |
| `room_finished` | Mark room `is_active = False`, cleanup |

**ทำไม webhook เป็น single source of truth:**

ก่อนหน้านี้ code เพิ่ม `participant_count` ทั้งใน join API endpoint และใน webhook — ทำให้ count เป็น 2 เท่า (bug) หลัง fix: **webhook เท่านั้นที่อัปเดต count** — join/leave API endpoints ไม่แตะ participant_count อีกต่อไป

---

### Flutter LiveKit Integration

```dart
// Flutter: LiveKitRoomService (ChangeNotifier)
class LiveKitRoomService extends ChangeNotifier {
  Room? _room;
  
  Future<void> connect(String url, String token) async {
    _room = await LiveKitClient.connect(
      url,
      token,
      roomOptions: const RoomOptions(
        adaptiveStream: true,     // Auto bitrate adjustment
        dynacast: true,           // Disable unused tracks
        defaultVideoPublishOptions: VideoPublishOptions(
          simulcast: true,
        ),
      ),
    );
    
    // Listen to participant events
    _room!.addListener(_onRoomUpdate);
    _room!.events.on<RoomDisconnectedEvent>(_handleDisconnect);
    _room!.events.on<ParticipantMetadataChangedEvent>(_handleMetadataChange);
    _room!.events.on<TrackMutedEvent>(_handleTrackMuted);
  }
  
  void _handleDisconnect(RoomDisconnectedEvent event) {
    // Check if kicked (wasKicked flag in disconnect reason)
    if (event.reason == DisconnectReason.PARTICIPANT_REMOVED) {
      _wasKicked = true;
    }
    notifyListeners();
  }
  
  void _handleMetadataChange(ParticipantMetadataChangedEvent event) {
    // Extract role changes from metadata JSON
    final metadata = jsonDecode(event.participant.metadata ?? '{}');
    if (metadata['role'] == 'speaker') {
      _promotedToSpeaker(event.participant.identity);
    }
    notifyListeners();
  }
}
```

**ทำไม LiveKitRoomService เป็น Singleton ที่ Root level:**

ถ้า Service อยู่ใน widget tree ปกติ มันจะถูก dispose เมื่อ navigate ออกจาก screen — audio จะหยุดทันที การ inject ที่ root MultiProvider ทำให้ audio เล่นต่อได้แม้ navigate ไปหน้าอื่น (เช่น เปิด profile ขณะอยู่ในห้อง)

---

## 7.3 Django Channels & WebSocket

### การ Setup

```python
# config/asgi.py
from channels.routing import ProtocolTypeRouter, URLRouter
from apps.community.middleware import JWTAuthMiddleware

application = ProtocolTypeRouter({
    "http": get_asgi_application(),
    "websocket": JWTAuthMiddleware(
        URLRouter([
            path("ws/chat/<str:room_id>/", ChatConsumer.as_asgi()),
            path("ws/notifications/", NotificationConsumer.as_asgi()),
            path("ws/admin/dashboard/", AdminDashboardConsumer.as_asgi()),
        ])
    ),
})
```

### Channel Layer Configuration

```python
# config/settings.py
CHANNEL_LAYERS = {
    "default": {
        "BACKEND": "channels_redis.core.RedisChannelLayer",
        "CONFIG": {
            "hosts": [env('REDIS_URL', default='redis://localhost:6379/0')],
            # ⚠️ URL string format — ไม่ใช่ tuple format
            # Bug: ('localhost', 6379) ทำให้เกิด tuple decode error ใน channels_redis 4.x
        },
    }
}
```

### JWT Authentication สำหรับ WebSocket

WebSocket ไม่สามารถส่ง `Authorization: Bearer <token>` header ได้ (browser/Flutter limitation) จึงใช้ query parameter:

```
wss://vivaclubs.site/ws/notifications/?token=<jwt_access_token>
```

```python
# apps/community/middleware.py
class JWTAuthMiddleware(BaseMiddleware):
    async def __call__(self, scope, receive, send):
        # Extract token from query string
        query_string = scope.get("query_string", b"").decode()
        params = dict(x.split("=") for x in query_string.split("&") if "=" in x)
        token = params.get("token", "")
        
        try:
            validated_token = JWTAuthentication().get_validated_token(token)
            user = await JWTAuthentication().get_user(validated_token)
            scope["user"] = user
        except (InvalidToken, TokenError):
            scope["user"] = AnonymousUser()
        
        return await super().__call__(scope, receive, send)
```

### Notification Consumer

```python
# apps/community/consumers.py
class NotificationConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        self.user = self.scope["user"]
        if not self.user.is_authenticated:
            await self.close()
            return
        
        # Join personal channel group
        self.group_name = f"user_{self.user.id}"
        await self.channel_layer.group_add(self.group_name, self.channel_name)
        await self.accept()
    
    async def disconnect(self, close_code):
        await self.channel_layer.group_discard(self.group_name, self.channel_name)
    
    async def notification_message(self, event):
        """Called when Django sends message to this group"""
        await self.send(text_data=json.dumps(event["data"]))
```

**วิธีส่ง notification จาก View:**
```python
# ใน Django view หรือ service
from channels.layers import get_channel_layer
from asgiref.sync import async_to_sync

channel_layer = get_channel_layer()
async_to_sync(channel_layer.group_send)(
    f"user_{user.id}",
    {
        "type": "notification.message",
        "data": {
            "type": "ghost_room_opened",
            "title": f"{ghost.display_name} opened a room",
            "room_id": str(room.id),
        }
    }
)
```

---

## 7.4 Chat WebSocket

### Chat Consumer

```python
# apps/chat/consumers.py
class ChatConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        self.room_id = self.scope["url_route"]["kwargs"]["room_id"]
        self.user = self.scope["user"]
        
        # Verify user has access to this room
        if not self._can_access_room():
            await self.close()
            return
        
        self.group_name = f"chat_{self.room_id}"
        await self.channel_layer.group_add(self.group_name, self.channel_name)
        await self.accept()
    
    async def receive(self, text_data):
        data = json.loads(text_data)
        content = data.get("message", "")
        
        # Save to database
        message = await Message.objects.acreate(
            sender=self.user,
            room_id=self.room_id,
            content=content,
        )
        
        # Broadcast to room group
        await self.channel_layer.group_send(
            self.group_name,
            {
                "type": "chat.message",
                "message_id": str(message.id),
                "sender_id": str(self.user.id),
                "content": content,
                "created_at": message.created_at.isoformat(),
            }
        )
        
        # Send push notification to offline users
        await self._notify_offline_users(content)
    
    async def chat_message(self, event):
        """Broadcast received message to WebSocket client"""
        await self.send(text_data=json.dumps(event))
    
    def _can_access_room(self) -> bool:
        # For DM rooms: room_id = "dm_uuid1_uuid2"
        # User must be one of the two UUIDs
        if self.room_id.startswith("dm_"):
            parts = self.room_id.split("_")
            user_ids = parts[1:]  # [uuid1, uuid2]
            return str(self.user.id) in user_ids
        return True  # Clubhouse rooms — open access
```

### room_id Pattern

```
DM ระหว่าง user A กับ B:
  room_id = "dm_" + sorted([user_a_id, user_b_id]).join("_")
  เช่น: "dm_12345678-aaaa-..._87654321-bbbb-..."

Clubhouse room:
  room_id = "room_" + room.id
  เช่น: "room_abcdef01-..."

(อนาคต) Appointment room:
  room_id = "appointment_" + appointment.id
```

UUID ถูก sort ก่อน concat เพื่อให้ room_id เป็น deterministic — ไม่ว่า A จะ DM B หรือ B จะ DM A จะได้ room_id เดียวกันเสมอ

---

## 7.5 Bot Audio Service — Timing-Sensitive System

### ปัญหาเดิม: asyncio.sleep drift

Bot service ส่ง audio frame ทุก 10ms (มาตรฐาน WebRTC: 480 samples ที่ 48kHz):

```python
# ❌ ปัญหาเดิม — drift สะสม
FRAME_DURATION = 0.010  # 10ms

while is_playing:
    frame = generate_audio_frame()
    await track.capture_frame(frame)
    await asyncio.sleep(FRAME_DURATION)  # sleep ไม่แม่นยำ!
```

`asyncio.sleep(0.010)` ไม่ได้ sleep แน่นอน 10ms — Python event loop จะ sleep นาน**กว่า**เล็กน้อยทุกครั้ง (12ms, 11ms, 13ms...) หลัง 1 นาที drift สะสมเป็น 2-5 วินาที → audio ฟัง ดังๆ หายๆ

### วิธีแก้: time.monotonic() Pacing

```python
# ✅ วิธีแก้ — monotonic clock pacing
import time

FRAME_DURATION = 0.010  # 10ms target

async def stream_audio(track, audio_data):
    frame_index = 0
    start_time = time.monotonic()
    
    while frame_index < total_frames:
        frame = audio_data[frame_index]
        await track.capture_frame(frame)
        frame_index += 1
        
        # คำนวณเวลาที่ควรส่ง frame ถัดไป
        next_send_time = start_time + (frame_index * FRAME_DURATION)
        sleep_duration = next_send_time - time.monotonic()
        
        if sleep_duration > 0:
            await asyncio.sleep(sleep_duration)
        # ถ้า sleep_duration < 0 (เราช้ากว่ากำหนด) → ส่งทันทีไม่ sleep
```

**ทำไม time.monotonic() ดีกว่า time.time():**
- `time.monotonic()` ไม่ได้รับผลจาก NTP sync หรือ system clock adjustments
- ค่าเพิ่มขึ้นอย่างสม่ำเสมอเสมอ (ไม่มี negative jump)
- เหมาะสำหรับ measuring elapsed time

**ผลลัพธ์:** Audio smooth ไม่มี gap ทุกๆ 1 นาทีอีกต่อไป Drift < 1ms per hour

---

## 7.6 TURN Server และปัญหา Thai Carriers

### WebRTC NAT Traversal

WebRTC ต้องการ ICE (Interactive Connectivity Establishment) เพื่อสร้าง peer connection ผ่าน NAT:

1. **STUN**: ค้นหา public IP:port ของ client
2. **TURN**: relay server สำหรับกรณี STUN ล้มเหลว

### ปัญหา: Path MTU Blackhole บน Thai Networks

บน network ของ AIS, True, DTAC — **large UDP packets ถูก drop** โดยไม่มีการแจ้งเตือน (ไม่ส่ง ICMP "Packet Too Big" กลับ) ทำให้:
- WebRTC media (UDP) ไม่สามารถ establish ได้
- User เห็น "เชื่อมต่อสำเร็จ" แต่ไม่ได้ยินเสียง

### วิธีแก้: TURN over TCP Port 443

```yaml
# livekit.yaml
rtc:
  tcp_port: 7882
  udp_port: 7882
  use_external_ip: true
  
turn:
  enabled: true
  domain: livekit.vivaclubs.site
  tls_port: 443   # ← TURN over TCP on port 443
  credential: <secret>
```

```
# Caddyfile — ส่ง TCP :443 ไปยัง LiveKit TURN
livekit.vivaclubs.site {
    reverse_proxy /rtc/* livekit:7880
    
    # TURN over TCP
    @turn path /turn/*
    handle @turn {
        reverse_proxy livekit:443
    }
}
```

**ทำไม TCP port 443:**
- TCP fragment packet อัตโนมัติ — ไม่มีปัญหา MTU
- Port 443 (HTTPS) ไม่ถูก block โดย corporate firewalls หรือ carrier firewalls
- LiveKit client จะ fallback มา TURN เมื่อ UDP ล้มเหลว

**ผลลัพธ์:** Audio ทำงานปกติบน AIS, True, DTAC หลัง fix

### ICE Candidate Order

Flutter LiveKit SDK ลอง ICE candidates ตามลำดับ:
1. Host candidates (local IP) — เร็วที่สุด, ใช้บน WiFi LAN
2. STUN candidates (public IP via UDP) — ใช้บน 4G ทั่วไป
3. TURN/TCP candidates — fallback สำหรับ Thai carriers

Timeout แต่ละ candidate type: 5 วินาที → ถ้า UDP fail จะ fallback ไป TCP ใน 10-15 วินาที
