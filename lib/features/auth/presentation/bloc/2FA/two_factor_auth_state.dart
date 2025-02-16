import 'package:equatable/equatable.dart';
import 'package:the_boost/features/auth/domain/entities/user.dart';

abstract class TwoFactorAuthState extends Equatable {
  const TwoFactorAuthState();

  @override
  List<Object?> get props => [];
}

class TwoFactorAuthInitial extends TwoFactorAuthState {
  const TwoFactorAuthInitial();
}

class TwoFactorAuthLoading extends TwoFactorAuthState {
  const TwoFactorAuthLoading();
}

class TwoFactorAuthEnabled extends TwoFactorAuthState {
  final String qrCodeUrl;
  const TwoFactorAuthEnabled(this.qrCodeUrl) ;
  @override
  List<Object?> get props => [qrCodeUrl];
}

class TwoFactorAuthVerified extends TwoFactorAuthState {
  const TwoFactorAuthVerified();
}

class TwoFactorAuthLoginSuccess extends TwoFactorAuthState {
  final User user;
  final String accessToken;
  final String refreshToken;
  
  const TwoFactorAuthLoginSuccess({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  }) ;

  @override
  List<Object?> get props => [user, accessToken, refreshToken];
}

class TwoFactorAuthOtpRequired extends TwoFactorAuthState {
  final String tempToken;
  final User user;

  const TwoFactorAuthOtpRequired({
    required this.tempToken,
    required this.user,
  }) ;

  @override
  List<Object?> get props => [tempToken, user];
}

class TwoFactorAuthError extends TwoFactorAuthState {
  final String message;
  
  const TwoFactorAuthError(this.message);

  @override
  List<Object?> get props => [message];
}

