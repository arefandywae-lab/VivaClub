import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/following_repository.dart';

// Events
abstract class FollowingEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FollowingLoad extends FollowingEvent {}

class FollowingToggle extends FollowingEvent {
  final String ghostId;
  final bool isCurrentlyFollowing;

  FollowingToggle(this.ghostId, this.isCurrentlyFollowing);

  @override
  List<Object?> get props => [ghostId, isCurrentlyFollowing];
}

class FollowingFeedLoad extends FollowingEvent {}

// States
abstract class FollowingState extends Equatable {
  @override
  List<Object?> get props => [];
}

class FollowingInitial extends FollowingState {}

class FollowingLoading extends FollowingState {}

class FollowingLoaded extends FollowingState {
  final List<Map<String, dynamic>> following;

  FollowingLoaded(this.following);

  @override
  List<Object?> get props => [following];
}

class FollowingFeedLoaded extends FollowingState {
  final List<Map<String, dynamic>> rooms;

  FollowingFeedLoaded(this.rooms);

  @override
  List<Object?> get props => [rooms];
}

class FollowingToggleSuccess extends FollowingState {
  final String message;
  final bool isNowFollowing;

  FollowingToggleSuccess(this.message, this.isNowFollowing);

  @override
  List<Object?> get props => [message, isNowFollowing];
}

class FollowingFailure extends FollowingState {
  final String message;

  FollowingFailure(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class FollowingBloc extends Bloc<FollowingEvent, FollowingState> {
  final FollowingRepository _repository;

  FollowingBloc(this._repository) : super(FollowingInitial()) {
    on<FollowingLoad>(_onFollowingLoad);
    on<FollowingToggle>(_onFollowingToggle);
    on<FollowingFeedLoad>(_onFollowingFeedLoad);
  }

  Future<void> _onFollowingLoad(
    FollowingLoad event,
    Emitter<FollowingState> emit,
  ) async {
    emit(FollowingLoading());
    try {
      final following = await _repository.getFollowingList();
      emit(FollowingLoaded(following));
    } catch (e) {
      emit(FollowingFailure(e.toString()));
    }
  }

  Future<void> _onFollowingToggle(
    FollowingToggle event,
    Emitter<FollowingState> emit,
  ) async {
    try {
      if (event.isCurrentlyFollowing) {
        final result = await _repository.unfollowGhost(event.ghostId);
        emit(FollowingToggleSuccess(result['message'] ?? 'Unfollowed', false));
      } else {
        final result = await _repository.followGhost(event.ghostId);
        emit(
          FollowingToggleSuccess(result['message'] ?? 'Now following', true),
        );
      }
      // Reload following list
      add(FollowingLoad());
    } catch (e) {
      emit(FollowingFailure(e.toString()));
    }
  }

  Future<void> _onFollowingFeedLoad(
    FollowingFeedLoad event,
    Emitter<FollowingState> emit,
  ) async {
    emit(FollowingLoading());
    try {
      final result = await _repository.getFollowingFeed();
      final rooms = List<Map<String, dynamic>>.from(result['rooms'] ?? []);
      emit(FollowingFeedLoaded(rooms));
    } catch (e) {
      emit(FollowingFailure(e.toString()));
    }
  }
}
