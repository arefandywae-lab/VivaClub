import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/auth_repository.dart';

// --- Events ---
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object> get props => [];
}

class AuthLoginRequested extends AuthEvent {
  final String username;
  final String password;
  const AuthLoginRequested(this.username, this.password);
}

class AuthRegisterRequested extends AuthEvent {
  final String username;
  final String email;
  final String password;
  const AuthRegisterRequested(this.username, this.email, this.password);
}

class AuthLogoutRequested extends AuthEvent {}

class AuthCheckRequested extends AuthEvent {}

class ProfileRefreshRequested extends AuthEvent {}

class AuthForgotPasswordRequested extends AuthEvent {
  final String email;
  const AuthForgotPasswordRequested(this.email);
  @override
  List<Object> get props => [email];
}

// --- States ---
abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {
  final Map<String, dynamic> user; // Profile data
  const AuthAuthenticated(this.user);

  @override
  List<Object> get props => [user];
}
class AuthUnauthenticated extends AuthState {}
class AuthFailure extends AuthState {
  final String message;
  const AuthFailure(this.message);
}

class AuthForgotPasswordSuccess extends AuthState {
  final String message;
  const AuthForgotPasswordSuccess(this.message);
}

// --- BLoC ---
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository}) 
      : _authRepository = authRepository, 
        super(AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthCheckRequested>(_onCheckRequested);
    on<ProfileRefreshRequested>(_onProfileRefreshRequested);
    on<AuthForgotPasswordRequested>(_onForgotPasswordRequested);
  }

  Future<void> _onProfileRefreshRequested(ProfileRefreshRequested event, Emitter<AuthState> emit) async {
    try {
      final profile = await _authRepository.getProfile();
      emit(AuthAuthenticated(profile));
    } catch (_) {
      // Ignore background refresh failures
    }
  }

  Future<void> _onLoginRequested(AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authRepository.login(event.username, event.password);
      // After login, fetch profile
      final profile = await _authRepository.getProfile();
      emit(AuthAuthenticated(profile));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onRegisterRequested(AuthRegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authRepository.register(event.username, event.email, event.password);
      // Auto login after register or ask user to login?
      // Let's auto login for better UX
      await _authRepository.login(event.username, event.password);
      final profile = await _authRepository.getProfile();
      emit(AuthAuthenticated(profile));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onLogoutRequested(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await _authRepository.logout();
    emit(AuthUnauthenticated());
  }

  Future<void> _onCheckRequested(AuthCheckRequested event, Emitter<AuthState> emit) async {
      try {
          // Try fetching profile to check if token is valid
          final profile = await _authRepository.getProfile();
          emit(AuthAuthenticated(profile));
      } catch (_) {
          emit(AuthUnauthenticated());
      }
  }

  Future<void> _onForgotPasswordRequested(AuthForgotPasswordRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authRepository.forgotPassword(event.email);
      emit(const AuthForgotPasswordSuccess("Reset link sent! Please check your email."));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }
}
