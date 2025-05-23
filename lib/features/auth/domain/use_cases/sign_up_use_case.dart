import 'package:dartz/dartz.dart';
import '../entities/grpd_consent.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  Future<Either<String, User>> call(String username, String email, String password, String role, String? publicKey,GDPRConsent gdprConsent) {
    return repository.signUp(username, email, password, role, publicKey, gdprConsent);
  }
}

