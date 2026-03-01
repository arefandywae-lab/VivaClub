"""
VivaClub Bot Worker — Manages a single bot's LiveKit room connection and audio playback.
"""
import asyncio
import subprocess
import logging
import uuid
import httpx
from livekit import rtc, api as lk_api

logger = logging.getLogger("bot_worker")


class BotWorker:
    """A single bot instance that connects to a LiveKit room."""

    def __init__(self, bot_id: str, name: str, backend_url: str, livekit_url: str,
                 api_key: str, api_secret: str):
        self.bot_id = bot_id
        self.name = name
        self.backend_url = backend_url
        self.livekit_url = livekit_url
        self.api_key = api_key
        self.api_secret = api_secret

        self.room: rtc.Room | None = None
        self.room_id: str | None = None
        self.is_connected = False
        self.is_playing = False
        self.is_muted = True
        self.current_url: str | None = None

        self._audio_source: rtc.AudioSource | None = None
        self._audio_track: rtc.LocalAudioTrack | None = None
        self._play_task: asyncio.Task | None = None
        self._stop_event = asyncio.Event()

    def _generate_token(self, room_name: str, is_host: bool = False) -> str:
        """Generate a LiveKit access token for the bot."""
        grant = lk_api.VideoGrants(
            room_join=True,
            room=room_name,
            can_publish=True,
            can_subscribe=True,
            can_publish_data=True,
            can_update_own_metadata=True,
        )

        token = lk_api.AccessToken(self.api_key, self.api_secret) \
            .with_identity(f"bot_{self.bot_id}") \
            .with_name(f"🤖 {self.name}") \
            .with_grants(grant) \
            .with_metadata('{"role": "bot"}') \
            .to_jwt()

        return token

    async def connect_to_room(self, room_id: str, is_host: bool = False):
        """Connect the bot to a LiveKit room."""
        if self.is_connected:
            await self.disconnect()

        self.room_id = room_id
        self.room = rtc.Room()

        token = self._generate_token(room_id, is_host)

        await self.room.connect(self.livekit_url, token)
        self.is_connected = True
        self.is_muted = True

        logger.info(f"Bot {self.name} connected to room {room_id}")

        # Notify Django backend that bot joined
        try:
            async with httpx.AsyncClient() as client:
                await client.post(
                    f"{self.backend_url}/api/community/rooms/{room_id}/join/",
                    headers={"Content-Type": "application/json"},
                    timeout=5.0,
                )
        except Exception as e:
            logger.warning(f"Failed to notify backend of bot join: {e}")

    async def disconnect(self):
        """Disconnect the bot from the room."""
        await self.stop_audio()

        if self.room:
            try:
                await self.room.disconnect()
            except Exception as e:
                logger.warning(f"Error disconnecting bot: {e}")

        self.room = None
        self.room_id = None
        self.is_connected = False
        self.is_muted = True
        logger.info(f"Bot {self.name} disconnected")

    async def set_muted(self, muted: bool):
        """Mute or unmute the bot's mic."""
        if not self.room or not self.is_connected:
            return

        self.is_muted = muted

        # If we have a published audio track, mute/unmute it
        local = self.room.local_participant
        if local:
            for pub in local.track_publications.values():
                if pub.track and isinstance(pub.track, rtc.LocalAudioTrack):
                    if muted:
                        await local.unpublish_track(pub.sid)
                    break

        logger.info(f"Bot {self.name} {'muted' if muted else 'unmuted'}")

    async def play_audio(self, url: str):
        """Play audio from a YouTube URL (or direct audio URL) into the room."""
        if not self.room or not self.is_connected:
            raise ValueError("Bot is not connected to a room")

        # Stop any existing playback
        await self.stop_audio()

        self.current_url = url
        self.is_playing = True
        self._stop_event.clear()

        # Create audio source (48kHz mono)
        self._audio_source = rtc.AudioSource(48000, 1)
        self._audio_track = rtc.LocalAudioTrack.create_audio_track(
            "bot_audio", self._audio_source
        )

        # Publish the track
        options = rtc.TrackPublishOptions(source=rtc.TrackSource.SOURCE_MICROPHONE)
        await self.room.local_participant.publish_track(self._audio_track, options)
        self.is_muted = False

        # Start streaming audio in background
        self._play_task = asyncio.create_task(self._stream_audio(url))
        logger.info(f"Bot {self.name} started playing: {url}")

    async def stop_audio(self):
        """Stop audio playback."""
        self._stop_event.set()

        if self._play_task and not self._play_task.done():
            self._play_task.cancel()
            try:
                await self._play_task
            except asyncio.CancelledError:
                pass

        self._play_task = None
        self._audio_source = None
        self._audio_track = None
        self.is_playing = False
        self.current_url = None
        logger.info(f"Bot {self.name} stopped playing")

    async def _stream_audio(self, url: str):
        """Extract audio from URL and stream as PCM frames to LiveKit."""
        import numpy as np

        try:
            # Use yt-dlp to get the actual audio stream URL
            audio_url = await self._get_audio_url(url)

            # Use ffmpeg to decode to raw PCM (48kHz, mono, s16le)
            process = await asyncio.create_subprocess_exec(
                "ffmpeg", "-reconnect", "1", "-reconnect_streamed", "1",
                "-reconnect_delay_max", "5",
                "-i", audio_url,
                "-f", "s16le", "-ar", "48000", "-ac", "1",
                "-loglevel", "error",
                "pipe:1",
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE,
            )

            SAMPLES_PER_FRAME = 480  # 10ms at 48kHz
            BYTES_PER_FRAME = SAMPLES_PER_FRAME * 2  # 16-bit = 2 bytes per sample

            while not self._stop_event.is_set():
                data = await process.stdout.read(BYTES_PER_FRAME)
                if not data:
                    break  # End of stream

                # Pad if we got less data than expected
                if len(data) < BYTES_PER_FRAME:
                    data += b'\x00' * (BYTES_PER_FRAME - len(data))

                # Convert bytes to numpy array
                samples = np.frombuffer(data, dtype=np.int16)

                # Create AudioFrame
                frame = rtc.AudioFrame(
                    data=samples.tobytes(),
                    sample_rate=48000,
                    num_channels=1,
                    samples_per_channel=SAMPLES_PER_FRAME,
                )

                await self._audio_source.capture_frame(frame)

                # Small sleep to match real-time (10ms per frame)
                await asyncio.sleep(0.01)

            process.kill()

        except asyncio.CancelledError:
            logger.info(f"Audio stream cancelled for bot {self.name}")
        except Exception as e:
            logger.error(f"Audio streaming error: {e}")
        finally:
            self.is_playing = False

    async def _get_audio_url(self, url: str) -> str:
        """Use yt-dlp to get the best audio stream URL."""
        # If it's already a direct audio URL (e.g., radio stream), return as-is
        if any(url.endswith(ext) for ext in ['.mp3', '.ogg', '.m3u8', '.aac']):
            return url
        if 'radio' in url.lower() or url.startswith('http') and 'youtube' not in url and 'youtu.be' not in url:
            return url

        # Use yt-dlp to extract audio URL
        process = await asyncio.create_subprocess_exec(
            "yt-dlp", "--get-url", "-f", "bestaudio",
            "--no-warnings", url,
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE,
        )
        stdout, stderr = await process.communicate()

        if process.returncode != 0:
            raise ValueError(f"yt-dlp failed: {stderr.decode()}")

        audio_url = stdout.decode().strip().split('\n')[0]
        return audio_url

    def to_dict(self) -> dict:
        """Serialize bot state for API responses."""
        return {
            "bot_id": self.bot_id,
            "name": self.name,
            "room_id": self.room_id,
            "is_connected": self.is_connected,
            "is_playing": self.is_playing,
            "is_muted": self.is_muted,
            "current_url": self.current_url,
        }
