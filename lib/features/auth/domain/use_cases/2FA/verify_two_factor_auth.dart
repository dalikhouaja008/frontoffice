
import 'package:the_boost/features/auth/domain/repositories/two_factor_auth_repository.dart';

class VerifyTwoFactorAuthUseCase {
  final ITwoFactorAuthRepository repository;

  VerifyTwoFactorAuthUseCase(this.repository);

  Future<bool> call(String code) async {
    return await repository.verifyTwoFactorAuth(code);
  }
}