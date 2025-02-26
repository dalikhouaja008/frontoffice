import 'package:the_boost/features/auth/domain/entities/login_response.dart';

abstract class ITwoFactorAuthRepository {
  Future<String> enableTwoFactorAuth();
  Future<bool> verifyTwoFactorAuth(String code);
  Future<LoginResponse> verifyTwoFactorLogin(String code);
}