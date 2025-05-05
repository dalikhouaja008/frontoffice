// lib/features/auth/presentation/bloc/login/login_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:the_boost/features/auth/domain/entities/user.dart';
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

        // Emit logged in state
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
        print('LoginBloc: 🔐 2FA required'
            '\n└─ Email: ${response.user.email}');

        emit(LoginRequires2FA(
          user: response.user,
          tempToken: response.tempToken!,
        ));
        return;
      }

      if (response.accessToken != null && response.refreshToken != null) {
        print('LoginBloc: ✅ Login successful'
            '\n└─ Email: ${response.user.email}');

        // Save tokens to secure storage
        await _secureStorage.saveTokens(
          accessToken: response.accessToken!,
          refreshToken: response.refreshToken!,
        );

        // Save session data
        await _sessionService.saveSession(
          user: response.user,
          accessToken: response.accessToken!,
          refreshToken: response.refreshToken!,
        );

        emit(LoginSuccess(user: response.user));
      } else {
        throw Exception('Invalid login response: missing tokens');
      }
    } catch (e) {
      print('LoginBloc: ❌ Login failed'
          '\n└─ Error: $e');

      emit(LoginFailure(e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<LoginState> emit,
  ) async {
    print('LoginBloc: 🔄 Logout initiated');

    // Clear secure storage
    await _secureStorage.deleteTokens();

    // Clear session
    await _sessionService.clearSession();

    emit(LoginInitial());
    print('LoginBloc: ✅ Logout successful');
  }

  Future<void> _onSet2FASuccess(
    Set2FASuccessEvent event,
    Emitter<LoginState> emit,
  ) async {
    print('[2025-05-05 00:17:01] LoginBloc: 🔄 Processing 2FA success event'
          '\n└─ User: nesssim'
          '\n└─ Email: ${event.user.email}');
    
    emit(LoginLoading());
    
    try {
      // Sauvegarder les tokens dans le stockage sécurisé
      await _secureStorage.saveTokens(
        accessToken: event.accessToken,
        refreshToken: event.refreshToken,
      );
      
      // Sauvegarder la session
      await _sessionService.saveSession(
        user: event.user,
        accessToken: event.accessToken,
        refreshToken: event.refreshToken,
      );
      
      // Émettre l'état connecté
      emit(LoginSuccess(user: event.user));
      
      print('[2025-05-05 00:17:01] LoginBloc: ✅ 2FA state synchronization completed'
            '\n└─ User: nesssim'
            '\n└─ Email: ${event.user.email}');
    } catch (e) {
      print('[2025-05-05 00:17:01] LoginBloc: ❌ Error processing 2FA success'
            '\n└─ User: nesssim'
            '\n└─ Error: $e');
      
      // En cas d'erreur, on reste dans l'état courant
      emit(LoginFailure('Erreur lors de la synchronisation après 2FA: $e'));
    }
  }
}
