import 'package:the_boost/features/auth/domain/entities/user.dart';
import 'package:the_boost/features/auth/presentation/bloc/2FA/two_factor_auth_state.dart';

enum ErrorType {
  invalidCode,
  networkError,
  serverError,
  unauthorized,
  unknown;

  String get userMessage {
    switch (this) {
      case ErrorType.invalidCode:
        return 'Code invalide. Veuillez réessayer.';
      case ErrorType.networkError:
        return 'Erreur de connexion. Vérifiez votre connexion internet.';
      case ErrorType.serverError:
        return 'Erreur serveur. Veuillez réessayer plus tard.';
      case ErrorType.unauthorized:
        return 'Session expirée. Veuillez vous reconnecter.';
      case ErrorType.unknown:
        return 'Une erreur est survenue. Veuillez réessayer.';
    }
  }
}

// Extensions utiles pour la conversion des états
extension TwoFactorAuthStateX on TwoFactorAuthState {
  bool get isLoading => this is TwoFactorAuthLoading;
  bool get isError => this is TwoFactorAuthError;
  bool get isSuccess => this is TwoFactorAuthLoginSuccess;
  bool get needsOtp => this is TwoFactorAuthOtpRequired;
  
  String? get errorMessage => this is TwoFactorAuthError 
      ? (this as TwoFactorAuthError).message 
      : null;
      
  User? get user => this is TwoFactorAuthLoginSuccess 
      ? (this as TwoFactorAuthLoginSuccess).user 
      : this is TwoFactorAuthOtpRequired 
          ? (this as TwoFactorAuthOtpRequired).user 
          : null;
}