import 'package:the_boost/features/auth/domain/entities/login_response.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase({required this.repository});

  Future<LoginResponse> execute({
    required String email,
    required String password,
  }) async {
    return await this.repository.login(email: email, password: password);
  }
}

// Classe pour encapsuler le résultat du login
class LoginResult {
  final User user;
  final String accessToken;
  final String refreshToken;

  LoginResult({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });
}