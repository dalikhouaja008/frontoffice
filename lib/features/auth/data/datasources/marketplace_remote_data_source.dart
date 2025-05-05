import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/services/secure_storage_service.dart';

abstract class MarketplaceRemoteDataSource {
  Future<Map<String, dynamic>> listToken(int tokenId, String price);
  Future<Map<String, dynamic>> listMultipleTokens(List<int> tokenIds, List<String> prices);
  Future<Map<String, dynamic>> cancelListing(int tokenId);
}

class MarketplaceRemoteDataSourceImpl implements MarketplaceRemoteDataSource {
  final http.Client client;
  final SecureStorageService secureStorage;
  final String baseUrl;

  MarketplaceRemoteDataSourceImpl({
    required this.client,
    required this.secureStorage,
    required this.baseUrl,
  });

  @override
  Future<Map<String, dynamic>> listToken(int tokenId, String price) async {
    final token = await secureStorage.getAccessToken();
    if (token == null) {
      throw Exception('Non authentifié');
    }

    final response = await client.post(
      Uri.parse('$baseUrl/marketplace/list'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'tokenId': tokenId,
        'price': price,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Échec de la mise en vente du token: ${response.body}');
    }
  }

  @override
  Future<Map<String, dynamic>> listMultipleTokens(List<int> tokenIds, List<String> prices) async {
    final token = await secureStorage.getAccessToken();
    if (token == null) {
      throw Exception('Non authentifié');
    }

    // Vérifier que les listes ont la même longueur
    if (tokenIds.length != prices.length) {
      throw Exception('Le nombre de tokens et de prix doit être identique');
    }

    final response = await client.post(
      Uri.parse('$baseUrl/marketplace/list-multiple'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'tokenIds': tokenIds,
        'prices': prices,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Échec de la mise en vente multiple: ${response.body}');
    }
  }

  @override
  Future<Map<String, dynamic>> cancelListing(int tokenId) async {
    final token = await secureStorage.getAccessToken();
    if (token == null) {
      throw Exception('Non authentifié');
    }

    final response = await client.post(
      Uri.parse('$baseUrl/marketplace/cancel-listing'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'tokenId': tokenId,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Échec de l\'annulation de la mise en vente: ${response.body}');
    }
  }
}