"""
VivaClub Bot Service — FastAPI app for controlling LiveKit room bots.
Runs as a separate Docker container on port 9090.
"""
import os
import uuid
import logging
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional
from bot_worker import BotWorker

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("bot_service")

app = FastAPI(title="VivaClub Bot Service", version="1.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Config from environment
BACKEND_URL = os.environ.get("BACKEND_URL", "https://vivaclubs.site")
LIVEKIT_URL = os.environ.get("LIVEKIT_URL", "wss://livekit.vivaclubs.site")
LIVEKIT_API_KEY = os.environ.get("LIVEKIT_API_KEY", "")
LIVEKIT_API_SECRET = os.environ.get("LIVEKIT_API_SECRET", "")

# In-memory bot registry
bots: dict[str, BotWorker] = {}

# --- Request Models ---

class SpawnBotRequest(BaseModel):
    name: Optional[str] = None
    room_id: str
    is_host: bool = False

class PlayAudioRequest(BaseModel):
    url: str

class CreateRoomRequest(BaseModel):
    name: Optional[str] = None
    title: str
    category: str = "general"
    description: str = ""

# --- Endpoints ---

@app.get("/health")
async def health():
    return {"status": "ok", "active_bots": len(bots)}


@app.get("/bots")
async def list_bots():
    """List all active bots."""
    return {"bots": [bot.to_dict() for bot in bots.values()]}


@app.post("/bots/spawn")
async def spawn_bot(req: SpawnBotRequest):
    """Spawn a new bot and connect it to a room."""
    if not LIVEKIT_API_KEY or not LIVEKIT_API_SECRET:
        raise HTTPException(500, "LiveKit credentials not configured")

    bot_id = str(uuid.uuid4())[:8]
    name = req.name or f"Bot #{len(bots) + 1}"

    bot = BotWorker(
        bot_id=bot_id,
        name=name,
        livekit_url=LIVEKIT_URL,
        api_key=LIVEKIT_API_KEY,
        api_secret=LIVEKIT_API_SECRET,
    )

    try:
        await bot.connect_to_room(req.room_id, req.is_host)
    except Exception as e:
        raise HTTPException(500, f"Failed to connect bot: {str(e)}")

    bots[bot_id] = bot
    return {"message": f"Bot '{name}' spawned", "bot": bot.to_dict()}


@app.post("/bots/{bot_id}/play")
async def play_audio(bot_id: str, req: PlayAudioRequest):
    """Start playing audio from a URL (YouTube, radio, direct)."""
    bot = bots.get(bot_id)
    if not bot:
        raise HTTPException(404, "Bot not found")
    if not bot.is_connected:
        raise HTTPException(400, "Bot is not connected to a room")

    try:
        await bot.play_audio(req.url)
    except Exception as e:
        raise HTTPException(500, f"Failed to play audio: {str(e)}")

    return {"message": f"Playing audio", "bot": bot.to_dict()}


@app.post("/bots/{bot_id}/stop")
async def stop_audio(bot_id: str):
    """Stop audio playback."""
    bot = bots.get(bot_id)
    if not bot:
        raise HTTPException(404, "Bot not found")

    await bot.stop_audio()
    return {"message": "Playback stopped", "bot": bot.to_dict()}


@app.post("/bots/{bot_id}/mute")
async def mute_bot(bot_id: str):
    """Mute the bot."""
    bot = bots.get(bot_id)
    if not bot:
        raise HTTPException(404, "Bot not found")

    await bot.set_muted(True)
    return {"message": "Bot muted", "bot": bot.to_dict()}


@app.post("/bots/{bot_id}/unmute")
async def unmute_bot(bot_id: str):
    """Unmute the bot."""
    bot = bots.get(bot_id)
    if not bot:
        raise HTTPException(404, "Bot not found")

    await bot.set_muted(False)
    return {"message": "Bot unmuted", "bot": bot.to_dict()}


@app.post("/bots/{bot_id}/leave")
async def leave_room(bot_id: str):
    """Disconnect bot from the room but keep it in registry."""
    bot = bots.get(bot_id)
    if not bot:
        raise HTTPException(404, "Bot not found")

    await bot.disconnect()
    return {"message": "Bot left room", "bot": bot.to_dict()}


@app.delete("/bots/{bot_id}")
async def kill_bot(bot_id: str):
    """Kill and remove a bot completely."""
    bot = bots.pop(bot_id, None)
    if not bot:
        raise HTTPException(404, "Bot not found")

    await bot.disconnect()
    return {"message": f"Bot '{bot.name}' killed"}


@app.post("/bots/create-room")
async def create_room_with_bot(req: CreateRoomRequest):
    """Create a new room via Django API and spawn a bot as host."""
    if not LIVEKIT_API_KEY or not LIVEKIT_API_SECRET:
        raise HTTPException(500, "LiveKit credentials not configured")

    # Create room via Django backend using admin credentials
    import httpx
    try:
        async with httpx.AsyncClient() as client:
            # Login as admin to get token
            login_resp = await client.post(
                f"{BACKEND_URL}/api/auth/login/",
                json={"username": os.environ.get("ADMIN_USERNAME", "admin"),
                      "password": os.environ.get("ADMIN_PASSWORD", "")},
                timeout=10.0,
            )
            if login_resp.status_code != 200:
                raise HTTPException(500, "Failed to login as admin")

            admin_token = login_resp.json()["access"]

            # Create room
            create_resp = await client.post(
                f"{BACKEND_URL}/api/community/rooms/",
                json={"title": req.title, "category": req.category, "description": req.description},
                headers={"Authorization": f"Bearer {admin_token}"},
                timeout=10.0,
            )
            if create_resp.status_code not in (200, 201):
                raise HTTPException(500, f"Failed to create room: {create_resp.text}")

            room_data = create_resp.json()
            room_id = room_data["id"]

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(500, f"Failed to create room: {str(e)}")

    # Spawn bot as host
    bot_id = str(uuid.uuid4())[:8]
    name = req.name or f"Bot Host #{len(bots) + 1}"

    bot = BotWorker(
        bot_id=bot_id,
        name=name,
        livekit_url=LIVEKIT_URL,
        api_key=LIVEKIT_API_KEY,
        api_secret=LIVEKIT_API_SECRET,
    )

    try:
        await bot.connect_to_room(room_id, is_host=True)
    except Exception as e:
        raise HTTPException(500, f"Failed to connect bot to room: {str(e)}")

    bots[bot_id] = bot
    return {
        "message": f"Room '{req.title}' created with bot host",
        "room": room_data,
        "bot": bot.to_dict(),
    }
