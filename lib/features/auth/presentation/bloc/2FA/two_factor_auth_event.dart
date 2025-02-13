import 'package:equatable/equatable.dart';

abstract class TwoFactorAuthEvent extends Equatable {
  const TwoFactorAuthEvent();

  @override
  List<Object?> get props => [];
}

class EnableTwoFactorAuthEvent extends TwoFactorAuthEvent {
  const EnableTwoFactorAuthEvent();
}

class VerifyTwoFactorAuthEvent extends TwoFactorAuthEvent {
  final String code;
  
  const VerifyTwoFactorAuthEvent(this.code);

  @override
  List<Object?> get props => [code];
}

class VerifyTwoFactorLoginEvent extends TwoFactorAuthEvent {
  final String code;
  
  const VerifyTwoFactorLoginEvent(this.code);

  @override
  List<Object?> get props => [code];
}