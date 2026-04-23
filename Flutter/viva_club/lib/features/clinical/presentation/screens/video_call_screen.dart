import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

class VideoCallScreen extends StatefulWidget {
  final String url;
  final String token;
  final String roomName;

  const VideoCallScreen({
    super.key,
    required this.url,
    required this.token,
    required this.roomName,
  });

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  Room? _room;
  List<Participant> _participants = [];

  @override
  void initState() {
    super.initState();
    _connect();
  }

  Future<void> _connect() async {
    try {
      final room = Room();
      _room = room;
      
      room.addListener(_onRoomUpdate);

      await room.connect(widget.url, widget.token, connectOptions: const ConnectOptions(autoSubscribe: true));
      
      final local = room.localParticipant;
      if (local != null) {
        await local.setCameraEnabled(true);
        await local.setMicrophoneEnabled(true);
      }
      
      _onRoomUpdate();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to connect: $e')),
        );
        context.pop();
      }
    }
  }

  void _onRoomUpdate() {
    final room = _room;
    if (room == null || room.localParticipant == null) return;
    setState(() {
      _participants = [
        room.localParticipant!,
        ...room.remoteParticipants.values,
      ];
    });
  }

  @override
  void dispose() {
    _room?.removeListener(_onRoomUpdate);
    _room?.disconnect();
    _room?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _buildMainVideo(),
          _buildLocalVideo(),
          _buildTopBar(),
          _buildControls(),
        ],
      ),
    );
  }

  Widget _buildMainVideo() {
    final remote = _participants.whereType<RemoteParticipant>().firstOrNull;
    
    if (remote == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16.h),
            Text(
              'Waiting for doctor...',
              style: TextStyle(color: Colors.white70, fontSize: 16.sp),
            ),
          ],
        ),
      );
    }

    final track = remote.videoTrackPublications.firstOrNull?.track;
    if (track == null) return const Center(child: Icon(Icons.videocam_off, color: Colors.white, size: 50));

    return VideoTrackRenderer(track as VideoTrack);
  }

  Widget _buildLocalVideo() {
    final localParticipant = _room?.localParticipant;
    if (localParticipant == null) return const SizedBox.shrink();
    
    final localTrack = localParticipant.videoTrackPublications.firstOrNull?.track;
    
    return Positioned(
      top: 60.h,
      right: 20.w,
      child: Container(
        width: 100.w,
        height: 150.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: localTrack != null 
            ? VideoTrackRenderer(localTrack as VideoTrack)
            : Container(color: Colors.grey[900], child: const Icon(Icons.person, color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 50.h,
      left: 20.w,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.black45,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const Icon(Icons.lock_outline, color: Colors.green, size: 16),
            SizedBox(width: 8.w),
            Text(
              'End-to-End Encrypted',
              style: TextStyle(color: Colors.white, fontSize: 12.sp),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    final local = _room?.localParticipant;
    return Positioned(
      bottom: 40.h,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildIconButton(
            local?.isMicrophoneEnabled() ?? false ? Icons.mic : Icons.mic_off, 
            () {
              if (local != null) local.setMicrophoneEnabled(!(local.isMicrophoneEnabled()));
            }
          ),
          _buildIconButton(
            local?.isCameraEnabled() ?? false ? Icons.videocam : Icons.videocam_off, 
            () {
              if (local != null) local.setCameraEnabled(!(local.isCameraEnabled()));
            }
          ),
          _buildIconButton(Icons.cameraswitch, () {
             if (local != null) local.setCameraEnabled(true);
          }),
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              child: const Icon(Icons.call_end, color: Colors.white, size: 30),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}
