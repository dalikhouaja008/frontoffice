import 'package:graphql_flutter/graphql_flutter.dart';
import '../models/2FA/two_factor_auth_model.dart';

abstract class TwoFactorAuthRepository {
  Future<String> enableTwoFactorAuth();
  Future<bool> verifyTwoFactorAuth(String code);
  Future<Map<String, dynamic>> verifyTwoFactorLogin(String code);
}

class TwoFactorAuthRepositoryImpl implements TwoFactorAuthRepository {
  final GraphQLClient client;

  TwoFactorAuthRepositoryImpl({required this.client});

  @override
  Future<String> enableTwoFactorAuth() async {
    final result = await client.mutate(
      MutationOptions(
        document: gql('''
          mutation EnableTwoFactorAuth {
            enableTwoFactorAuth
          }
        '''),
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception?.graphqlErrors.first.message);
    }

    return result.data?['enableTwoFactorAuth'];
  }

  @override
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
  }
}