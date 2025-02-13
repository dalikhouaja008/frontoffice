import 'package:dartz/dartz.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<String, User>> login(String email, String password);
  Future<Either<String, User>> signUp(String username, String email, String password, String role, String? publicKey);
}
