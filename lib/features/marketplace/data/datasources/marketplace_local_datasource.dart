import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../models/token_model.dart';

abstract class MarketplaceLocalDataSource {
  Future<List<TokenModel>> getLastCachedListings();
  Future<List<TokenModel>> getLastListings(); // Added alias method to match repository calls
  Future<TokenModel> getListingById(int tokenId);
  Future<void> cacheListings(List<TokenModel> listings);
  Future<void> cacheListingDetails(TokenModel token);
}

class MarketplaceLocalDataSourceImpl implements MarketplaceLocalDataSource {
  final SharedPreferences sharedPreferences;
  final String _cachedListingsKey = 'CACHED_LISTINGS';
  final String _cachedTokenPrefix = 'CACHED_TOKEN_';

  MarketplaceLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<TokenModel>> getLastCachedListings() async {
    try {
      final jsonString = sharedPreferences.getString(_cachedListingsKey);
      debugPrint('[2025-05-05 07:41:57] Reading cached listings: ${jsonString?.length ?? 0} bytes');
      
      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> decoded = json.decode(jsonString);
        final listings = decoded.map<TokenModel>((item) => TokenModel.fromJson(item)).toList();
        debugPrint('[2025-05-05 07:41:57] Successfully retrieved ${listings.length} cached listings');
        return listings;
      } else {
        debugPrint('[2025-05-05 07:41:57] No cached listings found');
        throw CacheException(message: 'No cached listings found');
      }
    } catch (e) {
      debugPrint('[2025-05-05 07:41:57] Error retrieving cached listings: $e');
      throw CacheException(message: 'Failed to retrieve cached listings: $e');
    }
  }

  // Alias method to match what repository is calling
  @override
  Future<List<TokenModel>> getLastListings() => getLastCachedListings();

  @override
  Future<TokenModel> getListingById(int tokenId) async {
    try {
      final jsonString = sharedPreferences.getString('$_cachedTokenPrefix$tokenId');
      debugPrint('[2025-05-05 07:41:57] Reading cached token $tokenId: ${jsonString != null}');
      
      if (jsonString != null) {
        final token = TokenModel.fromJson(json.decode(jsonString));
        debugPrint('[2025-05-05 07:41:57] Successfully retrieved cached token $tokenId');
        return token;
      } else {
        debugPrint('[2025-05-05 07:41:57] No cached token found for ID $tokenId');
        throw CacheException(message: 'No cached token found for ID $tokenId');
      }
    } catch (e) {
      debugPrint('[2025-05-05 07:41:57] Error retrieving cached token $tokenId: $e');
      throw CacheException(message: 'Error retrieving cached token $tokenId: $e');
    }
  }

  @override
  Future<void> cacheListings(List<TokenModel> listings) async {
    try {
      debugPrint('[2025-05-05 07:41:57] Caching ${listings.length} listings');
      final List<Map<String, dynamic>> jsonList = listings
          .map((token) => token.toJson())
          .toList();
      
      await sharedPreferences.setString(_cachedListingsKey, json.encode(jsonList));
      debugPrint('[2025-05-05 07:41:57] Successfully cached ${listings.length} listings');
    } catch (e) {
      debugPrint('[2025-05-05 07:41:57] Error caching listings: $e');
      // We don't throw here to prevent crashes during caching operations
    }
  }

  @override
  Future<void> cacheListingDetails(TokenModel token) async {
    try {
      debugPrint('[2025-05-05 07:41:57] Caching token ${token.tokenId}');
      final jsonData = token.toJson();
      
      await sharedPreferences.setString(
        '$_cachedTokenPrefix${token.tokenId}',
        json.encode(jsonData),
      );
      debugPrint('[2025-05-05 07:41:57] Successfully cached token ${token.tokenId}');
    } catch (e) {
      debugPrint('[2025-05-05 07:41:57] Error caching token ${token.tokenId}: $e');
      // We don't throw here to prevent crashes during caching operations
    }
  }
  
  // Additional helper method to clear all cached listings
  Future<bool> clearAllCachedListings() async {
    try {
      debugPrint('[2025-05-05 07:41:57] Clearing all cached listings');
      // Remove the main listings cache
      await sharedPreferences.remove(_cachedListingsKey);
      
      // Get all keys and clear any token-specific caches
      final allKeys = sharedPreferences.getKeys();
      for (final key in allKeys) {
        if (key.startsWith(_cachedTokenPrefix)) {
          await sharedPreferences.remove(key);
        }
      }
      
      debugPrint('[2025-05-05 07:41:57] Successfully cleared all cached listings');
      return true;
    } catch (e) {
      debugPrint('[2025-05-05 07:41:57] Error clearing cached listings: $e');
      return false;
    }
  }
}