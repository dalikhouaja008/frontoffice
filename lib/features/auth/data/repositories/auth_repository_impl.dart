import 'package:dartz/dartz.dart';
import 'package:the_boost/features/auth/domain/entities/login_response.dart';
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
    print('AuthRepositoryImpl:🔐 Repository: Processing login'
          '\n└─ Email: $email');

    try {
      final response = await remoteDataSource.login(email, password);

      // Si les tokens sont null mais qu'on a un utilisateur, c'est un cas de 2FA
      if (response.accessToken == null) {
        print('AuthRepositoryImpl:🔐 2FA required'
              '\n└─ Email: ${response.user?.email}');

        return LoginResponse(
          user: response.user,
          requiresTwoFactor: true,
          tempToken: response.tempToken,
        );
      }

      // Cas normal : on a les tokens
      if (response.accessToken != null && response.refreshToken != null) {
        print('AuthRepositoryImpl: ✅ Login successful'
              '\n└─ Email: ${response.user?.email}');

        return response;
      }

      // Cas d'erreur : pas de tokens ni d'indication 2FA
      throw Exception('Login response invalide');
    } catch (e) {
      print('AuthRepositoryImpl:❌ Login error'
            '\n└─ Error: $e');
      rethrow;
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
