import 'package:dartz/dartz.dart';
import 'package:the_boost/features/auth/domain/entities/login_response.dart';
import 'package:the_boost/features/auth/domain/use_cases/login_use_case.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<LoginResponse> login({
    required String email,
    required String password,
  });
  Future<Either<String, User>> signUp(String username, String email,
      String password, String role, String? publicKey);
}
