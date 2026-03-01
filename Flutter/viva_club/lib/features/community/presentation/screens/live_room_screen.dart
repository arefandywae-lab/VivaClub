import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/emoji_utils.dart';
import 'package:viva_club/features/community/presentation/bloc/room_bloc.dart';
import 'package:viva_club/features/community/data/livekit_room_service.dart';
import 'package:viva_club/features/community/data/community_repository.dart';

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
  bool _isLeaving = false;
  bool _isDragging = false; // Show zone borders when dragging

  // Avatar accent colors
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

  void _shareRoomLink() {
    final deepLink = 'https://vivaclub.app/rooms/${widget.roomId}';
    try {
      Share.share(
        '💬 Join me in "${widget.title}" on VivaClub — a safe space to talk! $deepLink',
        subject: 'Join my VivaClub room',
      );
    } catch (e) {
      debugPrint('Share failed: $e');
    }
  }

  void _leaveRoom() async {
    if (_isLeaving) return;
    _isLeaving = true;
    try {
      await context.read<LiveKitRoomService>().leave();
    } catch (e) {
      debugPrint('Error leaving room: $e');
    }
    if (mounted) {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/dashboard');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LiveKitRoomService>(
      builder: (context, service, child) {
        final participants = service.participants;
        final isMuted = service.isMuted;

        // Speakers = anyone with audio published or local participant if host
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
                      _buildHeader(participants.length),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 140.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // === SPEAKER ZONE (DragTarget) ===
                              _buildSpeakerZone(speakers, service),
                              SizedBox(height: 24.h),
                              // === LISTENER ZONE (DragTarget) ===
                              _buildListenerZone(listeners, service),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Bottom controls
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

  // ─── HEADER ───────────────────────────
  Widget _buildHeader(int participantCount) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              context.read<RoomBloc>().add(RoomLoad());
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/dashboard');
              }
            },
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
            onTap: _shareRoomLink,
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFEEF2FF),
              ),
              child: Icon(
                Icons.share_rounded,
                size: 20.sp,
                color: AppTheme.primary,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: _leaveRoom,
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFEF2F2),
              ),
              child: Icon(Icons.logout, size: 20.sp, color: Color(0xFFEF4444)),
            ),
          ),
        ],
      ),
    );
  }

  // ─── SPEAKER ZONE ─────────────────────
  Widget _buildSpeakerZone(
    List<Participant> speakers,
    LiveKitRoomService service,
  ) {
    Widget content = Column(
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
            final avatar = _buildParticipantAvatar(p, true, index);

            // Host can drag speakers back to listener zone
            if (widget.isHost && p is! LocalParticipant) {
              return LongPressDraggable<Participant>(
                data: p,
                onDragStarted: () => setState(() => _isDragging = true),
                onDragEnd: (_) => setState(() => _isDragging = false),
                onDraggableCanceled: (_, __) =>
                    setState(() => _isDragging = false),
                feedback: Material(
                  color: Colors.transparent,
                  child: SizedBox(
                    width: 80.w,
                    child: Opacity(opacity: 0.85, child: avatar),
                  ),
                ),
                childWhenDragging: Opacity(opacity: 0.3, child: avatar),
                child: GestureDetector(
                  onTap: () => _showProfileCard(context, p, service),
                  child: avatar,
                ),
              );
            }

            return GestureDetector(
              onTap: () => _showProfileCard(context, p, service),
              child: avatar,
            );
          },
        ),
        if (speakers.isEmpty)
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 32.h),
              child: Text(
                'No speakers yet',
                style: TextStyle(fontSize: 12.sp, color: AppTheme.textGrey),
              ),
            ),
          ),
      ],
    );

    // Wrap in DragTarget — host can drop listeners here to invite
    if (widget.isHost) {
      return DragTarget<Participant>(
        onWillAcceptWithDetails: (details) {
          // Accept only listeners (not already speakers)
          return !speakers.contains(details.data);
        },
        onAcceptWithDetails: (details) {
          final p = details.data;
          // Invite listener to speak
          service.inviteSpeaker(p.identity);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Invited ${p.name} to speak')));
        },
        builder: (context, candidateData, rejectedData) {
          final isHovering = candidateData.isNotEmpty;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              border: _isDragging
                  ? Border.all(
                      color: isHovering
                          ? AppTheme.skyBlue
                          : AppTheme.skyBlue.withValues(alpha: 0.3),
                      width: isHovering ? 2.5 : 1.5,
                      strokeAlign: BorderSide.strokeAlignOutside,
                    )
                  : null,
              color: isHovering
                  ? AppTheme.skyBlue.withValues(alpha: 0.05)
                  : Colors.transparent,
            ),
            child: content,
          );
        },
      );
    }
    return content;
  }

  // ─── LISTENER ZONE ────────────────────
  Widget _buildListenerZone(
    List<Participant> listeners,
    LiveKitRoomService service,
  ) {
    if (listeners.isEmpty && !_isDragging) return const SizedBox();

    Widget content = Column(
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
        if (listeners.isNotEmpty)
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
              final p = listeners[index];
              final avatar = _buildParticipantAvatar(p, false, index);
              final handRaised = service.isHandRaised(p);

              // Host can drag hand-raised listeners to speaker zone
              if (widget.isHost && handRaised) {
                return LongPressDraggable<Participant>(
                  data: p,
                  onDragStarted: () => setState(() => _isDragging = true),
                  onDragEnd: (_) => setState(() => _isDragging = false),
                  onDraggableCanceled: (_, __) =>
                      setState(() => _isDragging = false),
                  feedback: Material(
                    color: Colors.transparent,
                    child: SizedBox(
                      width: 60.w,
                      child: Opacity(opacity: 0.85, child: avatar),
                    ),
                  ),
                  childWhenDragging: Opacity(opacity: 0.3, child: avatar),
                  child: GestureDetector(
                    onTap: () => _showProfileCard(context, p, service),
                    child: avatar,
                  ),
                );
              }

              return GestureDetector(
                onTap: () => _showProfileCard(context, p, service),
                child: avatar,
              );
            },
          ),
        if (listeners.isEmpty && _isDragging)
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24.h),
              child: Text(
                'Drop here to move back to listeners',
                style: TextStyle(fontSize: 12.sp, color: AppTheme.textGrey),
              ),
            ),
          ),
      ],
    );

    // Wrap in DragTarget — host can drop speakers here to demote
    if (widget.isHost) {
      return DragTarget<Participant>(
        onWillAcceptWithDetails: (details) {
          // Accept only current speakers (demoting)
          return !listeners.contains(details.data);
        },
        onAcceptWithDetails: (details) {
          final p = details.data;
          // Revoke speaker: mute + remove publish permission
          // For now, mute them which effectively demotes
          if (p.audioTrackPublications.isNotEmpty) {
            service.muteParticipant(
              p.identity,
              p.audioTrackPublications.first.sid,
              true,
            );
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${p.name} moved to listeners')),
          );
        },
        builder: (context, candidateData, rejectedData) {
          final isHovering = candidateData.isNotEmpty;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              border: _isDragging
                  ? Border.all(
                      color: isHovering
                          ? AppTheme.mintGreen
                          : AppTheme.textGrey.withValues(alpha: 0.3),
                      width: isHovering ? 2.5 : 1.5,
                      strokeAlign: BorderSide.strokeAlignOutside,
                    )
                  : null,
              color: isHovering
                  ? AppTheme.mintGreen.withValues(alpha: 0.05)
                  : Colors.transparent,
            ),
            child: content,
          );
        },
      );
    }
    return content;
  }

  // ─── BOTTOM CONTROLS ──────────────────
  Widget _buildBottomControls(bool isMuted, LiveKitRoomService service) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // Hand raise (for listeners)
              GestureDetector(
                onTap: () {
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
              // Mic toggle — only for speakers
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
              child: Text(
                '✌️ Leave quietly',
                style: TextStyle(
                  color: const Color(0xFFEF4444),
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── PARTICIPANT AVATAR ───────────────
  Widget _buildParticipantAvatar(Participant p, bool isSpeaker, int index) {
    final colors = _avatarColors[index % _avatarColors.length];
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
              // Hand raise indicator
              if (Provider.of<LiveKitRoomService>(
                context,
                listen: false,
              ).isHandRaised(p))
                Positioned(
                  top: -4,
                  left: -4,
                  child: _buildIndicator(
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
                      final muted =
                          p.audioTrackPublications.isEmpty ||
                          p.audioTrackPublications.every((pub) => pub.muted);
                      if (muted) {
                        return _buildIndicator(
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

  Widget _buildIndicator({
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

  // ─── PROFILE ID CARD (bottom sheet) ───
  void _showProfileCard(
    BuildContext context,
    Participant p,
    LiveKitRoomService service,
  ) {
    final isLocal = p is LocalParticipant;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          margin: EdgeInsets.all(16.w),
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag indicator
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 20.h),

              // Avatar
              Container(
                width: 72.w,
                height: 72.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFF3E8FF),
                  border: Border.all(
                    color: AppTheme.skyBlue.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  EmojiUtils.getEmojiForName(p.name),
                  style: TextStyle(fontSize: 32.sp),
                ),
              ),
              SizedBox(height: 12.h),

              // Name
              Text(
                EmojiUtils.getNameWithoutTag(p.name),
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                ),
              ),
              SizedBox(height: 4.h),

              // Role badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: _getRoleBadgeColor(p),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  _getRoleLabel(p),
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 20.h),

              // Action buttons
              if (!isLocal)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Follow button
                    _buildCardButton(
                      icon: Icons.person_add_rounded,
                      label: 'Follow',
                      color: AppTheme.skyBlue,
                      onTap: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Followed ${p.name}')),
                        );
                      },
                    ),
                    SizedBox(width: 12.w),
                    // Report button
                    _buildCardButton(
                      icon: Icons.flag_rounded,
                      label: 'Report',
                      color: Colors.orange,
                      onTap: () {
                        Navigator.pop(ctx);
                        _showReportDialog(context, p);
                      },
                    ),
                    // Kick — host only
                    if (widget.isHost) ...[
                      SizedBox(width: 12.w),
                      _buildCardButton(
                        icon: Icons.remove_circle_rounded,
                        label: 'Kick',
                        color: const Color(0xFFEF4444),
                        onTap: () {
                          Navigator.pop(ctx);
                          _showKickConfirmation(context, p);
                        },
                      ),
                    ],
                  ],
                ),
              SizedBox(height: 8.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCardButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16.sp, color: color),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoleBadgeColor(Participant p) {
    if (p.metadata?.contains('"role": "admin"') == true) {
      return const Color(0xFF9333EA);
    }
    if (p.metadata?.contains('"role": "doctor"') == true) {
      return const Color(0xFF2563EB);
    }
    if (p.metadata?.contains('"role": "bot"') == true) {
      return const Color(0xFF059669);
    }
    return AppTheme.textGrey;
  }

  String _getRoleLabel(Participant p) {
    if (p is LocalParticipant) return 'You';
    if (p.metadata?.contains('"role": "admin"') == true) return 'Admin';
    if (p.metadata?.contains('"role": "doctor"') == true) return 'Doctor';
    if (p.metadata?.contains('"role": "bot"') == true) return 'Bot';
    return 'Participant';
  }

  // ─── KICK CONFIRMATION ────────────────
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

  // ─── REPORT DIALOG ────────────────────
  void _showReportDialog(BuildContext context, Participant p) {
    String selectedReason = 'harassment';
    final repo = context.read<CommunityRepository>();
    final roomId = context.read<LiveKitRoomService>().activeRoomId;
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Report ${p.name}'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Why are you reporting this user?'),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: selectedReason,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(
                          value: 'harassment',
                          child: Text('Harassment or Bullying'),
                        ),
                        DropdownMenuItem(
                          value: 'spam',
                          child: Text('Spam or Promotional'),
                        ),
                        DropdownMenuItem(
                          value: 'inappropriate',
                          child: Text('Inappropriate Content'),
                        ),
                        DropdownMenuItem(
                          value: 'self_harm',
                          child: Text('Self-Harm Threats'),
                        ),
                        DropdownMenuItem(value: 'other', child: Text('Other')),
                      ],
                      onChanged: (val) {
                        setState(() => selectedReason = val!);
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        hintText: 'Additional details (optional)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () async {
                    Navigator.pop(context);
                    try {
                      await repo.submitReport(
                        p.identity,
                        roomId,
                        selectedReason,
                        descriptionController.text,
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Report submitted successfully. Thank you.',
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Failed to submit report. Please try again.',
                            ),
                          ),
                        );
                      }
                    }
                  },
                  child: const Text(
                    'Submit Report',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
