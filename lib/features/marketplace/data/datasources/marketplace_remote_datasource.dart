import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:the_boost/features/marketplace/data/models/marketplace_remote_datasource.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/auth_interceptor.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../models/token_model.dart';

abstract class MarketplaceRemoteDataSource {
  /// Gets all token listings from the remote API
  Future<List<TokenModel>> getAllListings();
  
  /// Gets filtered token listings based on various criteria
  Future<List<TokenModel>> getFilteredListings({
    String? query,
    double? minPrice,
    double? maxPrice,
    String? category,
    String? sortBy,
  });
  
  /// Gets details for a specific token by ID
  Future<TokenModel> getListingDetails(int tokenId);
  
  Future<TransactionResponseModel> purchaseToken(int tokenId, String price);
}

class MarketplaceRemoteDataSourceImpl implements MarketplaceRemoteDataSource {
  final http.Client client;
  final String baseUrl;
  final SecureStorageService secureStorage;
  final AuthInterceptor? authInterceptor;
  
  MarketplaceRemoteDataSourceImpl({
    required this.client, 
    required this.baseUrl,
    required this.secureStorage,
    this.authInterceptor,
  });
  
  /// Helper method to get auth headers
  Future<Map<String, String>> _getAuthHeaders() async {
    try {
      // Récupérer directement le token à partir du SecureStorageService
      final token = await secureStorage.getAccessToken();
      if (token == null) {
        throw ServerException(message: 'Non authentifié');
      }
      
      return {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
    } catch (e) {
      debugPrint('[${DateTime.now()}] Error getting auth headers: $e');
      // Relancer l'exception pour indiquer qu'une authentification est nécessaire
      throw ServerException(message: 'Authentification requise: $e');
    }
  }
  
  @override
  Future<List<TokenModel>> getAllListings() async {
    try {
      final headers = await _getAuthHeaders();
      
      debugPrint('[${DateTime.now()}] Fetching all marketplace listings');
      final response = await client.get(
        Uri.parse('$baseUrl/marketplace/listings'),
        headers: headers,
      );
      
      debugPrint('[${DateTime.now()}] Marketplace listings response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] && jsonData['data'] != null) {
          final tokenList = List<TokenModel>.from(
            (jsonData['data'] as List).map((item) => TokenModel.fromJson(item))
          );
          debugPrint('[${DateTime.now()}] Successfully parsed ${tokenList.length} tokens');
          return tokenList;
        } else {
          debugPrint('[${DateTime.now()}] Received success: false or empty data');
          return [];
        }
      } else {
        debugPrint('[${DateTime.now()}] Failed to load listings: ${response.statusCode} - ${response.reasonPhrase}');
        throw ServerException(message: 'Failed to load listings: ${response.reasonPhrase}');
      }
    } catch (e) {
      debugPrint('[${DateTime.now()}] Exception in getAllListings: $e');
      throw ServerException(message: 'Error fetching listings: $e');
    }
  }
  
