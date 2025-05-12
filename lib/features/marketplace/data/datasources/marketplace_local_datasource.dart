import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../models/token_model.dart';

abstract class MarketplaceLocalDataSource {
  Future<List<TokenModel>> getLastTokenListings();
  Future<void> cacheTokenListings(List<TokenModel> tokenListings);
  Future<TokenModel> getTokenDetails(int tokenId);
  Future<void> cacheTokenDetails(TokenModel token);
  Future<void> removeTokenDetails(int tokenId);
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
        throw CacheException(message: 'Error parsing cached token listings');
      }
    } else {
      debugPrint('[${DateTime.now()}] No cached listings found');
      throw CacheException(message: 'No cached token listings found');
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
      await sharedPreferences.setInt(
        'CACHED_TOKEN_LISTINGS_TIMESTAMP',
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      debugPrint('[${DateTime.now()}] Error caching listings: $e');
      throw CacheException(message: 'Error caching token listings');
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
        throw CacheException(message: 'Error parsing cached token $tokenId');
      }
    } else {
      debugPrint('[${DateTime.now()}] No cached token $tokenId found');
      throw CacheException(message: 'No cached token details found for ID $tokenId');
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
      await sharedPreferences.setInt(
        'CACHED_TOKEN_${token.tokenId}_TIMESTAMP',
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      debugPrint('[${DateTime.now()}] Error caching token details: $e');
      throw CacheException(message: 'Error caching token details for ID ${token.tokenId}');
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

  bool isCacheExpired(int timestamp, {int ttlMinutes = 5}) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final expiryTime = timestamp + (ttlMinutes * 60 * 1000);
    return now > expiryTime;
  }
}