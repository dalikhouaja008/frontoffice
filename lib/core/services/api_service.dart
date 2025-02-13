import 'package:graphql_flutter/graphql_flutter.dart';
import 'secure_storage_service.dart';

//un service pour gérer les headers HTTP
class ApiService {
  final SecureStorageService _secureStorage;
  
  ApiService({required SecureStorageService secureStorage})
      : _secureStorage = secureStorage;

  Future<Map<String, String>> getHeaders() async {
    final token = await _secureStorage.getAccessToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<Link> getAuthLink() async {
    return AuthLink(
      getToken: () async {
        final token = await _secureStorage.getAccessToken();
        return 'Bearer $token';
      },
    );
  }
}