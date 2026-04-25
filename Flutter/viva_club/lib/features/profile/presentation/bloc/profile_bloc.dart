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
  final Map<String, dynamic> trustScore;

  const ProfileLoaded({
    required this.user,
    required this.appointments,
    required this.trustScore,
  });

  @override
  List<Object> get props => [user, appointments, trustScore];

  /// Upcoming = status is 'CONFIRMED' or 'PENDING'
  List<dynamic> get upcomingAppointments {
    final list = appointments
        .where((a) => a['status'] == 'CONFIRMED' || a['status'] == 'PENDING')
        .toList();
    
    // Sort by start_time ascending
    list.sort((a, b) {
      final t1 = DateTime.tryParse(a['slot_detail']?['start_time']?.toString() ?? '') ?? DateTime(2099);
      final t2 = DateTime.tryParse(b['slot_detail']?['start_time']?.toString() ?? '') ?? DateTime(2099);
      return t1.compareTo(t2);
    });
    
    return list;
  }

  /// Past = status is 'COMPLETED' or 'CANCELLED'
  List<dynamic> get pastAppointments {
    final list = appointments
        .where((a) => a['status'] == 'COMPLETED' || a['status'] == 'CANCELLED')
        .toList();
    
    // Sort by start_time descending (most recent first)
    list.sort((a, b) {
      final t1 = DateTime.tryParse(a['slot_detail']?['start_time']?.toString() ?? '') ?? DateTime(2000);
      final t2 = DateTime.tryParse(b['slot_detail']?['start_time']?.toString() ?? '') ?? DateTime(2000);
      return t2.compareTo(t1);
    });
    
    return list;
  }
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
      final results = await Future.wait([
        _profileRepository.getProfile(),
        _profileRepository.getMyAppointments(),
        _profileRepository.getTrustScore(),
      ]);

      final user = results[0] as Map<String, dynamic>;
      final appointments = results[1] as List<dynamic>;
      final trustScore = results[2] as Map<String, dynamic>;

      emit(
        ProfileLoaded(
          user: user,
          appointments: appointments,
          trustScore: trustScore,
        ),
      );
    } catch (e) {
      emit(ProfileFailure(e.toString()));
    }
  }
}
