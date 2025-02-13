import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_boost/features/auth/data/repositories/two_factor_auth_repository.dart';
import 'two_factor_auth_event.dart';
import 'two_factor_auth_state.dart';

class TwoFactorAuthBloc extends Bloc<TwoFactorAuthEvent, TwoFactorAuthState> {
  final TwoFactorAuthRepository repository;

  TwoFactorAuthBloc({required this.repository}) : super(const TwoFactorAuthInitial()) {
    on<EnableTwoFactorAuthEvent>(_onEnableTwoFactorAuth);
   // on<VerifyTwoFactorAuthEvent>(_onVerifyTwoFactorAuth);
    //on<VerifyTwoFactorLoginEvent>(_onVerifyTwoFactorLogin);
  }

Future<void> _onEnableTwoFactorAuth(
  EnableTwoFactorAuthEvent event,
  Emitter<TwoFactorAuthState> emit,
) async {
  final timestamp = '2025-02-13 22:55:59';
  print('[$timestamp] 🚀 TwoFactorAuthBloc: EnableTwoFactorAuthEvent received'
        '\n└─ User: raednas');

  emit(const TwoFactorAuthLoading());

  try {
    print('[$timestamp] 📡 TwoFactorAuthBloc: Calling repository.enableTwoFactorAuth'
          '\n└─ User: raednas');
          
    final qrCodeUrl = await repository.enableTwoFactorAuth();
    
    print('[$timestamp] ✅ TwoFactorAuthBloc: QR Code received'
          '\n└─ User: raednas');
          
    emit(TwoFactorAuthEnabled(qrCodeUrl));
  } catch (e) {
    print('[$timestamp] ❌ TwoFactorAuthBloc: Error caught'
          '\n└─ Error: $e'
          '\n└─ User: raednas');
    emit(TwoFactorAuthError(e.toString()));
  }
}

/*  Future<void> _onVerifyTwoFactorAuth(
    VerifyTwoFactorAuthEvent event,
    Emitter<TwoFactorAuthState> emit,
  ) async {
    final timestamp = '2025-02-13 22:24:48';
    print('[$timestamp] 🔐 Processing Verify 2FA request'
          '\n└─ User: raednas'
          '\n└─ Code length: ${event.code.length}');

    emit(const TwoFactorAuthLoading());

    try {
      print('[$timestamp] 📡 Calling repository to verify 2FA code');
      final isVerified = await repository.verifyTwoFactorAuth(event.code);
      
      if (isVerified) {
        print('[$timestamp] ✅ 2FA verification successful'
              '\n└─ User: raednas');
        emit(const TwoFactorAuthVerified());
      } else {
        print('[$timestamp] ⚠️ Invalid verification code'
              '\n└─ User: raednas');
        emit(const TwoFactorAuthError('Code de vérification invalide'));
      }
    } catch (e) {
      print('[$timestamp] ❌ Failed to verify 2FA code'
            '\n└─ Error: $e'
            '\n└─ User: raednas');
      
      final errorMessage = _formatErrorMessage(e);
      emit(TwoFactorAuthError(errorMessage));
    }
  }

  Future<void> _onVerifyTwoFactorLogin(
    VerifyTwoFactorLoginEvent event,
    Emitter<TwoFactorAuthState> emit,
  ) async {
    final timestamp = '2025-02-13 22:24:48';
    print('[$timestamp] 🔐 Processing 2FA Login verification'
          '\n└─ User: raednas'
          '\n└─ Code length: ${event.code.length}');

    emit(const TwoFactorAuthLoading());

    try {
      print('[$timestamp] 📡 Calling repository to verify 2FA login');
      final loginData = await repository.verifyTwoFactorLogin(event.code);
      
      print('[$timestamp] ✅ 2FA login successful'
            '\n└─ User: raednas');
      
      emit(TwoFactorAuthLoginSuccess(loginData));
    } catch (e) {
      print('[$timestamp] ❌ Failed to verify 2FA login'
            '\n└─ Error: $e'
            '\n└─ User: raednas');
      
      final errorMessage = _formatErrorMessage(e);
      emit(TwoFactorAuthError(errorMessage));
    }
  }*/

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