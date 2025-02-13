import 'package:equatable/equatable.dart';

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
  
  const TwoFactorAuthEnabled(this.qrCodeUrl);

  @override
  List<Object?> get props => [qrCodeUrl];
}

class TwoFactorAuthVerified extends TwoFactorAuthState {
  const TwoFactorAuthVerified();
}

class TwoFactorAuthLoginSuccess extends TwoFactorAuthState {
  final Map<String, dynamic> loginData;
  
  const TwoFactorAuthLoginSuccess(this.loginData);

  @override
  List<Object?> get props => [loginData];
}

class TwoFactorAuthError extends TwoFactorAuthState {
  final String message;
  
  const TwoFactorAuthError(this.message);

  @override
  List<Object?> get props => [message];
}