  @override
  Future<List<TokenModel>> getFilteredListings({
    String? query,
    double? minPrice,
    double? maxPrice,
    String? category,
    String? sortBy,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      
      // Build query parameters based on filters
      final queryParameters = <String, String>{};
      if (query != null && query.isNotEmpty) {
        queryParameters['query'] = query;
      }
      if (minPrice != null) {
        queryParameters['minPrice'] = minPrice.toString();
      }
      if (maxPrice != null) {
        queryParameters['maxPrice'] = maxPrice.toString();
      }
      
      // Map category to API's expected parameter
      if (category != null && category != 'All Categories' && category.isNotEmpty) {
        switch (category.toLowerCase()) {
          case 'residential':
            queryParameters['landType'] = 'residential';
            break;
          case 'commercial':
            queryParameters['landType'] = 'commercial';
            break;
          case 'agricultural':
            queryParameters['landType'] = 'agricultural';
            break;
          case 'industrial':
            queryParameters['landType'] = 'industrial';
            break;
          case 'mixed use':
            queryParameters['landType'] = 'mixed';
            break;
        }
      }
      
      // Convert UI sort options to API parameters
      if (sortBy != null && sortBy.isNotEmpty) {
        String apiSortBy = 'price';
        String sortOrder = 'asc';
        
        if (sortBy.contains('Low to High')) {
          apiSortBy = 'price';
          sortOrder = 'asc';
        } else if (sortBy.contains('High to Low')) {
          apiSortBy = 'price';
          sortOrder = 'desc';
        } else if (sortBy.contains('Newest')) {
          apiSortBy = 'date';
          sortOrder = 'desc';
        } else if (sortBy.contains('ROI')) {
          apiSortBy = 'profit';
          sortOrder = 'desc';
        } else if (sortBy.contains('Surface')) {
          apiSortBy = 'surface';
          sortOrder = 'asc';
        }
        
        queryParameters['sortBy'] = apiSortBy;
        queryParameters['sortOrder'] = sortOrder;
      }
      
      debugPrint('[${DateTime.now()}] Fetching filtered listings with params: $queryParameters');
      
      final uri = Uri.parse('$baseUrl/marketplace/listings/filtered')
          .replace(queryParameters: queryParameters);
          
      final response = await client.get(
        uri,
        headers: headers,
      );
      
      debugPrint('[${DateTime.now()}] Filtered listings response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] && jsonData['data'] != null) {
          final tokenList = List<TokenModel>.from(
            (jsonData['data'] as List).map((item) => TokenModel.fromJson(item))
          );
          debugPrint('[${DateTime.now()}] Successfully parsed ${tokenList.length} filtered tokens');
          return tokenList;
        } else {
          debugPrint('[${DateTime.now()}] Received success: false or empty data for filtered listings');
          return [];
        }
      } else {
        debugPrint('[${DateTime.now()}] Failed to load filtered listings: ${response.statusCode} - ${response.reasonPhrase}');
        throw ServerException(message: 'Failed to load filtered listings: ${response.reasonPhrase}');
      }
    } catch (e) {
      debugPrint('[${DateTime.now()}] Exception in getFilteredListings: $e');
      throw ServerException(message: 'Error fetching filtered listings: $e');
    }
  }
  
  @override
  Future<TokenModel> getListingDetails(int tokenId) async {
    try {
      final headers = await _getAuthHeaders();
      
      debugPrint('[${DateTime.now()}] Fetching token details for ID: $tokenId');
      
      final response = await client.get(
        Uri.parse('$baseUrl/marketplace/listings/$tokenId'),
        headers: headers,
      );
      
      debugPrint('[${DateTime.now()}] Token details response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] && jsonData['data'] != null) {
          final token = TokenModel.fromJson(jsonData['data']);
          debugPrint('[${DateTime.now()}] Successfully parsed token details for ID: $tokenId');
          return token;
        } else {
          debugPrint('[${DateTime.now()}] Received success: false or empty data for token details');
          throw ServerException(message: 'Token not found');
        }
      } else {
        debugPrint('[${DateTime.now()}] Failed to load token details: ${response.statusCode} - ${response.reasonPhrase}');
        throw ServerException(message: 'Failed to load token details: ${response.reasonPhrase}');
      }
    } catch (e) {
      debugPrint('[${DateTime.now()}] Exception in getListingDetails: $e');
      throw ServerException(message: 'Error fetching token details: $e');
    }
  }
  
@override
Future<TransactionResponseModel> purchaseToken(int tokenId, String price) async {
  try {
    final headers = await _getAuthHeaders();
    
    // Extraire le prix numérique (enlever " ETH" s'il est présent)
    final numericPrice = price.replaceAll(' ETH', '');
    
    debugPrint('[${DateTime.now()}] Initiating purchase for token ID: $tokenId at price $numericPrice');
    
    final response = await client.post(
      Uri.parse('$baseUrl/marketplace/buy'),
      headers: headers,
      body: json.encode({
        'tokenId': tokenId,
        'value': numericPrice,
      }),
    );
    
    debugPrint('[${DateTime.now()}] Purchase response: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData['success'] == true) {
        debugPrint('[${DateTime.now()}] Successfully purchased token $tokenId');
        return TransactionResponseModel.fromJson(jsonData);
      } else {
        final errorMessage = jsonData['message'] ?? 'Transaction échouée';
        debugPrint('[${DateTime.now()}] Purchase unsuccessful: $errorMessage');
        throw ServerException(message: errorMessage);
      }
    } else {
      debugPrint('[${DateTime.now()}] Failed to purchase token: ${response.statusCode} - ${response.reasonPhrase}');
      throw ServerException(message: 'Failed to purchase token: ${response.reasonPhrase}');
    }
  } catch (e) {
    debugPrint('[${DateTime.now()}] Exception in purchaseToken: $e');
    throw ServerException(message: 'Error purchasing token: $e');
  }
}
}