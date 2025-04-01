import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:the_boost/features/auth/domain/use_cases/login_use_case.dart';
import 'package:the_boost/features/auth/presentation/bloc/login/login_state.dart';
import 'package:the_boost/core/services/secure_storage_service.dart';
import 'package:the_boost/core/services/session_service.dart';

part 'login_event.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginUseCase _loginUseCase;
  final SecureStorageService _secureStorage;
  final SessionService _sessionService;

  LoginBloc({
    required LoginUseCase loginUseCase,
    required SecureStorageService secureStorage,
    required SessionService sessionService,
  })  : _loginUseCase = loginUseCase,
        _secureStorage = secureStorage,
        _sessionService = sessionService,
        super(LoginInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckSession>(_onCheckSession);

    // Automatically check for existing session when bloc is created
    add(CheckSession());
  }

  Future<void> _onCheckSession(
    CheckSession event,
    Emitter<LoginState> emit,
  ) async {
    print('LoginBloc: 🔍 Checking for existing session');
    emit(LoginLoading());

    try {
      final sessionData = await _sessionService.getSession();

      if (sessionData != null) {
        print('LoginBloc: ✅ Found existing session'
            '\n└─ User: ${sessionData.user.username}'
            '\n└─ Email: ${sessionData.user.email}');

        // Restore tokens to secure storage
        await _secureStorage.saveTokens(
          accessToken: sessionData.accessToken,
          refreshToken: sessionData.refreshToken,
        );

        // Emit logged-in state
        emit(LoginSuccess(user: sessionData.user));
      } else {
        print('LoginBloc: ℹ️ No existing session found');
        emit(LoginInitial());
      }
    } catch (e) {
      print('LoginBloc: ❌ Error checking session'
          '\n└─ Error: $e');
      emit(LoginInitial());
    }
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<LoginState> emit,
  ) async {
    print('LoginBloc: 🚀 Processing login request'
        '\n└─ Email: ${event.email}');

    try {
      emit(LoginLoading());

      final response = await _loginUseCase.execute(
        email: event.email,
        password: event.password,
      );

      if (response.requiresTwoFactor) {
        emit(LoginRequires2FA(
          user: response.user!,
          tempToken: response.tempToken!,
        ));
      } else {
        if (response.accessToken != null && response.refreshToken != null) {
          print('[${DateTime.now()}] LoginBloc: ✅ Login successful'
              '\n└─ User: ${response.user?.username}'
              '\n└─ Email: ${response.user?.email}');

          // Save tokens to secure storage
          await _secureStorage.saveTokens(
            accessToken: response.accessToken!,
            refreshToken: response.refreshToken!,
          );

          // Save session data
          await _sessionService.saveSession(
            user: response.user!,
            accessToken: response.accessToken!,
            refreshToken: response.refreshToken!,
          );

          emit(LoginSuccess(user: response.user!));
        } else {
          throw Exception('Invalid login response: missing tokens');
        }
      }
    } catch (e) {
      print('[${DateTime.now()}] LoginBloc: ❌ Login failed'
          '\n└─ Error: $e');

      emit(LoginFailure(e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<LoginState> emit,
  ) async {
    print('LoginBloc: 🔄 Logout initiated');

    try {
      // Clear secure storage
      await _secureStorage.deleteTokens();

      // Clear session
      await _sessionService.clearSession();

      emit(LoginInitial());
      print('LoginBloc: ✅ Logout successful');
    } catch (e) {
      print('LoginBloc: ❌ Error during logout'
          '\n└─ Error: $e');

      emit(LoginFailure(e.toString()));
    }
  }
}