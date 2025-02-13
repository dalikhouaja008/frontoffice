import 'package:dartz/dartz.dart';
import 'package:the_boost/features/auth/domain/entities/login_response.dart';
import 'package:the_boost/features/auth/domain/use_cases/login_use_case.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await remoteDataSource.login( email,  password);
      return response;
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }

  @override
  Future<Either<String, User>> signUp(String username, String email, String password, String role, String? publicKey) async {
    try {
      final user = await remoteDataSource.signUp(username, email, password, role, publicKey);
      return Right(user);
    } catch (e) {
      return Left(e.toString());
    }
  }



}
