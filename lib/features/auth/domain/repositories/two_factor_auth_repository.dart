abstract class ITwoFactorAuthRepository {
  Future<String> enableTwoFactorAuth();
  Future<bool> verifyTwoFactorAuth(String code);
  Future<Map<String, dynamic>> verifyTwoFactorLogin(String code);
}