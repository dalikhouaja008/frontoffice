
import 'package:the_boost/features/auth/domain/repositories/two_factor_auth_repository.dart';

class EnableTwoFactorAuthUseCase {
  final ITwoFactorAuthRepository repository;

  EnableTwoFactorAuthUseCase(this.repository);

  Future<String> call() async {
    return await repository.enableTwoFactorAuth();
  }
}