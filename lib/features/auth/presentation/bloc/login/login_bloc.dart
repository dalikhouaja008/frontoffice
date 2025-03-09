// lib/features/auth/presentation/bloc/login/login_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_boost/core/services/secure_storage_service.dart';
import 'package:the_boost/core/services/session_service.dart';
import 'package:the_boost/features/auth/domain/entities/user.dart';
import 'package:the_boost/features/auth/domain/entities/user_preferences.dart';
import 'package:the_boost/features/auth/domain/use_cases/login_use_case.dart';

// Events
abstract class LoginEvent {}

class LoginRequested extends LoginEvent {
  final String email;
  final String password;

  LoginRequested(this.email, this.password);
}

class CheckSession extends LoginEvent {}

class LogoutRequested extends LoginEvent {}

class UpdateUserPreferences extends LoginEvent {
  final UserPreferences preferences;

  UpdateUserPreferences(this.preferences);
}

// States
abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final User user;

  LoginSuccess(this.user);
}

class LoginRequires2FA extends LoginState {
  final User user;
  final String tempToken;

  LoginRequires2FA({required this.user, required this.tempToken});
}

class LoginFailure extends LoginState {
  final String error;

  LoginFailure(this.error);
}

// BLoC
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginUseCase loginUseCase;
  final SecureStorageService secureStorage;
  final SessionService sessionService;

  LoginBloc({
    required this.loginUseCase,
    required this.secureStorage,
    required this.sessionService,
  }) : super(LoginInitial()) {
    on<LoginRequested>(_handleLoginRequested);
    on<CheckSession>(_handleCheckSession);
    on<LogoutRequested>(_handleLogoutRequested);
    on<UpdateUserPreferences>(_handleUpdateUserPreferences);
  }

  Future<void> _handleLoginRequested(
    LoginRequested event,
    Emitter<LoginState> emit,
  ) async {
    print('[2025-03-02 15:45:28] LoginBloc: 🔄 Processing LoginRequested event'
          '\n└─ Email: ${event.email}');
    
    emit(LoginLoading());

    try {
      final response = await loginUseCase.execute(
        email: event.email,
        password: event.password,
      );

      // If 2FA is required
      if (response.requiresTwoFactor && response.tempToken != null) {
        print('[2025-03-02 15:45:28] LoginBloc: 🔐 2FA required'
              '\n└─ Email: ${response.user.email}');
        
        emit(LoginRequires2FA(
          user: response.user,
          tempToken: response.tempToken!,
        ));
        return;
      }

      // Normal login flow with tokens
      if (response.accessToken != null && response.refreshToken != null) {
        // Save session data
        await sessionService.saveSession(
          user: response.user,
          accessToken: response.accessToken!,
          refreshToken: response.refreshToken!,
        );

        print('[2025-03-02 15:45:28] LoginBloc: ✅ Login successful'
              '\n└─ Email: ${response.user.email}'
              '\n└─ Role: ${response.user.role}');
        
        emit(LoginSuccess(response.user));
      } else {
        // This should not happen if API is working correctly
        emit(LoginFailure('Unexpected login response format.'));
      }
    } catch (e) {
      print('[2025-03-02 15:45:28] LoginBloc: ❌ Login error'
            '\n└─ Error: $e');
      
      emit(LoginFailure(e.toString()));
    }
  }

  Future<void> _handleCheckSession(
    CheckSession event,
    Emitter<LoginState> emit,
  ) async {
    print('[2025-03-02 15:45:28] LoginBloc: 🔄 Checking for existing session');
    
    emit(LoginLoading());

    try {
      final sessionData = await sessionService.getSession();

      if (sessionData != null) {
        print('[2025-03-02 15:45:28] LoginBloc: ✅ Session found'
              '\n└─ User: ${sessionData.user.username}'
              '\n└─ Email: ${sessionData.user.email}');
        
        emit(LoginSuccess(sessionData.user));
      } else {
        print('[2025-03-02 15:45:28] LoginBloc: ℹ️ No session found');
        
        emit(LoginInitial());
      }
    } catch (e) {
      print('[2025-03-02 15:45:28] LoginBloc: ❌ Error checking session'
            '\n└─ Error: $e');
      
      emit(LoginInitial());
    }
  }

  Future<void> _handleLogoutRequested(
    LogoutRequested event,
    Emitter<LoginState> emit,
  ) async {
    print('[2025-03-02 15:45:28] LoginBloc: 🔄 Processing logout request');
    
    emit(LoginLoading());

    try {
      await sessionService.clearSession();
      
      print('[2025-03-02 15:45:28] LoginBloc: ✅ Logout successful');
      
      emit(LoginInitial());
    } catch (e) {
      print('[2025-03-02 15:45:28] LoginBloc: ❌ Error during logout'
            '\n└─ Error: $e');
      
      // Even if there's an error, we still want to log the user out
      emit(LoginInitial());
    }
  }

  Future<void> _handleUpdateUserPreferences(
    UpdateUserPreferences event,
    Emitter<LoginState> emit,
  ) async {
    print('[2025-03-02 15:45:28] LoginBloc: 🔄 Updating user preferences');
    
    final currentState = state;
    if (currentState is LoginSuccess) {
      try {
        // Create a new User with updated preferences
        final updatedUser = currentState.user.copyWith(
          preferences: event.preferences,
        );
        
        // Update the user in the session
        final sessionData = await sessionService.getSession();
        if (sessionData != null) {
          await sessionService.saveSession(
            user: updatedUser,
            accessToken: sessionData.accessToken,
            refreshToken: sessionData.refreshToken,
          );
          
          print('[2025-03-02 15:45:28] LoginBloc: ✅ User preferences updated'
                '\n└─ User: ${updatedUser.username}');
          
          emit(LoginSuccess(updatedUser));
        }
      } catch (e) {
        print('[2025-03-02 15:45:28] LoginBloc: ❌ Error updating preferences'
              '\n└─ Error: $e');
        
        // Keep the current state if there's an error
        emit(currentState);
      }
    }
  }
}