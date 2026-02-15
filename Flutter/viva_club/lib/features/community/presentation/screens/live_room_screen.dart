import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/emoji_utils.dart';
import 'package:viva_club/features/community/presentation/bloc/room_bloc.dart';
import 'package:viva_club/features/community/data/livekit_room_service.dart';

class LiveRoomScreen extends StatefulWidget {
  final String token;
  final String url;
  final String roomId;
  final String title;
  final bool isHost;

  const LiveRoomScreen({
    super.key,
    required this.token,
    required this.url,
    required this.roomId,
    required this.title,
    this.isHost = false,
  });

  @override
  State<LiveRoomScreen> createState() => _LiveRoomScreenState();
}

class _LiveRoomScreenState extends State<LiveRoomScreen> {
  bool _isLeaving = false; // Guard against multiple leaves

  void _leaveRoom() async {
    if (_isLeaving) return;
    _isLeaving = true;

    try {
      await context.read<LiveKitRoomService>().leave(); // Await leave
    } catch (e) {
      debugPrint('Error leaving room: $e');
    }

    if (mounted) {
      // Safe navigation
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/dashboard');
      }
    }
  }

  // Avatar accent colors for the ring around speakers
  static const List<List<Color>> _avatarColors = [
    [Color(0xFFF3E8FF), Color(0xFF9333EA)],
    [Color(0xFFDBEAFE), Color(0xFF2563EB)],
    [Color(0xFFFEF9C3), Color(0xFFCA8A04)],
    [Color(0xFFFCE7F3), Color(0xFFDB2777)],
    [Color(0xFFDCFCE7), Color(0xFF16A34A)],
    [Color(0xFFFFEDD5), Color(0xFFEA580C)],
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _connect());
  }

  Future<void> _connect() async {
    final service = context.read<LiveKitRoomService>();
    try {
      await service.connect(
        url: widget.url,
        token: widget.token,
        roomId: widget.roomId,
        title: widget.title,
        isHost: widget.isHost,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to connect: $e')));
        context.pop();
      }
    }
  }

  void _toggleMute() {
    final service = context.read<LiveKitRoomService>();
    service.setMicrophoneEnabled(service.isMuted);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LiveKitRoomService>(
      builder: (context, service, child) {
        final participants = service.participants;
        final isMuted = service.isMuted;

        // Speakers = anyone with mic enabled or the local participant if host
        final speakers = participants.where((p) {
          if (p is LocalParticipant) {
            return widget.isHost || p.audioTrackPublications.isNotEmpty;
          }
          return p.audioTrackPublications.isNotEmpty;
        }).toList();

        final listeners = participants
            .where((p) => !speakers.contains(p))
            .toList();

        return Scaffold(
          backgroundColor: AppTheme.background,
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.butteryYellow.withValues(alpha: 0.1),
                  Colors.white,
                  Colors.white,
                ],
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  Column(
                    children: [
                      // Header
                      _buildHeader(participants.length),

                      // Scrollable content
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 140.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSharingSpace(speakers),
                              SizedBox(height: 24.h),
                              _buildListenersSection(listeners),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Bottom floating controls
                  Positioned(
                    bottom: 16.h,
                    left: 0,
                    right: 0,
                    child: _buildBottomControls(isMuted, service),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(int participantCount) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              // Refresh room list
              context.read<RoomBloc>().add(RoomLoad());

              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/dashboard');
              }
            }, // Don't leave, just go back (audio persists)
            child: Icon(
              Icons.arrow_back_ios,
              color: AppTheme.textDark,
              size: 20.sp,
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '$participantCount people here',
                  style: TextStyle(fontSize: 10.sp, color: AppTheme.textGrey),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _leaveRoom,
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFEF2F2),
              ),
              child: Icon(
                Icons.logout,
                size: 20.sp,
                color: const Color(0xFFEF4444),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSharingSpace(List<Participant> speakers) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.auto_awesome, size: 16.sp, color: AppTheme.skyBlue),
            SizedBox(width: 8.w),
            Text(
              'Sharing Space',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: AppTheme.textGrey,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16.w,
            mainAxisSpacing: 20.h,
            childAspectRatio: 0.8,
          ),
          itemCount: speakers.length,
          itemBuilder: (context, index) {
            final p = speakers[index];
            return GestureDetector(
              onTap: () {
                if (widget.isHost && p is! LocalParticipant) {
                  _showSpeakerOptionsDialog(context, p);
                }
              },
              child: _buildParticipantAvatar(p, true, index),
            );
          },
        ),
      ],
    );
  }

  Widget _buildListenersSection(List<Participant> listeners) {
    if (listeners.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Listeners',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: AppTheme.textGrey,
          ),
        ),
        SizedBox(height: 16.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 16.h,
            childAspectRatio: 0.8,
          ),
          itemCount: listeners.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                if (widget.isHost) {
                  _showInviteDialog(context, listeners[index]);
                }
              },
              child: _buildParticipantAvatar(listeners[index], false, index),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBottomControls(bool isMuted, LiveKitRoomService service) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  // Toggle based on current state (read from metadata)
                  final isRaised = service.isHandRaised(
                    service.room!.localParticipant!,
                  );
                  service.toggleHandRaise(!isRaised);
                },
                child: Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color:
                        (service.room?.localParticipant != null &&
                            service.isHandRaised(
                              service.room!.localParticipant!,
                            ))
                        ? AppTheme.butteryYellow
                        : Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text('✋', style: TextStyle(fontSize: 20.sp)),
                ),
              ),
              SizedBox(width: 16.w),
              // Only show Mic toggle if user is a speaker (host or has permissions)
              if (widget.isHost ||
                  (service.room?.localParticipant?.permissions.canPublish ==
                      true))
                GestureDetector(
                  onTap: _toggleMute,
                  child: Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: isMuted ? const Color(0xFFFEF2F2) : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      isMuted ? Icons.mic_off : Icons.mic,
                      color: isMuted
                          ? const Color(0xFFEF4444)
                          : AppTheme.skyBlue,
                      size: 24.sp,
                    ),
                  ),
                ),
            ],
          ),
          GestureDetector(
            onTap: _leaveRoom,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(30.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Text(
                    '✌️ Leave quietly',
                    style: TextStyle(
                      color: const Color(0xFFEF4444),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantAvatar(Participant p, bool isSpeaker, int index) {
    final colors = _avatarColors[index % _avatarColors.length];
    final isLocal = p is LocalParticipant;
    final isSpeaking = p.isSpeaking;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: isSpeaker ? 80.w : 56.w,
          height: isSpeaker ? 80.w : 56.w,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: isSpeaker ? 80.w : 56.w,
                height: isSpeaker ? 80.w : 56.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSpeaker ? colors[0] : Colors.white,
                  border: Border.all(
                    color: isSpeaking
                        ? AppTheme.mintGreen
                        : (isSpeaker
                              ? AppTheme.skyBlue.withValues(alpha: 0.2)
                              : Colors.grey.shade200),
                    width: isSpeaking ? 3 : (isSpeaker ? 2 : 1),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  EmojiUtils.getEmojiForName(p.name),
                  style: TextStyle(fontSize: isSpeaker ? 30.sp : 22.sp),
                ),
              ),
              if (isSpeaker)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF262626),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      isLocal
                          ? Icons.auto_awesome
                          : (p.metadata?.contains('"role": "doctor"') == true ||
                                p.metadata?.contains('"role": "admin"') == true)
                          ? Icons.verified_user
                          : null, // Only show if doctor/admin
                      size: 10.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
              // Hand raise indicator
              if (Provider.of<LiveKitRoomService>(
                context,
                listen: false,
              ).isHandRaised(p))
                Positioned(
                  top: -4,
                  left: -4,
                  child: _buildIndicatorCircle(
                    icon: Icons.front_hand,
                    color: AppTheme.butteryYellow,
                    iconColor: const Color(0xFF854D0E),
                  ),
                ),
              // Mute indicator for speakers
              if (isSpeaker)
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Builder(
                    builder: (context) {
                      final isMuted =
                          p.audioTrackPublications.isEmpty ||
                          p.audioTrackPublications.every((pub) => pub.muted);
                      if (isMuted) {
                        return _buildIndicatorCircle(
                          icon: Icons.mic_off,
                          color: AppTheme.error,
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          EmojiUtils.getNameWithoutTag(p.name),
          style: TextStyle(fontSize: 10.sp, color: AppTheme.textGrey),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildIndicatorCircle({
    required IconData icon,
    required Color color,
    Color iconColor = Colors.white,
  }) {
    return Container(
      width: 24.w,
      height: 24.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 4),
        ],
      ),
      child: Icon(icon, size: 12.sp, color: iconColor),
    );
  }

  void _showInviteDialog(BuildContext context, Participant p) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Manage ${p.name}'),
        content: Text('What would you like to do with ${p.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          if (widget.isHost)
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog first
                _showKickConfirmation(context, p);
              },
              child: const Text('Kick', style: TextStyle(color: Colors.red)),
            ),
          TextButton(
            onPressed: () {
              context.read<LiveKitRoomService>().inviteSpeaker(p.identity);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Invited ${p.name} to speak')),
              );
            },
            child: const Text('Invite to Speak'),
          ),
        ],
      ),
    );
  }

  void _showSpeakerOptionsDialog(BuildContext context, Participant p) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Manage Speaker ${p.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (p.audioTrackPublications.isNotEmpty)
              ...p.audioTrackPublications.map((track) {
                final isMuted = track.muted;
                return ListTile(
                  leading: Icon(isMuted ? Icons.mic_off : Icons.mic),
                  title: Text(isMuted ? 'Unmute' : 'Mute'),
                  onTap: () {
                    context.read<LiveKitRoomService>().muteParticipant(
                      p.identity,
                      track.sid,
                      !isMuted,
                    );
                    Navigator.pop(context);
                  },
                );
              }),
            ListTile(
              leading: const Icon(
                Icons.remove_circle_outline,
                color: Colors.red,
              ),
              title: const Text(
                'Kick from Room',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                _showKickConfirmation(context, p);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showKickConfirmation(BuildContext context, Participant p) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Kick'),
        content: Text('Are you sure you want to kick ${p.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<LiveKitRoomService>().kickParticipant(p.identity);
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Kicked ${p.name}')));
            },
            child: const Text('Kick', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
