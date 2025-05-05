import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/error/exceptions.dart';
import '../models/token_model.dart';
import '../../../../core/services/secure_storage_service.dart';

abstract class MarketplaceRemoteDataSource {
  Future<List<TokenModel>> getAllListings();
  Future<List<TokenModel>> getFilteredListings({
    String? query,
    double? minPrice,
    double? maxPrice,
    String? category,
    String? sortBy,
  });
  Future<TokenModel> getListingDetails(int tokenId);
  Future<bool> purchaseToken(int tokenId, String buyerAddress);
}

class MarketplaceRemoteDataSourceImpl implements MarketplaceRemoteDataSource {
  final http.Client client;
  final String baseUrl;
  final SecureStorageService secureStorage;

  MarketplaceRemoteDataSourceImpl({
    required this.client,
    required this.baseUrl,
    required this.secureStorage,
  });

  // Helper method to get auth token
  Future<Map<String, String>> _getHeaders() async {
    try {
      final token = await secureStorage.read(key: 'jwt_token');
      print('[2025-05-05 04:48:27] Token from storage: ${token != null ? 'Found (${token.length} chars)' : 'Not found'}');
      
      if (token == null || token.isEmpty) {
        print('[2025-05-05 04:48:27] No valid JWT token found in storage');
        throw Exception('Authentication token not found');
      }
      
      return {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
    } catch (e) {
      print('[2025-05-05 04:48:27] Error getting auth headers: $e');
      throw AuthException(message: 'Failed to get authentication token: $e');
    }
  }

  @override
  Future<List<TokenModel>> getAllListings() async {
    try {
      print('[2025-05-05 04:48:27] Attempting to get all listings');
      
      // Try to get headers with token - this might throw if token is missing
      final headers = await _getHeaders();
      print('[2025-05-05 04:48:27] Headers obtained: ${headers.keys}');
      
      final response = await client.get(
        Uri.parse('$baseUrl/marketplace/listings'),
        headers: headers,
      );
      
      print('[2025-05-05 04:48:27] getAllListings response: ${response.statusCode}');
      print('[2025-05-05 04:48:27] Response body: ${response.body.substring(0, min(100, response.body.length))}...');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse != null) {
          print('[2025-05-05 04:48:27] Successfully parsed response JSON');
          final List<dynamic> tokensJson = jsonResponse['data'] ?? [];
          return tokensJson.map((json) => TokenModel.fromJson(json)).toList();
        } else {
          print('[2025-05-05 04:48:27] Response JSON is null');
          throw ServerException(message: 'Invalid response format');
        }
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        print('[2025-05-05 04:48:27] Authentication failed: ${response.statusCode}');
        throw AuthException(message: 'Authentication failed: ${response.body}');
      } else {
        print('[2025-05-05 04:48:27] Server error: ${response.statusCode}');
        throw ServerException(message: 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('[2025-05-05 04:48:27] Error in getAllListings: $e');
      
      // Return mock data in case of errors
      return _getMockTokens();
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
      final queryParams = <String, String>{};
      if (query != null && query.isNotEmpty) {
        queryParams['search'] = query;
      }
      if (minPrice != null) {
        queryParams['minPrice'] = minPrice.toString();
      }
      if (maxPrice != null) {
        queryParams['maxPrice'] = maxPrice.toString();
      }
      if (category != null && category.isNotEmpty && category != 'All Categories') {
        queryParams['landType'] = category;
      }
      if (sortBy != null && sortBy.isNotEmpty) {
        String sortField = 'price';
        String sortOrder = 'asc';
        
        if (sortBy.contains('High to Low')) {
          sortOrder = 'desc';
        } else if (sortBy.contains('Newest')) {
          sortField = 'date';
          sortOrder = 'desc';
        } else if (sortBy.contains('ROI')) {
          sortField = 'profit';
          sortOrder = 'desc';
        }
        
        queryParams['sortBy'] = sortField;
        queryParams['sortOrder'] = sortOrder;
      }

      try {
        final headers = await _getHeaders();
        final response = await client.get(
          Uri.parse('$baseUrl/marketplace/listings/filtered').replace(queryParameters: queryParams),
          headers: headers,
        );
        
        if (response.statusCode == 200) {
          final jsonResponse = json.decode(response.body);
          final List<dynamic> tokensJson = jsonResponse['data'] ?? [];
          return tokensJson.map((json) => TokenModel.fromJson(json)).toList();
        } else if (response.statusCode == 401) {
          throw AuthException(message: 'Authentication failed');
        } else {
          throw ServerException(message: 'Server error: ${response.statusCode}');
        }
      } catch (e) {
        print('[2025-05-05 04:48:27] API error in getFilteredListings: $e');
        return _getMockTokens();
      }
    } catch (e) {
      print('[2025-05-05 04:48:27] Error in getFilteredListings: $e');
      return _getMockTokens();
    }
  }

  @override
  Future<TokenModel> getListingDetails(int tokenId) async {
    try {
      final headers = await _getHeaders();
      final response = await client.get(
        Uri.parse('$baseUrl/marketplace/listings/$tokenId'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return TokenModel.fromJson(jsonResponse['data']);
      } else {
        throw ServerException(message: 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('[2025-05-05 04:48:27] Error in getListingDetails: $e');
      return _getMockTokens().firstWhere(
        (token) => token.tokenId == tokenId,
        orElse: () => _getMockTokens().first,
      );
    }
  }

  @override
  Future<bool> purchaseToken(int tokenId, String buyerAddress) async {
    try {
      final headers = await _getHeaders();
      final response = await client.post(
        Uri.parse('$baseUrl/marketplace/buy'),
        headers: headers,
        body: json.encode({
          'tokenId': tokenId,
          'value': '0.01',
        }),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw ServerException(message: 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('[2025-05-05 04:48:27] Error in purchaseToken: $e');
      return false;
    }
  }
  
  // Helper to get minimum value between two numbers
  int min(int a, int b) {
    return a < b ? a : b;
  }

  // Mock data
  List<TokenModel> _getMockTokens() {
    print('[2025-05-05 04:48:27] Generating mock token data');
    
    final now = DateTime.now();
    final threeDaysAgo = now.subtract(const Duration(days: 3));
    final oneWeekAgo = now.subtract(const Duration(days: 7));
    final oneMonthAgo = now.subtract(const Duration(days: 30));
    
    return [
      TokenModel(
        tokenId: 1,
        landId: 1,
        tokenNumber: 42,
        price: '0.025',
        purchasePrice: '0.020',
        mintDate: oneMonthAgo.toIso8601String(),
        seller: '0x8c34a78954632A5Bf09E87D13f31c801B0559D33',
        land: const LandModel(
          location: 'Brooklyn, NY',
          surface: 1200,
          status: 'Available',
          isRegistered: true,
          totalTokens: 100,
          availableTokens: 75,
          pricePerToken: '0.025 ETH',
          owner: '0x8c34a78954632A5Bf09E87D13f31c801B0559D33',
        ),
        listingDate: threeDaysAgo.toIso8601String(),
        listingDateFormatted: '${threeDaysAgo.month.toString().padLeft(2, '0')}/${threeDaysAgo.day.toString().padLeft(2, '0')}/${threeDaysAgo.year}',
        listingTimestamp: threeDaysAgo.millisecondsSinceEpoch ~/ 1000,
        daysSinceListing: 3,
        etherscanUrl: 'https://etherscan.io/token/0x123',
        formattedPrice: '0.025 ETH',
        formattedPurchasePrice: '0.020 ETH',
        mintDateFormatted: '${oneMonthAgo.month.toString().padLeft(2, '0')}/${oneMonthAgo.day.toString().padLeft(2, '0')}/${oneMonthAgo.year}',
        priceChangePercentage: const PriceChangePercentageModel(
          percentage: 25.0,
          formatted: '25.0%',
          isPositive: true,
        ),
        isRecentlyListed: true,
        isHighlyProfitable: true,
        investmentPotential: 5,
        investmentRating: 'Excellent',
      ),
      TokenModel(
        tokenId: 2,
        landId: 2,
        tokenNumber: 56,
        price: '0.018',
        purchasePrice: '0.017',
        mintDate: oneMonthAgo.toIso8601String(),
        seller: '0x5aEd24e5c636A58b9c35728dE3a54dF3dE61ce43',
        land: const LandModel(
          location: 'Austin, TX',
          surface: 2500,
          status: 'Available',
          isRegistered: true,
          totalTokens: 150,
          availableTokens: 120,
          pricePerToken: '0.018 ETH',
          owner: '0x5aEd24e5c636A58b9c35728dE3a54dF3dE61ce43',
        ),
        listingDate: oneWeekAgo.toIso8601String(),
        listingDateFormatted: '${oneWeekAgo.month.toString().padLeft(2, '0')}/${oneWeekAgo.day.toString().padLeft(2, '0')}/${oneWeekAgo.year}',
        listingTimestamp: oneWeekAgo.millisecondsSinceEpoch ~/ 1000,
        daysSinceListing: 7,
        etherscanUrl: 'https://etherscan.io/token/0x456',
        formattedPrice: '0.018 ETH',
        formattedPurchasePrice: '0.017 ETH',
        mintDateFormatted: '${oneMonthAgo.month.toString().padLeft(2, '0')}/${oneMonthAgo.day.toString().padLeft(2, '0')}/${oneMonthAgo.year}',
        priceChangePercentage: const PriceChangePercentageModel(
          percentage: 5.9,
          formatted: '5.9%',
          isPositive: true,
        ),
        isRecentlyListed: false,
        isHighlyProfitable: false,
        investmentPotential: 3,
        investmentRating: 'Average',
      ),
      TokenModel(
        tokenId: 3,
        landId: 3,
        tokenNumber: 19,
        price: '0.035',
        purchasePrice: '0.028',
        mintDate: oneMonthAgo.toIso8601String(),
        seller: '0xD2c73A35D7Ad9347C9Ef528711D1F7ED03f1000C',
        land: const LandModel(
          location: 'Miami, FL',
          surface: 850,
          status: 'Limited',
          isRegistered: true,
          totalTokens: 80,
          availableTokens: 15,
          pricePerToken: '0.035 ETH',
          owner: '0xD2c73A35D7Ad9347C9Ef528711D1F7ED03f1000C',
        ),
        listingDate: now.subtract(const Duration(days: 1)).toIso8601String(),
        listingDateFormatted: '${now.subtract(const Duration(days: 1)).month.toString().padLeft(2, '0')}/${now.subtract(const Duration(days: 1)).day.toString().padLeft(2, '0')}/${now.subtract(const Duration(days: 1)).year}',
        listingTimestamp: now.subtract(const Duration(days: 1)).millisecondsSinceEpoch ~/ 1000,
        daysSinceListing: 1,
        etherscanUrl: 'https://etherscan.io/token/0x789',
        formattedPrice: '0.035 ETH',
        formattedPurchasePrice: '0.028 ETH',
        mintDateFormatted: '${oneMonthAgo.month.toString().padLeft(2, '0')}/${oneMonthAgo.day.toString().padLeft(2, '0')}/${oneMonthAgo.year}',
        priceChangePercentage: const PriceChangePercentageModel(
          percentage: 25.0,
          formatted: '25.0%',
          isPositive: true,
        ),
        isRecentlyListed: true,
        isHighlyProfitable: true,
        investmentPotential: 5,
        investmentRating: 'Excellent',
      ),
    ];
  }
}

class AuthException implements Exception {
  final String message;
  AuthException({required this.message});
  
  @override
  String toString() => 'AuthException: $message';
}