import 'package:dartz/dartz.dart';
import 'package:the_boost/features/auth/data/models/TwoFactorResponse_model.dart';
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

  @override
  Future<Either<String, void>> changePassword(String oldPassword, String newPassword) {
    // TODO: implement changePassword
    throw UnimplementedError();
  }

  @override
  Future<Either<String, bool>> checkEmailExists(String email) {
    // TODO: implement checkEmailExists
    throw UnimplementedError();
  }

  @override
  Future<Either<String, bool>> checkUsernameExists(String username) {
    // TODO: implement checkUsernameExists
    throw UnimplementedError();
  }

  @override
  Future<Either<String, void>> disableTwoFactorAuth(String token) {
    // TODO: implement disableTwoFactorAuth
    throw UnimplementedError();
  }



  @override
  Future<Either<String, void>> forgotPassword(String email) {
    // TODO: implement forgotPassword
    throw UnimplementedError();
  }

  @override
  Future<Either<String, User>> getCurrentUser() {
    // TODO: implement getCurrentUser
    throw UnimplementedError();
  }

  @override
  Future<Either<String, void>> logout() {
    // TODO: implement logout
    throw UnimplementedError();
  }

  @override
  Future<Either<String, String>> refreshToken(String refreshToken) {
    // TODO: implement refreshToken
    throw UnimplementedError();
  }

  @override
  Future<Either<String, void>> resetPassword(String token, String newPassword) {
    // TODO: implement resetPassword
    throw UnimplementedError();
  }

  @override
  Future<Either<String, User>> updateProfile({String? username, String? email, String? publicKey}) {
    // TODO: implement updateProfile
    throw UnimplementedError();
  }



  @override
  Future<Either<String, void>> verifyEmail(String token) {
    // TODO: implement verifyEmail
    throw UnimplementedError();
  }



//Partie 2FA
  @override
  Future<Either<String, TwoFactorResponseModel>> verifyTwoFactorLogin(String userId, String token) async {
    try {
      final response = await remoteDataSource.verifyTwoFactorLogin(userId, token);
      return Right(response);
    } catch (e) {
      return Left(e.toString());
    }
  }
    @override
  Future<Either<String, bool>> verifyAndEnableTwoFactorAuth(String token) async {
    try {
      final result = await remoteDataSource.verifyAndEnableTwoFactorAuth(token);
      return Right(result);
    } catch (e) {
      return Left(e.toString());
    }
  }
    @override
  Future<Either<String, String>> enableTwoFactorAuth() async {
    try {
      final qrCodeUrl = await remoteDataSource.enableTwoFactorAuth();
      return Right(qrCodeUrl);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
