import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/secure_storage_service.dart';

class AuthInterceptor {
  final SecureStorageService secureStorage;
  final String baseUrl;
  
  AuthInterceptor({
    required this.secureStorage, 
    required this.baseUrl
  });

  Future<String?> getCurrentToken() async {
    return secureStorage.read(key: 'jwt_token');
  }

  Future<bool> isTokenValid() async {
    final token = await getCurrentToken();
    if (token == null) return false;
    
    final parts = token.split('.');
    return parts.length == 3;
  }

  Future<bool> refreshToken() async {
    try {
      // Get refresh token
      final refreshToken = await secureStorage.read(key: 'refresh_token');
      if (refreshToken == null) {
        debugPrint('[${DateTime.now()}] No refresh token available');
        return false;
      }
      
      // Call refresh token endpoint
      final response = await http.post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'refreshToken': refreshToken}),
      );
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        // Save new tokens
        await secureStorage.write(
          key: 'jwt_token', 
          value: responseData['accessToken']
        );
        
        await secureStorage.write(
          key: 'refresh_token', 
          value: responseData['refreshToken']
        );
        
        debugPrint('[${DateTime.now()}] Token refreshed successfully');
        return true;
      } else {
        debugPrint('[${DateTime.now()}] Failed to refresh token: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('[${DateTime.now()}] Error refreshing token: $e');
      return false;
    }
  }

  Future<Map<String, String>> getAuthHeaders() async {
    if (!await isTokenValid()) {
      final refreshed = await refreshToken();
      if (!refreshed) {
        // Token refresh failed - user may need to login again
        throw Exception('Authentication failed. Please login again.');
      }
    }
    
    final token = await getCurrentToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}