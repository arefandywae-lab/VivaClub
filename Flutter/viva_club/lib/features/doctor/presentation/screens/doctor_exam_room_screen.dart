import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../features/clinical/data/clinical_repository.dart';

class DoctorExamRoomScreen extends StatefulWidget {
  final String url;
  final String token;
  final String roomName;
  final String patientName;
  final String appointmentId;
  final bool isSos;

  const DoctorExamRoomScreen({
    super.key,
    required this.url,
    required this.token,
    required this.roomName,
    required this.appointmentId,
    this.isSos = false,
    this.patientName = 'Anonymous Panda',
  });

  @override
  State<DoctorExamRoomScreen> createState() => _DoctorExamRoomScreenState();
}

class _DoctorExamRoomScreenState extends State<DoctorExamRoomScreen> {
  final ClinicalRepository _repository = ClinicalRepository();
  Room? _room;
  List<Participant> _participants = [];
  EventsListener<RoomEvent>? _listener;
  
  int _activeTab = 0; 
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();
  
  List<Map<String, dynamic>> _messages = [];
  bool _isMicOn = true;
  bool _isVideoOn = true;
  Timer? _debounce;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _connect();
    _fetchInitialData();
    _noteController.addListener(_onNoteChanged);
  }

  Future<void> _fetchInitialData() async {
    try {
      final apps = await _repository.getMyAppointments();
      final app = apps.firstWhere((a) => a['id'].toString() == widget.appointmentId);
      if (app != null && app['clinical_notes'] != null) {
        setState(() {
          _noteController.text = app['clinical_notes'];
        });
      }
    } catch (e) {
      debugPrint('❌ Error fetching initial note: $e');
    }
  }

  void _onNoteChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 1000), () {
      _saveNote();
    });
  }

  Future<void> _saveNote() async {
    if (_noteController.text.isEmpty) return;
    setState(() => _isSaving = true);
    try {
      await _repository.saveOPDNote(
        appointmentId: widget.appointmentId,
        note: _noteController.text,
      );
    } catch (e) {
      // Handle error silently
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _completeSession() async {
    setState(() => _isSaving = true);
    try {
      // 1. Final save of notes
      if (_noteController.text.isNotEmpty) {
        await _repository.saveOPDNote(
          appointmentId: widget.appointmentId,
          note: _noteController.text,
        );
      }
      
      // 2. Call complete API
      if (widget.isSos) {
        await _repository.completeSOSCall(widget.appointmentId);
      } else {
        await _repository.completeAppointment(widget.appointmentId);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session completed successfully'), backgroundColor: Color(0xFF0D9488)),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _connect() async {
    try {
      final room = Room();
      _room = room;
      _listener = room.createListener();
      _listener!..on<TrackSubscribedEvent>((_) => _onRoomUpdate())
               ..on<TrackUnsubscribedEvent>((_) => _onRoomUpdate())
               ..on<ParticipantConnectedEvent>((_) => _onRoomUpdate())
               ..on<ParticipantDisconnectedEvent>((_) => _onRoomUpdate())
               ..on<DataReceivedEvent>((event) {
                  final data = utf8.decode(event.data);
                  final msg = json.decode(data);
                  if (mounted) {
                    setState(() {
                      _messages.add({
                        'sender': event.participant?.identity ?? 'Patient',
                        'text': msg['text'],
                        'isMe': false,
                        'time': DateTime.now(),
                      });
                    });
                    _scrollToBottom();
                  }
               });

      await room.connect(
        widget.url,
        widget.token,
        roomOptions: RoomOptions(
          adaptiveStream: true,
          dynacast: true,
        ),
      );
      
      final local = room.localParticipant;
      if (local != null) {
        try {
          await local.setCameraEnabled(true);
        } catch (e) {
          debugPrint('📸 Camera not available: $e');
        }
        try {
          await local.setMicrophoneEnabled(true);
        } catch (e) {
          debugPrint('🎙️ Mic not available: $e');
        }
      }
      _onRoomUpdate();
    } catch (e) {
      debugPrint('📽️ VIDEOCALL ERROR: $e');
      if (mounted) context.pop();
    }
  }

  void _onRoomUpdate() {
    if (_room == null || _room!.localParticipant == null) return;
    if (mounted) {
      setState(() {
        _participants = [_room!.localParticipant!, ..._room!.remoteParticipants.values];
      });
    }
  }

  void _sendChatMessage() {
    if (_chatController.text.trim().isEmpty || _room == null) return;
    
    final text = _chatController.text.trim();
    final msg = json.encode({'text': text, 'type': 'chat'});
    final data = utf8.encode(msg);

    _room!.localParticipant?.publishData(data);
    
    setState(() {
      _messages.add({
        'sender': 'Me',
        'text': text,
        'isMe': true,
        'time': DateTime.now(),
      });
    });
    
    _chatController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _noteController.removeListener(_onNoteChanged);
    _noteController.dispose();
    _chatController.dispose();
    _chatScrollController.dispose();
    _listener?.dispose();
    _room?.disconnect();
    _room?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Column(
        children: [
          _buildVideoArea(),
          Expanded(child: _buildInteractivePanel()),
        ],
      ),
    );
  }

  Widget _buildVideoArea() {
    final remote = _participants.whereType<RemoteParticipant>().firstOrNull;
    final local = _room?.localParticipant;
    final localTrack = local?.videoTrackPublications.firstOrNull?.track;

    return Container(
      height: 0.4.sh,
      width: double.infinity,
      color: Colors.black,
      child: Stack(
        children: [
          if (remote != null && remote.videoTrackPublications.isNotEmpty)
            Positioned.fill(
              child: VideoTrackRenderer(remote.videoTrackPublications.first.track as VideoTrack),
            )
          else
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Color(0xFF2DD4BF)),
                  SizedBox(height: 16.h),
                  Text('Waiting for patient...', style: GoogleFonts.inter(color: Colors.white70)),
                ],
              ),
            ),

          Positioned(
            top: 50.h,
            right: 16.w,
            child: Container(
              width: 90.w,
              height: 120.h,
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: const Color(0xFF334155), width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14.r),
                child: localTrack != null
                    ? VideoTrackRenderer(localTrack as VideoTrack)
                    : const Icon(Icons.person, color: Color(0xFF475569)),
              ),
            ),
          ),

          Positioned(
            bottom: 20.h,
            left: 0, right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildFloatingAction(_isMicOn ? Icons.mic : Icons.mic_off, !_isMicOn, () {
                  setState(() => _isMicOn = !_isMicOn);
                  local?.setMicrophoneEnabled(_isMicOn);
                }),
                SizedBox(width: 16.w),
                _buildFloatingAction(_isVideoOn ? Icons.videocam : Icons.videocam_off, !_isVideoOn, () {
                  setState(() => _isVideoOn = !_isVideoOn);
                  local?.setCameraEnabled(_isVideoOn);
                }),
                SizedBox(width: 16.w),
                _buildFloatingAction(Icons.close, true, () => context.pop(), color: const Color(0xFFEF4444)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingAction(IconData icon, bool isActive, VoidCallback onTap, {Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: color ?? (isActive ? const Color(0xFFEF4444) : Colors.white.withOpacity(0.2)),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 24.sp),
      ),
    );
  }

  Widget _buildInteractivePanel() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(32.r), topRight: Radius.circular(32.r)),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
            child: Row(
              children: [
                _buildTab(0, Icons.person_outline, 'Profile'),
                SizedBox(width: 8.w),
                _buildTab(1, Icons.description_outlined, 'OPD Note'),
                SizedBox(width: 8.w),
                _buildTab(2, Icons.chat_bubble_outline, 'Chat'),
              ],
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: _activeTab,
              children: [
                _buildProfileTab(),
                _buildNoteTab(),
                _buildChatTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(int index, IconData icon, String label) {
    bool active = _activeTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = index),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF0F172A) : Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: active ? Colors.transparent : const Color(0xFFE2E8F0)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16.sp, color: active ? Colors.white : const Color(0xFF64748B)),
              SizedBox(width: 6.w),
              Text(label, style: GoogleFonts.inter(color: active ? Colors.white : const Color(0xFF64748B), fontSize: 12.sp, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          _buildInfoRow('Patient Name', widget.patientName),
          _buildInfoRow('Appointment ID', '#${widget.appointmentId}'),
          _buildInfoRow('Session Status', 'Live / In-Progress', valueColor: const Color(0xFF10B981)),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: _isSaving ? null : _completeSession,
            icon: _isSaving 
                ? SizedBox(width: 16.w, height: 16.w, child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.check_circle_outline),
            label: Text(_isSaving ? 'Finishing...' : 'Complete Session'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D9488),
              foregroundColor: Colors.white,
              minimumSize: Size(double.infinity, 50.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9)))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label.toUpperCase(), style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 10.sp, fontWeight: FontWeight.bold)),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              value, 
              textAlign: TextAlign.right,
              style: GoogleFonts.inter(color: valueColor ?? const Color(0xFF0F172A), fontSize: 14.sp, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteTab() {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          Expanded(
            child: TextField(
              controller: _noteController,
              maxLines: null,
              expands: true,
              style: GoogleFonts.inter(fontSize: 14.sp, color: const Color(0xFF1E293B), height: 1.6),
              decoration: InputDecoration(
                hintText: 'Type clinical notes here...',
                hintStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8)),
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.r), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_isSaving ? 'Saving...' : 'All changes saved', 
                  style: GoogleFonts.inter(color: _isSaving ? Colors.orange : const Color(0xFF0D9488), fontSize: 11.sp, fontWeight: FontWeight.bold)),
              Icon(_isSaving ? Icons.sync : Icons.check_circle, color: _isSaving ? Colors.orange : const Color(0xFF0D9488), size: 14),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChatTab() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _chatScrollController,
            padding: EdgeInsets.all(20.w),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final msg = _messages[index];
              final isMe = msg['isMe'];
              return Align(
                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: EdgeInsets.only(bottom: 8.h),
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: isMe ? const Color(0xFF0F172A) : Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                  ),
                  child: Column(
                    crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Text(
                        msg['text'],
                        style: GoogleFonts.inter(color: isMe ? Colors.white : const Color(0xFF0F172A), fontSize: 14.sp),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        DateFormat('HH:mm').format(msg['time']),
                        style: GoogleFonts.inter(color: isMe ? Colors.white54 : Colors.grey, fontSize: 9.sp),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: const Color(0xFFF1F5F9))),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _chatController,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    border: InputBorder.none,
                    hintStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8)),
                  ),
                  onSubmitted: (_) => _sendChatMessage(),
                ),
              ),
              IconButton(
                onPressed: _sendChatMessage,
                icon: const Icon(Icons.send, color: Color(0xFF0D9488)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
