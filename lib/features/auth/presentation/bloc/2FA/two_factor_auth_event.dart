import 'package:equatable/equatable.dart';

abstract class TwoFactorAuthEvent extends Equatable {
  const TwoFactorAuthEvent();

  @override
  List<Object?> get props => [];
}

class EnableTwoFactorAuthEvent extends TwoFactorAuthEvent {
   EnableTwoFactorAuthEvent(){
     print('TwoFactorAuthEvent: 🔐 Enabling 2FA');
   }
}

class VerifyTwoFactorAuthEvent extends TwoFactorAuthEvent {
  final String code;
  
   VerifyTwoFactorAuthEvent(this.code) {
    assert(
      code.length == 6 && int.tryParse(code) != null,
      'Le code doit être composé de 6 chiffres',
    );

    print('TwoFactorAuthEvent:🔑 Verifying 2FA setup'
          '\n└─ Code length: ${code.length}');
  }

  @override
  List<Object?> get props => [code];
}

class VerifyTwoFactorLoginEvent extends TwoFactorAuthEvent {
  final String code;
  final String tempToken;

  VerifyTwoFactorLoginEvent({
    required this.code,
    required this.tempToken,
  }) {
    assert(
      code.length == 6 && int.tryParse(code) != null,
      'Le code doit être composé de 6 chiffres',
    );
    assert(
      tempToken.isNotEmpty,
      'Le token temporaire ne peut pas être vide',
    );

    print('TwoFactorAuthEvent: 🔑 Verifying 2FA login'
        '\n└─ Code length: ${code.length}'
        '\n└─ Has temp token: ${tempToken.isNotEmpty}');
  }

  @override
  List<Object?> get props => [code, tempToken];
}

class CancelTwoFactorAuthEvent extends TwoFactorAuthEvent {
   CancelTwoFactorAuthEvent() {
    print('TwoFactorAuthEvent: 🚫 Cancelling 2FA operation');
  }
}

class ResendTwoFactorCodeEvent extends TwoFactorAuthEvent {
  final String? email;
  
   ResendTwoFactorCodeEvent({this.email}) {
    print('TwoFactorAuthEvent:🔄 Resending 2FA code'
          '\n└─ Email: ${email ?? 'Not provided'}');
  }

  @override
  List<Object?> get props => [email];
}

// Extension utilitaire pour la validation
extension TwoFactorAuthEventValidation on String {
  bool get isValidOtpCode {
    return length == 6 && int.tryParse(this) != null;
  }
}