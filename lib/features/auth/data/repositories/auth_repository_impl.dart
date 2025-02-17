import 'package:dartz/dartz.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<String, User>> login(String email, String password) async {
    try {
      final user = await remoteDataSource.login(email, password);
      return Right(user);
    } catch (e) {
      return Left(e.toString());
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