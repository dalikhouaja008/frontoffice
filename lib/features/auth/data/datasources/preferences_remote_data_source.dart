// lib/features/auth/data/datasources/preferences_remote_data_source_impl.dart
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:the_boost/core/network/graphql_client.dart';
import 'package:the_boost/core/services/secure_storage_service.dart';
import 'package:the_boost/features/auth/data/graphql/preferences_queries.dart';
import 'package:the_boost/features/auth/data/models/land_model.dart';
import 'package:the_boost/features/auth/domain/entities/user_preferences.dart';

abstract class PreferencesRemoteDataSource {
  Future<UserPreferences?> getUserPreferences();
  Future<UserPreferences> updateUserPreferences(UserPreferences preferences);
  Future<List<LandType>> getAvailableLandTypes();
}

class PreferencesRemoteDataSourceImpl implements PreferencesRemoteDataSource {
  final SecureStorageService _secureStorage;

  PreferencesRemoteDataSourceImpl({
    required SecureStorageService secureStorage,
  }) : _secureStorage = secureStorage;

  @override
  Future<UserPreferences?> getUserPreferences() async {
    final String? accessToken = await _secureStorage.getAccessToken();
    if (accessToken == null) {
      print('[${DateTime.now()}] PreferencesRemoteDataSource: ❌ No access token found');
      return null;
    }

    try {
      // Get authenticated GraphQL client
      final GraphQLClient client = GraphQLService.getClientWithToken(accessToken);

      final QueryOptions options = QueryOptions(
        document: gql(PreferencesQueries.getUserPreferences),
        fetchPolicy: FetchPolicy.networkOnly,
      );

      final QueryResult result = await client.query(options);

      if (result.hasException) {
        print('[${DateTime.now()}] PreferencesRemoteDataSource: ❌ GraphQL error fetching preferences');
        print(result.exception.toString());
        return null;
      }

      final data = result.data?['getUserPreferences'];
      if (data == null) {
        print('[${DateTime.now()}] PreferencesRemoteDataSource: ℹ️ No preferences found');
        return null;
      }

      print('[${DateTime.now()}] PreferencesRemoteDataSource: ✅ Preferences fetched successfully');
      
      // Convert from API format to domain entity
      return UserPreferences(
        preferredLandTypes: (data['preferredLandTypes'] as List<dynamic>)
            .map((type) => _stringToLandType(type.toString()))
            .toList(),
        minPrice: data['minPrice'] as double,
        maxPrice: data['maxPrice'] as double,
        preferredLocations: (data['preferredLocations'] as List<dynamic>)
            .map((loc) => loc.toString())
            .toList(),
        maxDistanceKm: data['maxDistanceKm'] as double,
        notificationsEnabled: data['notificationsEnabled'] as bool,
        lastUpdated: DateTime.parse(data['lastUpdated']),
      );
    } catch (e) {
      print('[${DateTime.now()}] PreferencesRemoteDataSource: ❌ Error fetching preferences: $e');
      return null;
    }
  }

  @override
  Future<UserPreferences> updateUserPreferences(UserPreferences preferences) async {
    final String? accessToken = await _secureStorage.getAccessToken();
    if (accessToken == null) {
      print('[${DateTime.now()}] PreferencesRemoteDataSource: ❌ No access token found');
      throw Exception('Authentication required');
    }

    try {
      // Get authenticated GraphQL client
      final GraphQLClient client = GraphQLService.getClientWithToken(accessToken);

      final MutationOptions options = MutationOptions(
        document: gql(PreferencesQueries.updateUserPreferences),
        variables: {
          'preferences': {
            'preferredLandTypes': preferences.preferredLandTypes
                .map((type) => type.toString().split('.').last)
                .toList(),
            'minPrice': preferences.minPrice,
            'maxPrice': preferences.maxPrice == double.infinity ? 1000000 : preferences.maxPrice,
            'preferredLocations': preferences.preferredLocations,
            'maxDistanceKm': preferences.maxDistanceKm,
            'notificationsEnabled': preferences.notificationsEnabled,
          }
        },
      );

      final QueryResult result = await client.mutate(options);

      if (result.hasException) {
        print('[${DateTime.now()}] PreferencesRemoteDataSource: ❌ GraphQL error updating preferences');
        print(result.exception.toString());
        throw Exception('Failed to update preferences: ${result.exception.toString()}');
      }

      final data = result.data?['updateUserPreferences'];
      if (data == null) {
        print('[${DateTime.now()}] PreferencesRemoteDataSource: ❌ No data returned after update');
        throw Exception('Failed to update preferences');
      }

      print('[${DateTime.now()}] PreferencesRemoteDataSource: ✅ Preferences updated successfully');
      
      // Convert from API format to domain entity
      return UserPreferences(
        preferredLandTypes: (data['preferredLandTypes'] as List<dynamic>)
            .map((type) => _stringToLandType(type.toString()))
            .toList(),
        minPrice: data['minPrice'] as double,
        maxPrice: data['maxPrice'] as double,
        preferredLocations: (data['preferredLocations'] as List<dynamic>)
            .map((loc) => loc.toString())
            .toList(),
        maxDistanceKm: data['maxDistanceKm'] as double,
        notificationsEnabled: data['notificationsEnabled'] as bool,
        lastUpdated: DateTime.parse(data['lastUpdated']),
      );
    } catch (e) {
      print('[${DateTime.now()}] PreferencesRemoteDataSource: ❌ Error updating preferences: $e');
      throw Exception('Failed to update preferences: $e');
    }
  }

  @override
  Future<List<LandType>> getAvailableLandTypes() async {
    try {
      // Get GraphQL client (doesn't need authentication)
      final GraphQLClient client = GraphQLService.client;

      final QueryOptions options = QueryOptions(
        document: gql(PreferencesQueries.getAvailableLandTypes),
        fetchPolicy: FetchPolicy.networkOnly,
      );

      final QueryResult result = await client.query(options);

      if (result.hasException) {
        print('[${DateTime.now()}] PreferencesRemoteDataSource: ❌ GraphQL error fetching land types');
        print(result.exception.toString());
        return LandType.values;  // Return defaults if error
      }

      final data = result.data?['getAvailableLandTypes'] as List<dynamic>?;
      if (data == null || data.isEmpty) {
        print('[${DateTime.now()}] PreferencesRemoteDataSource: ❌ No land types returned');
        return LandType.values;  // Return defaults if no data
      }

      print('[${DateTime.now()}] PreferencesRemoteDataSource: ✅ Land types fetched successfully');
      
      return data.map((type) => _stringToLandType(type.toString())).toList();
    } catch (e) {
      print('[${DateTime.now()}] PreferencesRemoteDataSource: ❌ Error fetching land types: $e');
      return LandType.values;  // Return defaults if error
    }
  }
  
  // Helper method to convert string to LandType enum
  LandType _stringToLandType(String type) {
    try {
      // First try exact match (with LandType. prefix)
      if (type.startsWith('LandType.')) {
        final enumName = type.split('.').last;
        return LandType.values.firstWhere(
          (e) => e.toString() == 'LandType.$enumName',
          orElse: () => LandType.RESIDENTIAL,
        );
      }
      
      // Then try with just the enum value name
      return LandType.values.firstWhere(
        (e) => e.toString().split('.').last == type,
        orElse: () => LandType.RESIDENTIAL,
      );
    } catch (e) {
      print('Error converting string to LandType: $e');
      return LandType.RESIDENTIAL;  // Default
    }
  }
}