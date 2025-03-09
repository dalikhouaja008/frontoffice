import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:the_boost/features/auth/domain/use_cases/login_use_case.dart';
import 'package:the_boost/features/auth/presentation/bloc/login/login_state.dart';

import '../../../../../core/services/secure_storage_service.dart';

part 'login_event.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginUseCase _loginUseCase;
  final SecureStorageService _secureStorage;

  LoginBloc({
    required LoginUseCase loginUseCase,
    required SecureStorageService secureStorage,
  })  : _loginUseCase = loginUseCase,
        _secureStorage = secureStorage,
        super(LoginInitial()) {

    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);

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

      // Sauvegarder les tokens immédiatement après une connexion réussie
      if (!response.requiresTwoFactor) {
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
      } else {
        print('[${DateTime.now()}] LoginBloc: ✅ Login successful'
            '\n└─ User: ${response.user?.username}'
            '\n└─ Email: ${response.user?.email}');

        emit(LoginSuccess(user: response.user!));
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
    await _secureStorage.deleteTokens();
    emit(LoginInitial());
    print('LoginBloc: ✅ Logout successful');
  }


}
