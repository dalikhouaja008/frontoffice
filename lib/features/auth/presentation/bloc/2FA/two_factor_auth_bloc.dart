import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_boost/features/auth/data/repositories/two_factor_auth_repository.dart';
import 'two_factor_auth_event.dart';
import 'two_factor_auth_state.dart';

class TwoFactorAuthBloc extends Bloc<TwoFactorAuthEvent, TwoFactorAuthState> {
  final TwoFactorAuthRepository repository;

  TwoFactorAuthBloc({required this.repository}) : super(const TwoFactorAuthInitial()) {
    on<EnableTwoFactorAuthEvent>(_onEnableTwoFactorAuth);
    on<VerifyTwoFactorAuthEvent>(_onVerifyTwoFactorAuth);
    on<VerifyTwoFactorLoginEvent>(_onVerifyTwoFactorLogin);
  }

  Future<void> _onEnableTwoFactorAuth(
    EnableTwoFactorAuthEvent event,
    Emitter<TwoFactorAuthState> emit,
  ) async {
    emit(const TwoFactorAuthLoading());
    try {
      final qrCodeUrl = await repository.enableTwoFactorAuth();
      emit(TwoFactorAuthEnabled(qrCodeUrl));
    } catch (e) {
      emit(TwoFactorAuthError(e.toString()));
    }
  }

  Future<void> _onVerifyTwoFactorAuth(
    VerifyTwoFactorAuthEvent event,
    Emitter<TwoFactorAuthState> emit,
  ) async {
    emit(const TwoFactorAuthLoading());
    try {
      final isVerified = await repository.verifyTwoFactorAuth(event.code);
      if (isVerified) {
        emit(const TwoFactorAuthVerified());
      } else {
        emit(const TwoFactorAuthError('Invalid verification code'));
      }
    } catch (e) {
      emit(TwoFactorAuthError(e.toString()));
    }
  }

  Future<void> _onVerifyTwoFactorLogin(
    VerifyTwoFactorLoginEvent event,
    Emitter<TwoFactorAuthState> emit,
  ) async {
    emit(const TwoFactorAuthLoading());
    try {
      final loginData = await repository.verifyTwoFactorLogin(event.code);
      emit(TwoFactorAuthLoginSuccess(loginData));
    } catch (e) {
      emit(TwoFactorAuthError(e.toString()));
    }
  }
}