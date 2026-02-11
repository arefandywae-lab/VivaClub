import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/profile_repository.dart';

// --- Events ---
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object> get props => [];
}

class ProfileLoad extends ProfileEvent {}

// --- States ---
abstract class ProfileState extends Equatable {
  const ProfileState();
  @override
  List<Object> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final Map<String, dynamic> user;
  final List<dynamic> appointments;

  const ProfileLoaded({required this.user, required this.appointments});

  @override
  List<Object> get props => [user, appointments];

  /// Upcoming = status is 'available', 'reserved', or 'confirmed' and in the future
  List<dynamic> get upcomingAppointments => appointments
      .where((a) => a['status'] == 'confirmed' || a['status'] == 'reserved')
      .toList();

  /// Past = status is 'completed' or 'cancelled'
  List<dynamic> get pastAppointments => appointments
      .where((a) => a['status'] == 'completed' || a['status'] == 'cancelled')
      .toList();
}

class ProfileFailure extends ProfileState {
  final String message;
  const ProfileFailure(this.message);
  @override
  List<Object> get props => [message];
}

// --- BLoC ---
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _profileRepository;

  ProfileBloc({required ProfileRepository profileRepository})
    : _profileRepository = profileRepository,
      super(ProfileInitial()) {
    on<ProfileLoad>(_onLoad);
  }

  Future<void> _onLoad(ProfileLoad event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      // Fetch profile and appointments in parallel
      final results = await Future.wait([
        _profileRepository.getProfile(),
        _profileRepository.getMyAppointments(),
      ]);

      final user = results[0] as Map<String, dynamic>;
      final appointments = results[1] as List<dynamic>;

      emit(ProfileLoaded(user: user, appointments: appointments));
    } catch (e) {
      emit(ProfileFailure(e.toString()));
    }
  }
}
