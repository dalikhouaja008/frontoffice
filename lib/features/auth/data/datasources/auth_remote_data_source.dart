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
  }) : _secureStorage = secureStorage;

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

    // Verify user data
    final userData = loginData['user'];
    if (userData == null) {
      print('AuthRemoteDataSourceImpl:❌ No user data in response');
      throw Exception('No user data in response');
    }

    // Create the User object
    final user = User.fromJson({
      '_id': userData['_id'],
      'email': userData['email'],
      'username': userData['username'],
      'role': userData['role'],
    });

    // Handle Two-Factor Authentication (2FA)
    final requiresTwoFactor = loginData['requiresTwoFactor'] ?? false; // Default to false
    if (requiresTwoFactor == true) {
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

    // Handle normal login tokens
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
        isTwoFactorEnabled
        isVerified
        createdAt
        updatedAt
        phoneNumber
      }
    }
  """;

  try {
    final QueryResult result = await client.mutate(
      MutationOptions(
        document: gql(signUpMutation),
        variables: {
          "signupData": {
            "username": username,
            "email": email,
            "password": password,
            "role": role,
            if (publicKey != null) "publicKey": publicKey,
          },
        },
      ),
    );

    // Detailed error handling
    if (result.hasException) {
      print('Signup Mutation Errors:');
      
      // Comprehensive error logging
      if (result.exception?.graphqlErrors.isNotEmpty == true) {
        result.exception?.graphqlErrors.forEach((error) {
          print('GraphQL Error: ${error.message}');
          print('Error Locations: ${error.locations}');
          print('Error Extensions: ${error.message}');
          
          // Specific error handling
          if (error.message.contains('Email already in use')) {
            throw Exception('This email is already registered');
          }
          if (error.message.contains('Phone number already in use')) {
            throw Exception('This phone number is already registered');
          }
        });
      }

      // Log network errors
      if (result.exception?.linkException != null) {
        print('Network Error: ${result.exception?.linkException}');
      }

      // Generic error message
      final errorMessage = result.exception?.graphqlErrors.isNotEmpty == true 
          ? result.exception!.graphqlErrors.first.message 
          : 'Signup failed due to an unknown error';
      
      throw Exception(errorMessage);
    }

    // Validate user data
    final userData = result.data?['signUp'];
    if (userData == null) {
      throw Exception('No user data returned from signup');
    }

    // Debug print to see exact user data structure
    print('User Data from Signup: $userData');

    // Return UserModel, ensuring all necessary data is present
    return UserModel.fromJson({
      'user': userData,
      'accessToken': '', 
      'refreshToken': ''
    });

  } catch (e) {
    print('Detailed Signup Error: $e');
    rethrow;
  }
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
  const timestamp = '2025-02-17 11:55:47';
  const user = 'raednas';

  print('[$timestamp] AuthRemoteDataSource: 🔐 Verifying login OTP'
        '\n└─ User: $user'
        '\n└─ OTP length: ${otpCode.length}');

  try {
    // Créer un client avec le token temporaire
    final client = GraphQLService.getClientWithToken(tempToken);

    const String verifyTwoFactorMutation = r'''
      mutation VerifyTwoFactorLogin($token: String!) {
        verifyTwoFactorLogin(token: $token) {
          accessToken
          refreshToken
          requiresTwoFactor
          user {
            _id
            email
            username
            
            isTwoFactorEnabled
          }
        }
      }
    ''';

    print('[$timestamp] AuthRemoteDataSource: 🌐 Sending verification request'
          '\n└─ User: $user'
          '\n└─ Has tempToken: ${tempToken.isNotEmpty}'
          '\n└─ OTP length: ${otpCode.length}');

    final QueryResult result = await client.mutate(
      MutationOptions(
        document: gql(verifyTwoFactorMutation),
        variables: {
          'token': otpCode,
        },
        fetchPolicy: FetchPolicy.noCache,
      ),
    );

    print('[$timestamp] AuthRemoteDataSource: 📥 Raw GraphQL response:'
          '\n${result.data}');

    if (result.hasException) {
      final error = result.exception?.graphqlErrors.firstOrNull?.message ?? 
                   result.exception.toString();
      
      print('[$timestamp] AuthRemoteDataSource: ❌ GraphQL error'
            '\n└─ User: $user'
            '\n└─ Error: $error');
      
      throw Exception(error);
    }

    final data = result.data?['verifyTwoFactorLogin'];
    if (data == null) {
      print('[$timestamp] AuthRemoteDataSource: ❌ No data in response'
            '\n└─ User: $user');
      throw Exception('Réponse invalide du serveur');
    }

    // Vérifier les tokens
    final accessToken = data['accessToken'];
    final refreshToken = data['refreshToken'];

    if (accessToken == null || refreshToken == null) {
      print('[$timestamp] AuthRemoteDataSource: ❌ Missing tokens'
            '\n└─ User: $user'
            '\n└─ Has accessToken: ${accessToken != null}'
            '\n└─ Has refreshToken: ${refreshToken != null}');
      throw Exception('Tokens manquants dans la réponse');
    }

    // Sauvegarder les nouveaux tokens
    await _secureStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );

    print('[$timestamp] AuthRemoteDataSource: ✅ 2FA verification successful'
          '\n└─ User: $user'
          '\n└─ Tokens stored: true');

    return LoginResponse(
      user: User.fromJson(data['user']),
      accessToken: accessToken,
      refreshToken: refreshToken,
      requiresTwoFactor: false,
      tempToken: null,
    );

  } catch (e) {
    print('[$timestamp] AuthRemoteDataSource: ❌ Verification failed'
          '\n└─ User: $user'
          '\n└─ Error: $e');
    throw Exception('Erreur lors de la vérification: ${e.toString()}');
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