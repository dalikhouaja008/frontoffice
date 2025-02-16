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

  Future<bool> verifyTwoFactorAuth(String token);

  Future<LoginResponse> verifyLoginOtp(
    String tempToken,
    String otpCode,
  );
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SecureStorageService _secureStorage;

  AuthRemoteDataSourceImpl({
    required GraphQLClient client,
    required SecureStorageService secureStorage,
  })  : _secureStorage = secureStorage;

  Future<LoginResponse> login(String email, String password) async {
    DateTime.now().toIso8601String();
    print('AuthRemoteDataSourceImpl: 🌐 Sending login request'
        '\n└─ Email: $email');

    final GraphQLClient client = GraphQLService.client;

  const String loginMutation = """
    mutation Login(\$credentials: LoginInput!) {
      login(credentials: \$credentials) {
        accessToken
        refreshToken
        tempToken
        requiresTwoFactor
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
      print('AuthRemoteDataSourceImpl: ❌ GraphQL error'
            '\n└─ Error: ${result.exception.toString()}');
      throw Exception(result.exception.toString());
    }

    print('AuthRemoteDataSourceImpl: 📥 Raw GraphQL response:'
          '\n${JsonEncoder.withIndent('  ').convert(result.data)}');

    final loginData = result.data?['login'];
    if (loginData == null) {
      print('[2025-02-15 16:44:26] ❌ No login data received');
      throw Exception('No login data received');
    }

    // Vérifier les données utilisateur
    final userData = loginData['user'];
    if (userData == null) {
      print('AuthRemoteDataSourceImpl:❌ No user data in response');
      throw Exception('No user data in response');
    }

    // Créer l'objet User
    final user = User.fromJson({
      '_id': userData['_id'],
      'email': userData['email'],
      'username': userData['username'],
      'role': userData['role'],
    });

    // Vérifier si 2FA est requis
    final requiresTwoFactor = loginData['requiresTwoFactor'] ?? false;
    if (requiresTwoFactor) {
      final tempToken = loginData['tempToken'];
      if (tempToken == null) {
        print('AuthRemoteDataSourceImpl: ❌ No temp token for 2FA'
              '\n└─ Email: ${user.email}');
        throw Exception('No temporary token provided for 2FA');
      }

      print('AuthRemoteDataSourceImpl: 🔐 2FA required'
            '\n└─ Email: ${user.email}');

      return LoginResponse(
        user: user,
        requiresTwoFactor: true,
        tempToken: tempToken,
        accessToken: null,
        refreshToken: null,
      );
    }

    // Vérifier les tokens pour le login normal
    final accessToken = loginData['accessToken'];
    final refreshToken = loginData['refreshToken'];

    if (accessToken == null || refreshToken == null) {
      print('AuthRemoteDataSourceImpl: ❌ Missing tokens'
            '\n└─ Email: ${user.email}'
            '\n└─ Has access token: ${accessToken != null}'
            '\n└─ Has refresh token: ${refreshToken != null}');
      throw Exception('Missing required tokens');
    }

    print('AuthRemoteDataSourceImpl:✅ Login successful'
          '\n└─ Email: ${user.email}'
          '\n└─ Role: ${user.role}');

    return LoginResponse(
      user: user,
      accessToken: accessToken,
      refreshToken: refreshToken,
      requiresTwoFactor: false,
      tempToken: null,
    );
  } catch (e) {
    final errorMessage = 'Failed to login: $e';
    print('AuthRemoteDataSourceImpl: ❌ Login error'
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
  Future<bool> verifyTwoFactorAuth(String token) async {
    print('AuthRemoteDataSource:🔐 Verifying 2FA token');

    final String? accessToken = await _secureStorage.getAccessToken();
    if (accessToken == null) {
      print('AuthRemoteDataSource: ❌ No access token found');
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
        print('AuthRemoteDataSource:❌ 2FA verification failed'
            '\n└─ Error: ${result.exception.toString()}');
        throw Exception(result.exception.toString());
      }

      final isVerified = result.data?["verifyTwoFactorAuth"];
      if (isVerified == null) {
        print('AuthRemoteDataSource: ❌ Invalid server response');
        throw Exception("Invalid response from server");
      }

      print(
          'AuthRemoteDataSource: ✅ 2FA verification ${isVerified ? 'successful' : 'failed'}'
          '\n└─ User: raednas');
      return isVerified;
    } catch (e) {
      print('AuthRemoteDataSource: ⚠️ 2FA verification error'
          '\n└─ Error: $e');
      throw Exception('Failed to verify 2FA: $e');
    }
  }

  @override
  Future<LoginResponse> verifyLoginOtp(
    String tempToken,
    String otpCode,
  ) async {
    print('AuthRemoteDataSourceImpl :🔐 RemoteDataSource: Verifying login OTP'
        '\n└─ OTP length: ${otpCode.length}');

    try {
      // Utiliser le client authentifié
      final GraphQLClient client = GraphQLService.getClientWithToken(tempToken);

      // Définir la mutation GraphQL
      const String verifyTwoFactorMutation = r'''
      mutation VerifyTwoFactorLogin($token: String!) {
        verifyTwoFactorLogin(token: $token) {
          accessToken
          refreshToken
          user {
            id
            email
            firstName
            lastName
            isTwoFactorEnabled
          }
        }
      }
    ''';

      // Configurer les headers avec le token temporaire
      final QueryResult result = await client.mutate(
        MutationOptions(
          document: gql(verifyTwoFactorMutation),
          variables: {
            "token": otpCode,
          },
        ),
      );

      if (result.hasException) {
        print('AuthRemoteDataSource: ❌ GraphQL mutation failed'
            '\n└─ Error: ${result.exception?.graphqlErrors.first.message ?? result.exception.toString()}');

        throw Exception(result.exception?.graphqlErrors.first.message ??
            'Erreur de vérification OTP');
      }

      final data = result.data?['verifyTwoFactorLogin'];
      if (data == null) {
        print('AuthRemoteDataSource: ❌ No data received from API');
        throw Exception('Aucune donnée reçue du serveur');
      }

      // Sauvegarder les nouveaux tokens
      await _secureStorage.saveTokens(
          accessToken: data['accessToken'], refreshToken: data['refreshToken']);

      print('AuthRemoteDataSource :✅ 2FA verification successful'
          '\n└─ Tokens stored in secure storage');

      return LoginResponse(
        user: User.fromJson(data['user']),
        accessToken: data['accessToken'],
        refreshToken: data['refreshToken'],
        requiresTwoFactor: false,
        tempToken: null,
      );
    } catch (e) {
      print('AuthRemoteDataSource: ❌ 2FA verification error'
          '\n└─ Error: $e');
      throw Exception('Erreur lors de la vérification 2FA: $e');
    }
  }

  @override
  Future<String> enableTwoFactorAuth() async {
    print('AuthRemoteDataSource:🔐 Initiating 2FA activation'
        '\n└─ User: raednas');

    final String? accessToken = await _secureStorage.getAccessToken();
    print(
        'AuthRemoteDataSource: 🔐 access token in remote data source $accessToken');

    if (accessToken == null) {
      print('AuthRemoteDataSource: ❌ No access token found in secure storage');
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
        print('AuthRemoteDataSource:❌ Failed to enable 2FA'
            '\n└─ Error: ${result.exception.toString()}');
        throw Exception(result.exception.toString());
      }

      final qrCodeUrl = result.data?['enableTwoFactorAuth'];
      if (qrCodeUrl == null) {
        print('AuthRemoteDataSource:❌ No QR code URL received');
        throw Exception('No QR code URL received');
      }

      print('AuthRemoteDataSource: 📱 2FA QR Code generated successfully'
          '\n└─ Length: ${qrCodeUrl.length} characters'
          '\n'
          '\n=== QR Code URL ==='
          '\n$qrCodeUrl'
          '\n==================');

      return qrCodeUrl;
    } catch (e) {
      print('AuthRemoteDataSource:⚠️ Error enabling 2FA'
          '\n└─ Error: $e');
      throw Exception('Failed to enable 2FA: $e');
    }
  }
}
