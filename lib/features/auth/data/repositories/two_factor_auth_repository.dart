import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:the_boost/features/auth/data/datasources/auth_remote_data_source.dart';
import '../models/2FA/two_factor_auth_model.dart';

abstract class TwoFactorAuthRepository {
  Future<String> enableTwoFactorAuth();
  //Future<bool> verifyTwoFactorAuth(String code);
  //Future<Map<String, dynamic>> verifyTwoFactorLogin(String code);
}

class TwoFactorAuthRepositoryImpl implements TwoFactorAuthRepository {
 final AuthRemoteDataSource _remoteDataSource;

 TwoFactorAuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<String> enableTwoFactorAuth() async {
    print('[2025-02-13 22:55:59] 🏭 Repository: enableTwoFactorAuth called'
          '\n└─ User: raednas');
    
    try {
      final result = await _remoteDataSource.enableTwoFactorAuth();
      print('[2025-02-13 22:55:59] ✅ Repository: enableTwoFactorAuth successful'
            '\n└─ User: raednas');
      return result;
    } catch (e) {
      print('[2025-02-13 22:55:59] ❌ Repository: enableTwoFactorAuth failed'
            '\n└─ Error: $e'
            '\n└─ User: raednas');
      rethrow;
    }
  }
 /* @override
  Future<bool> verifyTwoFactorAuth(String code) async {
    final result = await client.mutate(
      MutationOptions(
        document: gql('''
          mutation VerifyTwoFactorAuth(\$token: String!) {
            verifyTwoFactorAuth(token: \$token)
          }
        '''),
        variables: {'token': code},
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception?.graphqlErrors.first.message);
    }

    return result.data?['verifyTwoFactorAuth'];
  }

  @override
  Future<Map<String, dynamic>> verifyTwoFactorLogin(String code) async {
    final result = await client.mutate(
      MutationOptions(
        document: gql('''
          mutation VerifyTwoFactorLogin(\$token: String!) {
            verifyTwoFactorLogin(token: \$token) {
              accessToken
              refreshToken
              user {
                id
                username
                email
                isTwoFactorEnabled
              }
            }
          }
        '''),
        variables: {'token': code},
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception?.graphqlErrors.first.message);
    }

    return result.data?['verifyTwoFactorLogin'];
  }*/
}