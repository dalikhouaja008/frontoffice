import 'package:graphql_flutter/graphql_flutter.dart';
import '../../../../core/network/graphql_client.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> signUp(String username, String email, String password, String role, String? publicKey);

  //2FA
  Future<String> enableTwoFactorAuth();
  Future<bool> verifyAndEnableTwoFactorAuth(String token);
  Future<UserModel> verifyTwoFactorLogin(String userId, String token);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {

  
  @override
  Future<UserModel> login(String email, String password) async {
    final GraphQLClient client = GraphQLService.client;

    const String loginMutation = """
      mutation Login(\$credentials: LoginInput!) {
        login(credentials: \$credentials) {
          accessToken
          refreshToken
          user {
            _id
            username
            email
            role
          }
        }
      }
    """;

    final QueryResult result = await client.mutate(
      MutationOptions(
        document: gql(loginMutation),
        variables: {
          "credentials": {
            "email": email,
            "password": password,
          },
        },
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final userData = result.data?['login'];
    return UserModel.fromJson(userData);
  }

  @override
  Future<UserModel> signUp(String username, String email, String password, String role, String? publicKey) async {
    final GraphQLClient client = GraphQLService.client;

    const String signUpMutation = """
      mutation SignUp(\$signupData: UserInput!) {
        signUp(signupData: \$signupData) {
          _id
          username
          email
          role
        }
      }
    """;

    final QueryResult result = await client.mutate(
      MutationOptions(
        document: gql(signUpMutation),
        variables: {
          "signupData": {
            "username": username,
            "email": email,
            "password": password,
            "role": role,
            "publicKey": publicKey,
          },
        },
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final userData = result.data?['signUp'];
    return UserModel.fromJson(userData);
  }


//partie 2FA

  @override
  Future<String> enableTwoFactorAuth() async {
    final GraphQLClient client = GraphQLService.client;

    const String enableTwoFactorMutation = """
      mutation EnableTwoFactor {
        enableTwoFactorAuth
      }
    """;

    final QueryResult result = await client.mutate(
      MutationOptions(
        document: gql(enableTwoFactorMutation),
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final qrCodeUrl = result.data?["enableTwoFactorAuth"];
    if (qrCodeUrl == null) {
      throw Exception("Invalid response from server");
    }

    return qrCodeUrl;
  }

  @override
  Future<bool> verifyAndEnableTwoFactorAuth(String token) async {
    final GraphQLClient client = GraphQLService.client;

    const String verifyTwoFactorMutation = """
      mutation VerifyTwoFactor(\$token: String!) {
        verifyTwoFactorAuth(token: \$token)
      }
    """;

    final QueryResult result = await client.mutate(
      MutationOptions(
        document: gql(verifyTwoFactorMutation),
        variables: {
          "token": token,
        },
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final isVerified = result.data?["verifyTwoFactorAuth"];
    if (isVerified == null) {
      throw Exception("Invalid response from server");
    }

    return isVerified;
  }
  
  
  @override
  Future<UserModel> verifyTwoFactorLogin(String userId, String token) {
    // TODO: implement verifyTwoFactorLogin
    throw UnimplementedError();
  }
  

  
}
