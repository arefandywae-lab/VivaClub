# WebSocket Testing Guide

You can test the Real-time Chat & Presence features using **Postman** (New WebSocket Request) or a simple browser console.

## Connection Details
- **URL**: `ws://localhost:8000/ws/chat/{ROOM_ID}/`
- **Auth**: Currently, the consumer checks `self.scope["user"]`. In a browser session (with session cookie), it works automatically. For external tools, you might need to pass headers or use a token-based AuthMiddleware (not yet fully configured for JWT in WS, defaulting to Session).

## Test Steps (Browser Console)

1. **Login** via the Admin panel (`http://localhost:8000/admin/`) to set the Session Cookie.
2. Open the **Developer Console** (F12).
3. Run the following JavaScript to connect:

```javascript
// Connect to Room "room1"
const chatSocket = new WebSocket('ws://localhost:8000/ws/chat/room1/');

chatSocket.onopen = function(e) {
    console.log("✅ Custom: Chat socket connected!");
    // Send a message
    chatSocket.send(JSON.stringify({
        'message': 'Hello World from Console!'
    }));
};

chatSocket.onmessage = function(e) {
    const data = JSON.parse(e.data);
    console.log("📩 Received:", data);
};

chatSocket.onclose = function(e) {
    console.error('❌ Chat socket closed unexpectedly');
};
```

4. You should see "✅ Connected" and then receive your own message back.
5. Check the **Database** or Admin Panel -> **Users**: The `is_online` flag should be `True`.
6. Close the tab -> `is_online` should become `False` (after socket disconnect).

## Test Steps (Postman)
1. Create a new **WebSocket Request**.
2. URL: `ws://localhost:8000/ws/chat/room1/`
3. Headers:
    - `Cookie`: `sessionid=YOUR_SESSION_ID_FROM_BROWSER` (Required since we use Session Auth for now)
    - `Origin`: `http://localhost:8000`
4. Connect.
5. Send Message:
   ```json
   {
       "message": "Hello via Postman"
   }
   ```
