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
    print('[${DateTime.now().toIso8601String()}] ⏳ Login attempt initiated'
          '\n└─ Email: ${event.email}');
    
    emit(LoginLoading());
    
    try {
      final response = await _loginUseCase.execute(
        email: event.email,
        password: event.password,
      );

      if (response.requiresTwoFactor) {
        print('[${DateTime.now().toIso8601String()}] 🔐 2FA Required'
              '\n└─ Email: ${event.email}');
        
        emit(LoginRequires2FA(
          tempToken: response.tempToken!,
          user: response.user,
        ));
        return;
      }

      if (response.accessToken != null && response.refreshToken != null) {
        await _secureStorage.saveTokens(
          accessToken: response.accessToken!,
          refreshToken: response.refreshToken!,
        );
        print('[${DateTime.now().toIso8601String()}] 🔑 Tokens saved successfully'
              '\n└─ User: ${response.accessToken}');
      }

      emit(LoginSuccess(
        user: response.user,
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        requiresTwoFactor: false,
        tempToken: null,
      ));
      
      print('[${DateTime.now().toIso8601String()}] ✅ Login successful'
            '\n└─ User: ${response.user.email}');

    } catch (e) {
      print('[${DateTime.now().toIso8601String()}] ❌ Login failed'
            '\n└─ Error: ${e.toString()}'
            '\n└─ Email: ${event.email}');
      emit(LoginFailure(e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<LoginState> emit,
  ) async {
    print('[${DateTime.now().toIso8601String()}] 🔄 Logout initiated');
    await _secureStorage.deleteTokens();
    emit(LoginInitial());
    print('[${DateTime.now().toIso8601String()}] ✅ Logout successful');
  }
}
