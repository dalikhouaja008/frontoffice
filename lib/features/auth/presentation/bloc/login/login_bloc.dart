// lib/features/auth/presentation/bloc/login/login_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:the_boost/features/auth/domain/entities/user.dart';
import 'dart:developer' as developer;

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
    on<RefreshAuthState>(_onRefreshAuthState);
    
    // Automatically check for existing session when bloc is created
    add(CheckSession());
  }

  Future<void> _onRefreshAuthState(
  RefreshAuthState event,
  Emitter<LoginState> emit,
) async {
  developer.log('LoginBloc: 🔄 Refreshing auth state for user: ${event.user.username}');
  
  // Réémettez l'état LoginSuccess pour forcer une mise à jour des widgets
  emit(LoginSuccess(user: event.user));
}

  Future<void> _onCheckSession(
    CheckSession event,
    Emitter<LoginState> emit,
  ) async {
    developer.log('LoginBloc: 🔍 Checking for existing session');
    emit(LoginLoading());
    
    try {
      final sessionData = await _sessionService.getSession();
      
      if (sessionData != null) {
        developer.log('LoginBloc: ✅ Found existing session'
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
        developer.log('LoginBloc: ℹ️ No existing session found');
        emit(LoginInitial());
      }
    } catch (e) {
      developer.log('LoginBloc: ❌ Error checking session'
            '\n└─ Error: $e');
      emit(LoginInitial());
    }
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<LoginState> emit,
  ) async {
    developer.log('LoginBloc: 🚀 Processing login request'
        '\n└─ Email: ${event.email}');

    try {
      emit(LoginLoading());

      final response = await _loginUseCase.execute(
        email: event.email,
        password: event.password,
      );

      // Debug log response
      developer.log('LoginBloc: 📥 Login response received'
          '\n└─ AccessToken: ${response.accessToken != null ? "Present" : "Missing"}'
          '\n└─ User: ${response.user?.username ?? "Missing"}');

      // Sauvegarder les tokens immédiatement après une connexion réussie
      if (!response.requiresTwoFactor && response.accessToken != null && response.refreshToken != null) {
        await _secureStorage.saveTokens(
          accessToken: response.accessToken!,
          refreshToken: response.refreshToken!,
        );
      }

      if (response.requiresTwoFactor) {
        emit(LoginRequires2FA(
          user: response.user!,
          tempToken: response.tempToken!,
        ));
      } else if (response.accessToken != null && response.refreshToken != null && response.user != null) {
        developer.log('LoginBloc: ✅ Login successful'
            '\n└─ User: ${response.user?.username}'
            '\n└─ Email: ${response.user?.email}');

        // Save session data
        await _sessionService.saveSession(
          user: response.user!,
          accessToken: response.accessToken!,
          refreshToken: response.refreshToken!,
        );

        // Important: Émettre l'état LoginSuccess en dernier pour permettre 
        // aux widgets d'observer le changement
        emit(LoginSuccess(user: response.user!));
      } else {
        throw Exception('Invalid login response: missing tokens or user data');
      }
    } catch (e) {
      developer.log('LoginBloc: ❌ Login failed'
            '\n└─ Error: $e');
      emit(LoginFailure(e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<LoginState> emit,
  ) async {
    developer.log('LoginBloc: 🔄 Logout initiated');
    
    // Clear secure storage
    await _secureStorage.deleteTokens();
    
    // Clear session
    await _sessionService.clearSession();
    
    emit(LoginInitial());
    developer.log('LoginBloc: ✅ Logout successful');
  }
}