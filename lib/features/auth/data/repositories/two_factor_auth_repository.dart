import 'package:the_boost/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:the_boost/features/auth/domain/entities/login_response.dart';

abstract class TwoFactorAuthRepository {
  Future<String> enableTwoFactorAuth();
  Future<bool> verifyTwoFactorAuth(String code);
  Future<LoginResponse> verifyLoginOtp(
    String tempToken,
    String otpCode,
  );
}

class TwoFactorAuthRepositoryImpl implements TwoFactorAuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
    final _timeoutDuration = const Duration(seconds: 30);

  TwoFactorAuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<String> enableTwoFactorAuth() async {
    print('🏭 TwoFactorAuthRepositoryImpl: enableTwoFactorAuth called');

    try {
      final result = await _remoteDataSource.enableTwoFactorAuth();
      print('✅ TwoFactorAuthRepositoryImpl: enableTwoFactorAuth successful');
      return result;
    } catch (e) {
      print('❌ TwoFactorAuthRepositoryImpl: enableTwoFactorAuth failed'
          '\n└─ Error: $e');
      rethrow;
    }
  }

  @override
  Future<bool> verifyTwoFactorAuth(String code) async {
    print(
        'TwoFactorAuthRepositoryImpl: 🔐 Repository: verifyTwoFactorAuth called'
        '\n└─ Code length: ${code.length}');

    try {
      final result = await _remoteDataSource.verifyTwoFactorAuth(code);
      print(
          'TwoFactorAuthRepositoryImpl: ✅ Repository: verifyTwoFactorAuth successful'
          '\n└─ Result: $result');
      return result;
    } catch (e) {
      print(
          'TwoFactorAuthRepositoryImpl:❌ Repository: verifyTwoFactorAuth failed'
          '\n└─ Error: $e');
      rethrow;
    }
  }

  @override
 Future<LoginResponse> verifyLoginOtp(String tempToken, String otpCode)  async {
    print('[2025-02-15 13:32:49] 🔐 Repository: Verifying login OTP'
        '\n└─ User: raednas');

    try {
      print('[2025-02-15 13:32:49] ✅ Repository: OTP verification loading');
      return await _remoteDataSource.verifyLoginOtp(
        tempToken,
        otpCode,
      ) .timeout(
            _timeoutDuration,
            onTimeout: () => throw Exception(
              'La vérification a pris trop de temps. Veuillez réessayer.',
            ),
          );
      
    } catch (e) {
      print('[2025-02-15 13:32:49] ❌ Repository: OTP verification failed'
          '\n└─ Error: $e');
      rethrow;
    }
  }
}
