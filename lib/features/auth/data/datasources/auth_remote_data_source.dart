import 'dart:convert';

import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:the_boost/core/services/secure_storage_service.dart';
import 'package:the_boost/features/auth/domain/entities/login_response.dart';
import 'package:the_boost/features/auth/domain/entities/user.dart';
import '../../../../core/network/graphql_client.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponse> login(String email, String password);
  Future<UserModel> signUp(String username, String email, String password,
      String role, String? publicKey);

  //2FA
  Future<String> enableTwoFactorAuth();
  Future<bool> verifyAndEnableTwoFactorAuth(String token);
  Future<UserModel> verifyTwoFactorLogin(String userId, String token);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final GraphQLClient _client;
  final SecureStorageService _secureStorage;

  AuthRemoteDataSourceImpl({
    required GraphQLClient client,
    required SecureStorageService secureStorage,
  })  : _client = client,
        _secureStorage = secureStorage;

  Future<LoginResponse> login(String email, String password) async {
    final timestamp = DateTime.now().toIso8601String();
    print('[$timestamp] 🌐 Sending login request'
        '\n└─ Email: $email');

    final GraphQLClient client = GraphQLService.client;

    const String loginMutation = """
    mutation Login(\$credentials: LoginInput!) {
      login(credentials: \$credentials) {
        accessToken
        refreshToken
        user {
          _id
          email
          username
          role
        }
      }
    }
  """;

    try {
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
        print('[$timestamp] ❌ GraphQL error'
            '\n└─ Error: ${result.exception.toString()}');
        throw Exception(result.exception.toString());
      }

      // Afficher la réponse brute
      print('[$timestamp] 📥 Raw GraphQL response:'
          '\n${JsonEncoder.withIndent('  ').convert(result.data)}');

      final loginData = result.data?['login'];
      if (loginData == null) {
        print('[$timestamp] ❌ No login data received');
        throw Exception('No login data received');
      }

      // Vérifier chaque champ requis
      final userData = loginData['user'];
      if (userData == null) {
        print('[$timestamp] ❌ No user data in response');
        throw Exception('No user data in response');
      }

      final accessToken = loginData['accessToken'];
      if (accessToken == null) {
        print('[$timestamp] ❌ No access token in response');
        throw Exception('No access token in response');
      }

      final refreshToken = loginData['refreshToken'];
      if (refreshToken == null) {
        print('[$timestamp] ❌ No refresh token in response');
        throw Exception('No refresh token in response');
      }

      // Créer l'objet User
      final user = User.fromJson({
        '_id': userData['_id'],
        'email': userData['email'],
        'username': userData['username'],
        'role': userData['role'],
      });

      print('[$timestamp] ✅ Login successful'
          '\n└─ User: ${user.email}'
          '\n└─ Role: ${user.role}');

      // Créer la réponse de login
      return LoginResponse(
        user: user,
        accessToken: accessToken,
        refreshToken: refreshToken,
        requiresTwoFactor: false, // valeur par défaut
        tempToken: null, // valeur par défaut
      );
    } catch (e) {
      final errorMessage = 'Failed to login: $e';
      print('[$timestamp] ❌ Login error'
          '\n└─ Error: $errorMessage'
          '\n└─ Email: $email');
      throw Exception(errorMessage);
    }
  }

  @override
  Future<UserModel> signUp(String username, String email, String password,
      String role, String? publicKey) async {
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
Future<bool> verifyAndEnableTwoFactorAuth(String token) async {
  final timestamp = '2025-02-13 21:54:13';
  print('[$timestamp] 🔐 Verifying 2FA token'
        '\n└─ User: raednas');

  final String? accessToken = await _secureStorage.getAccessToken();
  if (accessToken == null) {
    print('[$timestamp] ❌ No access token found');
    throw Exception('Authentication required');
  }

  // Utiliser le client authentifié
  final GraphQLClient client = GraphQLService.getClientWithToken(accessToken);

  const String verifyTwoFactorMutation = """
    mutation VerifyTwoFactor(\$token: String!) {
      verifyTwoFactorAuth(token: \$token)
    }
  """;

  try {
    final QueryResult result = await client.mutate(
      MutationOptions(
        document: gql(verifyTwoFactorMutation),
        variables: {
          "token": token,
        },
      ),
    );

    if (result.hasException) {
      print('[$timestamp] ❌ 2FA verification failed'
            '\n└─ Error: ${result.exception.toString()}');
      throw Exception(result.exception.toString());
    }

    final isVerified = result.data?["verifyTwoFactorAuth"];
    if (isVerified == null) {
      print('[$timestamp] ❌ Invalid server response');
      throw Exception("Invalid response from server");
    }

    print('[$timestamp] ✅ 2FA verification ${isVerified ? 'successful' : 'failed'}'
          '\n└─ User: raednas');
    return isVerified;
  } catch (e) {
    print('[$timestamp] ⚠️ 2FA verification error'
          '\n└─ Error: $e');
    throw Exception('Failed to verify 2FA: $e');
  }
}
  @override
  Future<UserModel> verifyTwoFactorLogin(String userId, String token) async {
    final timestamp = DateTime.now().toIso8601String();
    print('[$timestamp] 🔐 Verifying 2FA login'
          '\n└─ User ID: $userId');

    const String verifyLoginMutation = """
      mutation VerifyTwoFactorLogin(\$userId: String!, \$token: String!) {
        verifyTwoFactorLogin(userId: \$userId, token: \$token) {
          _id
          username
          email
          role
          isTwoFactorEnabled
          createdAt
          updatedAt
        }
      }
    """;

    try {
      final QueryResult result = await _client.mutate(
        MutationOptions(
          document: gql(verifyLoginMutation),
          variables: {
            "userId": userId,
            "token": token,
          },
        ),
      );

      if (result.hasException) {
        print('[$timestamp] ❌ 2FA login verification failed'
              '\n└─ Error: ${result.exception.toString()}');
        throw Exception(result.exception.toString());
      }

      final userData = result.data?['verifyTwoFactorLogin'];
      if (userData == null) {
        print('[$timestamp] ❌ No user data received');
        throw Exception('No user data received');
      }

      final user = UserModel.fromJson(userData);
      print('[$timestamp] ✅ 2FA login verification successful'
            '\n└─ User: ${user.email}');

      return user;
    } catch (e) {
      print('[$timestamp] ⚠️ 2FA login verification error'
            '\n└─ Error: $e');
      throw Exception('Failed to verify 2FA login: $e');
    }
  }
  
@override
Future<String> enableTwoFactorAuth() async {
  final timestamp = '2025-02-13 21:54:13';
  print('[$timestamp] 🔐 Initiating 2FA activation'
        '\n└─ User: raednas');

  final String? accessToken = await _secureStorage.getAccessToken();
   print('[$timestamp] 🔐 access token in remote data source $accessToken');
  
  if (accessToken == null) {
    print('[$timestamp] ❌ No access token found in secure storage');
    throw Exception('Authentication required: No access token found');
  }

  // Utiliser le client authentifié
  final GraphQLClient client = GraphQLService.getClientWithToken(accessToken);

  const String enableTwoFactorMutation = """
    mutation EnableTwoFactorAuth {
      enableTwoFactorAuth
    }
  """;

  try {
    final QueryResult result = await client.mutate(
      MutationOptions(
        document: gql(enableTwoFactorMutation),
      ),
    );

    if (result.hasException) {
      print('[$timestamp] ❌ Failed to enable 2FA'
            '\n└─ Error: ${result.exception.toString()}');
      throw Exception(result.exception.toString());
    }

    final qrCodeUrl = result.data?['enableTwoFactorAuth'];
    if (qrCodeUrl == null) {
      print('[$timestamp] ❌ No QR code URL received');
      throw Exception('No QR code URL received');
    }

    print('[$timestamp] 📱 2FA QR Code generated successfully'
          '\n└─ User: raednas'
          '\n└─ Length: ${qrCodeUrl.length} characters'
          '\n'
          '\n=== QR Code URL ==='
          '\n$qrCodeUrl'
          '\n==================');

    return qrCodeUrl;
  } catch (e) {
    print('[$timestamp] ⚠️ Error enabling 2FA'
          '\n└─ Error: $e');
    throw Exception('Failed to enable 2FA: $e');
  }
}
}
