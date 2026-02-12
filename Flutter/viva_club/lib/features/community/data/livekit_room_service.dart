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

  LiveKitRoomService({required this.communityRepository});

  Room? get room => _room;
  String? get activeRoomId => _activeRoomId;
  String? get currentTitle => _currentTitle;
  bool get isHost => _isHost;
  bool get isConnecting => _isConnecting;
  List<Participant> get participants => _participants;
  bool get isMuted {
    final p = _room?.localParticipant;
    if (p == null) return true;
    // Considered muted if no audio tracks or all audio tracks are muted
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

      // Check if we have permission to publish
      if (enabled) {
        // LiveKit's permissions object isn't always fully populated immediately after join for listeners
        // But we can check if we are meant to be a publisher via metadata or role if we had that info.
        // For now, let's catch the specific error or check if we can publish.
        // A safer way is to check the participant's permissions if available.
        // However, simply wrapping in try-catch as done below is good, but we should handle the specific error.
      }

      await p.setMicrophoneEnabled(enabled);
      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling microphone: $e');
      // Optional: rethrow or notify UI of error
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

      // Update metadata: {"handRaised": true}
      p.setMetadata('{"handRaised": $isRaised}');
      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling hand raise: $e');
    }
  }

  bool isHandRaised(Participant p) {
    try {
      if (p.metadata == null || p.metadata!.isEmpty) return false;
      // Simple string check to avoid full JSON parsing overhead if simple
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

  @override
  void dispose() {
    leave();
    super.dispose();
  }
}
