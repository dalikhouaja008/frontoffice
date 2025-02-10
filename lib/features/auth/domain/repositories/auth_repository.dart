import 'package:dartz/dartz.dart';
import 'package:the_boost/features/auth/data/models/TwoFactorResponse_model.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<String, User>> login(String email, String password);
  Future<Either<String, User>> signUp(String username, String email, String password, String role, String? publicKey);

    // Méthodes de gestion du token
  Future<Either<String, String>> refreshToken(String refreshToken);
  Future<Either<String, void>> logout();
  
  // Méthodes de récupération/modification du mot de passe
  Future<Either<String, void>> forgotPassword(String email);
  Future<Either<String, void>> resetPassword(String token, String newPassword);
  Future<Either<String, void>> changePassword(String oldPassword, String newPassword);
  
  // Méthodes de gestion 2FA
  Future<Either<String, String>> enableTwoFactorAuth();
  Future<Either<String, bool>> verifyAndEnableTwoFactorAuth(String token);
  Future<Either<String, TwoFactorResponseModel>> verifyTwoFactorLogin(String userId, String token);
  Future<Either<String, void>> disableTwoFactorAuth(String token);
  
  // Méthodes de gestion du profil
  Future<Either<String, User>> getCurrentUser();
  Future<Either<String, User>> updateProfile({
    String? username,
    String? email,
    String? publicKey,
  });
  
  // Méthodes de vérification
  Future<Either<String, void>> verifyEmail(String token);
  Future<Either<String, bool>> checkEmailExists(String email);
  Future<Either<String, bool>> checkUsernameExists(String username);
  
}
