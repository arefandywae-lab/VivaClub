import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/community_repository.dart';

// --- Events ---
abstract class RoomEvent extends Equatable {
  const RoomEvent();
  @override
  List<Object> get props => [];
}

class RoomLoad extends RoomEvent {
  final String? search;
  final String sort;
  const RoomLoad({this.search, this.sort = 'recent'});
  @override
  List<Object> get props => [search ?? '', sort];
}

class RoomCreate extends RoomEvent {
  final String title;
  final String category;
  const RoomCreate(this.title, this.category);
}

class RoomJoin extends RoomEvent {
  final String roomId;
  const RoomJoin(this.roomId);
}

// --- States ---
abstract class RoomState extends Equatable {
  const RoomState();
  @override
  List<Object> get props => [];
}

class RoomInitial extends RoomState {}

class RoomLoading extends RoomState {}

class RoomLoaded extends RoomState {
  final List<dynamic> rooms;
  const RoomLoaded(this.rooms);
  @override
  List<Object> get props => [rooms];
}

class RoomActionProcess extends RoomState {} // Creating...

class RoomJoined extends RoomState {
  final String token;
  final String url;
  final String roomId;
  final String title;
  final bool isHost;

  const RoomJoined({
    required this.token,
    required this.url,
    required this.roomId,
    required this.title,
    this.isHost = false,
  });
}

class RoomFailure extends RoomState {
  final String message;
  const RoomFailure(this.message);
}

// --- BLoC ---
class RoomBloc extends Bloc<RoomEvent, RoomState> {
  final CommunityRepository _communityRepository;

  RoomBloc({required CommunityRepository communityRepository})
    : _communityRepository = communityRepository,
      super(RoomInitial()) {
    on<RoomLoad>(_onLoad);
    on<RoomCreate>(_onCreate);
    on<RoomJoin>(_onJoin);
  }

  Future<void> _onLoad(RoomLoad event, Emitter<RoomState> emit) async {
    emit(RoomLoading());
    try {
      final rooms = await _communityRepository.getRooms(
        search: event.search,
        sort: event.sort,
      );
      emit(RoomLoaded(rooms));
    } catch (e) {
      emit(RoomFailure(e.toString()));
    }
  }

  Future<void> _onCreate(RoomCreate event, Emitter<RoomState> emit) async {
    try {
      final room = await _communityRepository.createRoom(
        event.title,
        event.category,
      );
      // Auto-join the room after creating it
      final roomId = room['id'];
      final data = await _communityRepository.joinRoom(roomId);
      emit(
        RoomJoined(
          token: data['token'],
          url: data['url'],
          roomId: data['room_id'],
          title: event.title,
          isHost: data['is_host'] ?? true,
        ),
      );
      await Future.delayed(const Duration(milliseconds: 500));
      add(RoomLoad());
    } catch (e) {
      emit(RoomFailure(e.toString()));
    }
  }

  Future<void> _onJoin(RoomJoin event, Emitter<RoomState> emit) async {
    try {
      final data = await _communityRepository.joinRoom(event.roomId);
      emit(
        RoomJoined(
          token: data['token'],
          url: data['url'],
          roomId: data['room_id'],
          title: data['title'] ?? 'Room',
          isHost: data['is_host'] ?? false,
        ),
      );
      // Delay reload so the BlocConsumer listener has time to navigate
      await Future.delayed(const Duration(milliseconds: 500));
      add(RoomLoad());
    } catch (e) {
      emit(RoomFailure(e.toString()));
      add(RoomLoad()); // Restore list state
    }
  }
}
