// lib/features/investment/data/datasources/investment_remote_data_source.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/enhanced_tokens_response_model.dart';
import '../../../../core/services/secure_storage_service.dart';

abstract class InvestmentRemoteDataSource {
  Future<EnhancedTokensResponseModel> getEnhancedTokens();
}

class InvestmentRemoteDataSourceImpl implements InvestmentRemoteDataSource {
  final http.Client client;
  final SecureStorageService secureStorage;
  final String baseUrl;

  InvestmentRemoteDataSourceImpl({
    required this.client,
    required this.secureStorage,
    required this.baseUrl,
  });

  @override
  Future<EnhancedTokensResponseModel> getEnhancedTokens() async {
    final token = await secureStorage.getAccessToken();
    if (token == null) {
      throw Exception('Non authentifié');
    }

    final response = await client.get(
      Uri.parse('$baseUrl/marketplace/enhanced-tokens'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return EnhancedTokensResponseModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Échec de récupération des tokens améliorés: ${response.body}');
    }
  }
}