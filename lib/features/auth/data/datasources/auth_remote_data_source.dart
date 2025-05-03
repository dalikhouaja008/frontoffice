import 'dart:convert';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:the_boost/core/services/secure_storage_service.dart';
import 'package:the_boost/features/auth/data/models/device_info_model.dart';
import 'package:the_boost/features/auth/domain/entities/login_response.dart';
import 'package:the_boost/features/auth/domain/entities/user.dart';
import '../../../../core/network/graphql_client.dart';
import '../models/user_model.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' if (dart.library.html) 'dart:html' show window;


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
  final DeviceInfoPlugin _deviceInfo;

  AuthRemoteDataSourceImpl({
    required GraphQLClient client,
    required SecureStorageService secureStorage,
  })  : _secureStorage = secureStorage,
        _deviceInfo = DeviceInfoPlugin();

 Future<LoginResponse> login(String email, String password) async {
  final timestamp = DateTime.now().toIso8601String();
  print('AuthRemoteDataSourceImpl: 🌐 Sending login request'
        '\n└─ Email: $email'
        '\n└─ Timestamp: $timestamp');

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
        print('[$timestamp] ❌ No login data received');
        throw Exception('No login data received');
      }

      // Vérifier les données utilisateur
      final userData = loginData['user'];
      if (userData == null) {
        print('AuthRemoteDataSourceImpl: ❌ No user data in response');
        throw Exception('No user data in response');
      }

      // Créer l'objet User
      final user = User.fromJson({
        '_id': userData['_id'],
        'email': userData['email'],
        'username': userData['username'],
        'role': userData['role'],
        'isTwoFactorEnabled': userData['isTwoFactorEnabled'] ?? false,
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
          sessionId: null,
          deviceInfo: null,
        );
      }

      // Vérifier les tokens et la session pour le login normal
      final accessToken = loginData['accessToken'];
      final refreshToken = loginData['refreshToken'];
      final sessionId = loginData['sessionId'];
      final deviceInfoResponse = loginData['deviceInfo'];

      if (accessToken == null || refreshToken == null) {
        print('AuthRemoteDataSourceImpl: ❌ Missing tokens'
            '\n└─ Email: ${user.email}'
            '\n└─ Has access token: ${accessToken != null}'
            '\n└─ Has refresh token: ${refreshToken != null}');
        throw Exception('Missing required tokens');
      }

      // Créer l'objet DeviceInfo
      final deviceInfoModel = deviceInfoResponse != null
          ? DeviceInfoModel.fromJson(deviceInfoResponse)
          : null;

      print('AuthRemoteDataSourceImpl: ✅ Login successful'
          '\n└─ Email: ${user.email}'
          '\n└─ Role: ${user.role}'
          '\n└─ Session ID: $sessionId'
          '\n└─ Device: ${deviceInfoModel?.device ?? "Unknown"}');

      return LoginResponse(
        user: user,
        accessToken: accessToken,
        refreshToken: refreshToken,
        requiresTwoFactor: false,
        tempToken: null,
        sessionId: sessionId,
        deviceInfo: deviceInfoModel,
      );
    } catch (e) {
      final errorMessage = 'Failed to login: $e';
      print('AuthRemoteDataSourceImpl: ❌ Login error'
          '\n└─ Error: $errorMessage'
          '\n└─ Email: $email');
      throw Exception(errorMessage);
    }
  }

 Future<Map<String, String>> _getDeviceInfo() async {
  try {
    if (Platform.isAndroid) {
      final androidInfo = await _deviceInfo.androidInfo;
      return {
        'device': androidInfo.model,
        'deviceType': 'mobile', // Ajout du type d'appareil
        'userAgent': 'Flutter/${androidInfo.version.release} (Android; ${androidInfo.model})',
      };
    } else if (Platform.isIOS) {
      final iosInfo = await _deviceInfo.iosInfo;
      return {
        'device': iosInfo.model,
        'deviceType': 'mobile', // Ajout du type d'appareil
        'userAgent': 'Flutter/${iosInfo.systemVersion} (iOS; ${iosInfo.model})',
      };
    } else if (kIsWeb) {
      return {
        'device': 'Web Browser',
        'deviceType': 'web',
        'userAgent': window.navigator.userAgent,
      };
    }
    return {
      'device': 'Unknown Device',
      'deviceType': 'unknown',
      'userAgent': 'Flutter/Unknown',
    };
  } catch (e) {
    print('AuthRemoteDataSourceImpl: ⚠️ Error getting device info: $e');
    return {
      'device': 'Unknown Device',
      'deviceType': 'unknown',
      'userAgent': 'Flutter/Unknown',
    };
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
