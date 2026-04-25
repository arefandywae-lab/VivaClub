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
  bool _wasKicked = false;
  List<Participant> _participants = [];

  LiveKitRoomService({required this.communityRepository});

  Room? get room => _room;
  String? get activeRoomId => _activeRoomId;
  String? get currentTitle => _currentTitle;
  bool get isHost => _isHost;
  bool get isConnecting => _isConnecting;
  bool get wasKicked => _wasKicked;
  List<Participant> get participants => _participants;
  bool get isMuted {
    final p = _room?.localParticipant;
    if (p == null) return true;
    return p.audioTrackPublications.isEmpty ||
        p.audioTrackPublications.every((track) => track.muted);
  }

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

    // Reset wasKicked status immediately when starting a new connection attempt
    _wasKicked = false;

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
      _wasKicked = false;

      // Listen for disconnection (kicked by host or room finished)
      _room!.events.listen((event) {
        if (event is RoomDisconnectedEvent) {
          // Only trigger wasKicked if it wasn't a manual leave (activeRoomId still set)
          if (_activeRoomId != null) {
            debugPrint('Room disconnected unexpectedly — likely kicked or room closed');
            _wasKicked = true;
            _activeRoomId = null;
            _currentTitle = null;
            _isHost = false;
            _participants = [];
            _room = null;
            notifyListeners();
          }
        }
      });

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

  void _onRoomEvent([dynamic _]) {
    _updateParticipants();
    notifyListeners();
  }

  void _updateParticipants() {
    if (_room == null || _room!.localParticipant == null) return;
    _participants = [
      _room!.localParticipant!,
      ..._room!.remoteParticipants.values,
    ];
  }

  Future<void> setMicrophoneEnabled(bool enabled) async {
    try {
      final p = _room?.localParticipant;
      if (p == null) return;
      await p.setMicrophoneEnabled(enabled);
      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling microphone: $e');
    }
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
      // Remove listener before disconnecting to avoid event loop issues
      roomToDispose?.removeListener(_onRoomEvent);
      await roomToDispose?.disconnect();
      await roomToDispose?.dispose();
    } catch (e) {
      debugPrint('Error leaving room: $e');
    }
  }

  Future<void> toggleHandRaise(bool isRaised) async {
    try {
      final p = _room?.localParticipant;
      if (p == null) return;
      p.setMetadata('{"handRaised": $isRaised}');
      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling hand raise: $e');
    }
  }

  bool isHandRaised(Participant p) {
    try {
      if (p.metadata == null || p.metadata!.isEmpty) return false;
      return p.metadata!.contains('"handRaised": true');
    } catch (_) {
      return false;
    }
  }

  Future<void> inviteSpeaker(String identity) async {
    if (_activeRoomId != null) {
      await communityRepository.inviteSpeaker(_activeRoomId!, identity);
    }
  }

  Future<void> demoteSpeaker(String identity) async {
    if (_activeRoomId != null) {
      await communityRepository.demoteSpeaker(_activeRoomId!, identity);
    }
  }

  Future<void> muteParticipant(
    String identity,
    String trackSid,
    bool muted,
  ) async {
    if (_activeRoomId != null) {
      await communityRepository.muteParticipant(
        _activeRoomId!,
        identity,
        trackSid,
        muted,
      );
    }
  }

  Future<void> kickParticipant(String identity) async {
    if (_activeRoomId != null) {
      await communityRepository.kickParticipant(_activeRoomId!, identity);
    }
  }

  Future<void> promoteModerator(String identity) async {
    if (_activeRoomId != null) {
      await communityRepository.promoteModerator(_activeRoomId!, identity);
    }
  }

  Future<void> demoteModerator(String identity) async {
    if (_activeRoomId != null) {
      await communityRepository.demoteModerator(_activeRoomId!, identity);
    }
  }

  @override
  void dispose() {
    leave();
    super.dispose();
  }
}
