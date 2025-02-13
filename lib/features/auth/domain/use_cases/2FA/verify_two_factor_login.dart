import 'package:the_boost/features/auth/domain/repositories/two_factor_auth_repository.dart';

class VerifyTwoFactorLoginUseCase {
  final ITwoFactorAuthRepository repository;

  VerifyTwoFactorLoginUseCase(this.repository);

  Future<Map<String, dynamic>> call(String code) async {
    return await repository.verifyTwoFactorLogin(code);
  }
}