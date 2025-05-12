import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../models/token_model.dart';

abstract class MarketplaceLocalDataSource {
  /// Gets the cached list of token listings
  Future<List<TokenModel>> getLastTokenListings();
  
  /// Caches a list of token listings
  Future<void> cacheTokenListings(List<TokenModel> tokenListings);
  
  /// Gets cached details for a specific token
  Future<TokenModel> getTokenDetails(int tokenId);
  
  /// Caches details for a specific token
  Future<void> cacheTokenDetails(TokenModel token);
  
  /// Removes cached details for a token
  Future<void> removeTokenDetails(int tokenId);
  
  /// Invalidates the entire listings cache
  Future<void> invalidateListingsCache();
}

class MarketplaceLocalDataSourceImpl implements MarketplaceLocalDataSource {
  final SharedPreferences sharedPreferences;
  
  MarketplaceLocalDataSourceImpl({required this.sharedPreferences});
  
  @override
  Future<List<TokenModel>> getLastTokenListings() async {
    final jsonString = sharedPreferences.getString('CACHED_TOKEN_LISTINGS');
    if (jsonString != null) {
      try {
        debugPrint('[${DateTime.now()}] Retrieving cached listings');
        final List<dynamic> decodedJsonList = json.decode(jsonString);
        return decodedJsonList
            .map((jsonMap) => TokenModel.fromJson(jsonMap))
            .toList();
      } catch (e) {
        debugPrint('[${DateTime.now()}] Error parsing cached listings: $e');
        throw CacheException();
      }
    } else {
      debugPrint('[${DateTime.now()}] No cached listings found');
      throw CacheException();
    }
  }
  
  @override
  Future<void> cacheTokenListings(List<TokenModel> tokenListings) async {
    try {
      debugPrint('[${DateTime.now()}] Caching ${tokenListings.length} listings');
      final List<Map<String, dynamic>> jsonList = 
          tokenListings.map((token) => token.toJson()).toList();
      await sharedPreferences.setString(
        'CACHED_TOKEN_LISTINGS',
        json.encode(jsonList),
      );
      // Also store cache timestamp
      await sharedPreferences.setInt(
        'CACHED_TOKEN_LISTINGS_TIMESTAMP', 
        DateTime.now().millisecondsSinceEpoch
      );
    } catch (e) {
      debugPrint('[${DateTime.now()}] Error caching listings: $e');
      throw CacheException();
    }
  }
  
  @override
  Future<TokenModel> getTokenDetails(int tokenId) async {
    final jsonString = sharedPreferences.getString('CACHED_TOKEN_$tokenId');
    if (jsonString != null) {
      try {
        debugPrint('[${DateTime.now()}] Retrieving cached token $tokenId');
        return TokenModel.fromJson(json.decode(jsonString));
      } catch (e) {
        debugPrint('[${DateTime.now()}] Error parsing cached token $tokenId: $e');
        throw CacheException();
      }
    } else {
      debugPrint('[${DateTime.now()}] No cached token $tokenId found');
      throw CacheException();
    }
  }
  
  @override
  Future<void> cacheTokenDetails(TokenModel token) async {
    try {
      debugPrint('[${DateTime.now()}] Caching token ${token.tokenId}');
      await sharedPreferences.setString(
        'CACHED_TOKEN_${token.tokenId}',
        json.encode(token.toJson()),
      );
      // Also store cache timestamp
      await sharedPreferences.setInt(
        'CACHED_TOKEN_${token.tokenId}_TIMESTAMP',
        DateTime.now().millisecondsSinceEpoch
      );
    } catch (e) {
      debugPrint('[${DateTime.now()}] Error caching token details: $e');
      throw CacheException();
    }
  }
  
  @override
  Future<void> removeTokenDetails(int tokenId) async {
    debugPrint('[${DateTime.now()}] Removing cached token $tokenId');
    await sharedPreferences.remove('CACHED_TOKEN_$tokenId');
    await sharedPreferences.remove('CACHED_TOKEN_${tokenId}_TIMESTAMP');
  }
  
  @override
  Future<void> invalidateListingsCache() async {
    debugPrint('[${DateTime.now()}] Invalidating listings cache');
    await sharedPreferences.remove('CACHED_TOKEN_LISTINGS');
    await sharedPreferences.remove('CACHED_TOKEN_LISTINGS_TIMESTAMP');
  }
  
  // Helper method to check if cache is expired (5 minutes TTL)
  bool isCacheExpired(int timestamp, {int ttlMinutes = 5}) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final expiryTime = timestamp + (ttlMinutes * 60 * 1000);
    return now > expiryTime;
  }
}