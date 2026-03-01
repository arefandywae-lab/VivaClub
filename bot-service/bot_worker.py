"""
VivaClub Bot Worker — Manages a single bot's LiveKit room connection and audio playback.
Uses yt-dlp piped through ffmpeg for YouTube audio, and LiveKit server API for mute control.
"""
import asyncio
import logging
import os
from livekit import rtc, api as lk_api

logger = logging.getLogger("bot_worker")


class BotWorker:
    """A single bot instance that connects to a LiveKit room."""

    def __init__(self, bot_id: str, name: str, livekit_url: str,
                 api_key: str, api_secret: str):
        self.bot_id = bot_id
        self.name = name
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
        self._publication = None
        self._play_task: asyncio.Task | None = None
        self._ffmpeg_process = None

    def _generate_token(self, room_name: str) -> str:
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

        token = self._generate_token(room_id)
        logger.info(f"Bot {self.name}: connecting to room {room_id}...")

        await self.room.connect(self.livekit_url, token)
        self.is_connected = True
        self.is_muted = True

        logger.info(f"Bot {self.name}: connected to room {room_id} ✓")

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
        self._publication = None
        logger.info(f"Bot {self.name}: disconnected")

    async def set_muted(self, muted: bool):
        """Mute or unmute the bot using LiveKit server-side API."""
        if not self.room_id:
            return

        try:
            # Use server-side RoomService API for mute control
            room_service = lk_api.RoomService(
                self.livekit_url.replace("wss://", "https://").replace("ws://", "http://"),
                self.api_key,
                self.api_secret,
            )

            identity = f"bot_{self.bot_id}"

            if muted and self._publication:
                await room_service.mute_published_track(
                    lk_api.MuteRoomTrackRequest(
                        room=self.room_id,
                        identity=identity,
                        track_sid=self._publication.sid,
                        muted=True,
                    )
                )
            elif not muted and self._publication:
                await room_service.mute_published_track(
                    lk_api.MuteRoomTrackRequest(
                        room=self.room_id,
                        identity=identity,
                        track_sid=self._publication.sid,
                        muted=False,
                    )
                )

            await room_service.aclose()
            self.is_muted = muted
            logger.info(f"Bot {self.name}: {'muted' if muted else 'unmuted'}")

        except Exception as e:
            logger.error(f"Bot {self.name}: mute error: {e}")

    async def play_audio(self, url: str):
        """Play audio from a YouTube URL or direct audio stream."""
        if not self.room or not self.is_connected:
            raise ValueError("Bot is not connected to a room")

        # Stop existing playback
        await self.stop_audio()

        self.current_url = url
        self.is_playing = True

        # Create audio source (48kHz mono)
        self._audio_source = rtc.AudioSource(48000, 1)
        self._audio_track = rtc.LocalAudioTrack.create_audio_track(
            "bot_audio", self._audio_source
        )

        # Publish
        options = rtc.TrackPublishOptions(source=rtc.TrackSource.SOURCE_MICROPHONE)
        self._publication = await self.room.local_participant.publish_track(
            self._audio_track, options
        )
        self.is_muted = False

        logger.info(f"Bot {self.name}: published audio track, starting playback: {url}")

        # Start streaming in background
        self._play_task = asyncio.create_task(self._stream_audio(url))

    async def stop_audio(self):
        """Stop audio playback and clean up."""
        # Kill ffmpeg
        if self._ffmpeg_process:
            try:
                self._ffmpeg_process.kill()
                await self._ffmpeg_process.wait()
            except Exception:
                pass
            self._ffmpeg_process = None

        # Cancel stream task
        if self._play_task and not self._play_task.done():
            self._play_task.cancel()
            try:
                await self._play_task
            except asyncio.CancelledError:
                pass

        # Unpublish track
        if self._publication and self.room and self.room.local_participant:
            try:
                await self.room.local_participant.unpublish_track(self._publication.sid)
            except Exception as e:
                logger.warning(f"Bot {self.name}: unpublish error: {e}")

        self._play_task = None
        self._audio_source = None
        self._audio_track = None
        self._publication = None
        self.is_playing = False
        self.current_url = None
        logger.info(f"Bot {self.name}: playback stopped")

    async def _stream_audio(self, url: str):
        """Stream audio from URL via yt-dlp piped through ffmpeg."""
        import time

        try:
            # Determine if this is a YouTube URL or direct stream
            is_youtube = any(x in url for x in ['youtube.com', 'youtu.be'])

            if is_youtube:
                logger.info(f"Bot {self.name}: extracting YouTube audio...")
                ytdlp_proc = await asyncio.create_subprocess_exec(
                    "yt-dlp", "--get-url", "-f", "bestaudio/best",
                    "--no-warnings", "--no-playlist", url,
                    stdout=asyncio.subprocess.PIPE,
                    stderr=asyncio.subprocess.PIPE,
                )
                stdout, stderr = await ytdlp_proc.communicate()
                if ytdlp_proc.returncode != 0:
                    logger.error(f"Bot {self.name}: yt-dlp failed: {stderr.decode().strip()}")
                    self.is_playing = False
                    return
                audio_url = stdout.decode().strip().split('\n')[0]
                logger.info(f"Bot {self.name}: got audio URL, starting ffmpeg...")
            else:
                audio_url = url

            # FFmpeg → raw PCM (48kHz mono s16le)
            self._ffmpeg_process = await asyncio.create_subprocess_exec(
                "ffmpeg",
                "-reconnect", "1", "-reconnect_streamed", "1",
                "-reconnect_delay_max", "5",
                "-i", audio_url,
                "-f", "s16le", "-ar", "48000", "-ac", "1",
                "-loglevel", "warning", "pipe:1",
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE,
            )

            SAMPLE_RATE = 48000
            SAMPLES_PER_FRAME = 480  # 10ms frames for smoother playback
            BYTES_PER_FRAME = SAMPLES_PER_FRAME * 2  # mono 16-bit
            FRAME_DURATION = SAMPLES_PER_FRAME / SAMPLE_RATE  # 0.01s

            frames_sent = 0
            start_time = time.monotonic()

            while True:
                data = await self._ffmpeg_process.stdout.read(BYTES_PER_FRAME)
                if not data:
                    logger.info(f"Bot {self.name}: stream ended ({frames_sent} frames)")
                    break

                if len(data) < BYTES_PER_FRAME:
                    data += b'\x00' * (BYTES_PER_FRAME - len(data))

                frame = rtc.AudioFrame(
                    data=data,
                    sample_rate=SAMPLE_RATE,
                    num_channels=1,
                    samples_per_channel=SAMPLES_PER_FRAME,
                )

                await self._audio_source.capture_frame(frame)
                frames_sent += 1

                # Monotonic clock pacing — prevents drift/stutter
                target_time = start_time + (frames_sent * FRAME_DURATION)
                sleep_time = target_time - time.monotonic()
                if sleep_time > 0:
                    await asyncio.sleep(sleep_time)

            _, stderr = await self._ffmpeg_process.communicate()
            if stderr:
                logger.warning(f"Bot {self.name}: ffmpeg: {stderr.decode()[:300]}")

        except asyncio.CancelledError:
            logger.info(f"Bot {self.name}: audio cancelled")
        except Exception as e:
            logger.error(f"Bot {self.name}: stream error: {e}", exc_info=True)
        finally:
            self.is_playing = False

    def to_dict(self) -> dict:
        return {
            "bot_id": self.bot_id,
            "name": self.name,
            "room_id": self.room_id,
            "is_connected": self.is_connected,
            "is_playing": self.is_playing,
            "is_muted": self.is_muted,
            "current_url": self.current_url,
        }
