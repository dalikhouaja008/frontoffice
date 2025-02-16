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
  print('TwoFactorAuthBloc:🚀 TwoFactorAuthBloc: EnableTwoFactorAuthEvent received');

  emit(const TwoFactorAuthLoading());

  try {
    print('TwoFactorAuthBloc: 📡 TwoFactorAuthBloc: Calling repository.enableTwoFactorAuth');
          
    final qrCodeUrl = await repository.enableTwoFactorAuth();
    
    print('TwoFactorAuthBloc: ✅ TwoFactorAuthBloc: QR Code received');
          
    emit(TwoFactorAuthEnabled(qrCodeUrl));
  } catch (e) {
    print('TwoFactorAuthBloc: ❌ TwoFactorAuthBloc: Error caught'
          '\n└─ Error: $e');

     emit(const TwoFactorAuthError('Code de vérification invalide'));
  }
}

 Future<void> _onVerifyTwoFactorAuth(
    VerifyTwoFactorAuthEvent event,
    Emitter<TwoFactorAuthState> emit,
  ) async {
    print('TwoFactorAuthBloc: 🔐 Processing Verify 2FA request'
          '\n└─ Code length: ${event.code.length}');

    emit(const TwoFactorAuthLoading());

    try {
      print('TwoFactorAuthBloc:📡 Calling repository to verify 2FA code');
      final isVerified = await repository.verifyTwoFactorAuth(event.code);
      
      if (isVerified) {
        print('TwoFactorAuthBloc: ✅ 2FA verification successful');
        emit(const TwoFactorAuthVerified());
      } else {
        print('TwoFactorAuthBloc:⚠️ Invalid verification code');
        emit(const TwoFactorAuthError( 'Code de vérification invalide'));
      }
    } catch (e) {
      print('TwoFactorAuthBloc:❌ Failed to verify 2FA code'
            '\n└─ Error: $e');
      
      final errorMessage = _formatErrorMessage(e);
      emit(TwoFactorAuthError(errorMessage));
    }
  }

 Future<void> _onVerifyTwoFactorLogin(
    VerifyTwoFactorLoginEvent event,
    Emitter<TwoFactorAuthState> emit,
  ) async {
    print('[2025-02-15 14:44:51] 🔐 Processing 2FA login verification'
          '\n└─ User: raednas');

    if (!event.code.isValidOtpCode) {
      emit(const TwoFactorAuthError(
         'Code OTP invalide',

      ));
      return;
    }

    emit(const TwoFactorAuthLoading());

    try {
      final response = await repository.verifyLoginOtp(
        event.tempToken,
        event.code,
      );

      emit(TwoFactorAuthLoginSuccess(
        user: response.user,
        accessToken: response.accessToken!,
        refreshToken: response.refreshToken!,
      ));
    } catch (e) {
      emit(TwoFactorAuthError(e.toString(),));
    }
  }

  String _formatErrorMessage(dynamic error) {
    if (error.toString().contains('token')) {
      return 'Session expirée. Veuillez vous reconnecter.';
    } else if (error.toString().contains('network')) {
      return 'Erreur de connexion. Vérifiez votre connexion internet.';
    } else if (error.toString().contains('invalid')) {
      return 'Code invalide. Veuillez réessayer.';
    }
    return 'Une erreur est survenue. Veuillez réessayer.';
  }
}