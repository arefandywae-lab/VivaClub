# 04: Challenges and Solutions

Building a complex, real-time platform in a short period presented several technical hurdles. Below are the key challenges and how they were resolved.

## 1. Challenge: Redis Tuple Errors in Django Channels
**Problem:** Real-time chat messages were failing to send, with the server throwing "Redis response is not a tuple" errors.
**Cause:** A version mismatch and incorrect configuration in the Django `CHANNEL_LAYERS` setting.
**Solution:** Reconfigured the Redis host URL to include explicit credentials and updated the `channels-redis` package to ensure compatibility with the production Redis instance.

## 2. Challenge: Audio Stuttering in Bot Interactions
**Problem:** The community bots (for music or guidance) had choppy audio playback.
**Cause:** Standard Python loops were not consistent enough for the 10ms-20ms timing required by WebRTC audio packets.
**Solution:** Implemented a high-precision pacing mechanism using `time.monotonic()` to ensure packets are dispatched exactly every 10ms, eliminating jitter and stutter.

## 3. Challenge: 401/403 Errors on Admin Dashboard
**Problem:** Newly promoted administrators were being locked out of the Next.js dashboard in the production environment.
**Cause:** Backend permission caching and missing "is_staff" flags for specific admin roles.
**Solution:** Implemented a robust session verification middleware in Next.js and a manual "Promotion" script in the Django admin to ensure all credentials synchronize correctly across the distributed system.

## 4. Challenge: Mobile Network "Blackholes" (AIS/True/dtac)
**Problem:** Users on certain Thai mobile networks could join rooms but hear no audio.
**Cause:** Path MTU (Maximum Transmission Unit) issues where large UDP packets were being dropped by the carrier.
**Solution:** 
1. Forced the usage of **TURN over TCP** (Port 443) for problematic networks.
2. Implemented ICMPv6 "Packet Too Big" handling in the Caddy proxy to help the network negotiate smaller packet sizes.

## 5. Challenge: SOS Real-time Synchronization
**Problem:** Patients were waiting indefinitely on the SOS screen even after a doctor accepted the call.
**Cause:** The patient app only knew the call was "Waiting" and didn't have a listener for the "Ongoing" state.
**Solution:** Enhanced the `my_position` API to return room tokens and status. Updated the Flutter app to poll this endpoint every 5 seconds, triggering an automatic navigation to the video call screen as soon as the status changes to "Ongoing".
