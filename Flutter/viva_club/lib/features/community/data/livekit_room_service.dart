import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';
import 'community_repository.dart';

class LiveKitRoomService extends ChangeNotifier {
  final CommunityRepository communityRepository;

  Room? _room;
  String? _activeRoomId;
  String? _currentTitle;
  bool _isHost = false;
  bool _isConnecting = false;
  List<Participant> _participants = [];
  bool _isMuted = true;

  LiveKitRoomService({required this.communityRepository});

  Room? get room => _room;
  String? get activeRoomId => _activeRoomId;
  String? get currentTitle => _currentTitle;
  bool get isHost => _isHost;
  bool get isConnecting => _isConnecting;
  List<Participant> get participants => _participants;
  bool get isMuted => _isMuted;
  bool get isActive => _activeRoomId != null;

  Future<void> connect({
    required String url,
    required String token,
    required String roomId,
    required String title,
    required bool isHost,
  }) async {
    // If already in this room, do nothing
    if (_activeRoomId == roomId && _room != null) return;

    // If in another room, leave it first
    if (_activeRoomId != null) {
      await leave();
    }

    _isConnecting = true;
    _currentTitle = title;
    notifyListeners();

    try {
      _room = Room();

      // Wire up events
      _room!.addListener(_onRoomEvent);

      await _room!.connect(
        url,
        token,
        connectOptions: const ConnectOptions(autoSubscribe: true),
      );

      _activeRoomId = roomId;
      _isHost = isHost;
      _isConnecting = false;

      if (isHost) {
        await _room!.localParticipant?.setMicrophoneEnabled(true);
        _isMuted = false;
      } else {
        _isMuted = true;
      }

      _updateParticipants();
      notifyListeners();
    } catch (e) {
      _isConnecting = false;
      _activeRoomId = null;
      _room = null;
      notifyListeners();
      rethrow;
    }
  }

  void _onRoomEvent() {
    _updateParticipants();
    notifyListeners();
  }

  void _updateParticipants() {
    if (_room == null) return;
    _participants = [
      _room!.localParticipant!,
      ..._room!.remoteParticipants.values,
    ];
  }

  Future<void> setMicrophoneEnabled(bool enabled) async {
    await _room?.localParticipant?.setMicrophoneEnabled(enabled);
    _isMuted = !enabled;
    notifyListeners();
  }

  Future<void> leave() async {
    if (_activeRoomId == null) return;

    final roomId = _activeRoomId!;
    _activeRoomId = null;
    _currentTitle = null;
    _isHost = false;
    _participants = [];

    final roomToDispose = _room;
    _room = null;

    notifyListeners();

    // Background cleanup
    communityRepository.leaveRoom(roomId);
    try {
      await roomToDispose?.disconnect();
      await roomToDispose?.dispose();
    } catch (e) {
      debugPrint('Error leaving room: $e');
    }
  }

  @override
  void dispose() {
    leave();
    super.dispose();
  }
}
