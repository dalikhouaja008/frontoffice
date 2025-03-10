import 'package:graphql_flutter/graphql_flutter.dart';
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
  final GraphQLClient _client;
  final SecureStorageService _secureStorage;

  PreferencesRemoteDataSourceImpl({
    required GraphQLClient client,
    required SecureStorageService secureStorage,
  }) : _client = client, _secureStorage = secureStorage;

  @override
  Future<UserPreferences?> getUserPreferences() async {
    final String? accessToken = await _secureStorage.getAccessToken();
    if (accessToken == null) {
      print('PreferencesRemoteDataSource: ❌ No access token found');
      return null;
    }

    try {
      final QueryOptions options = QueryOptions(
        document: gql(PreferencesQueries.getUserPreferences),
        fetchPolicy: FetchPolicy.networkOnly,
      );

      final QueryResult result = await _client.query(options);

      if (result.hasException) {
        print('PreferencesRemoteDataSource: ❌ GraphQL error fetching preferences');
        print(result.exception.toString());
        return null;
      }

      final data = result.data?['getUserPreferences'];
      if (data == null) {
        print('PreferencesRemoteDataSource: ℹ️ No preferences found');
        return null;
      }

      print('PreferencesRemoteDataSource: ✅ Preferences fetched successfully');
      
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
      print('PreferencesRemoteDataSource: ❌ Error fetching preferences: $e');
      return null;
    }
  }

  @override
  Future<UserPreferences> updateUserPreferences(UserPreferences preferences) async {
    final String? accessToken = await _secureStorage.getAccessToken();
    if (accessToken == null) {
      print('PreferencesRemoteDataSource: ❌ No access token found');
      throw Exception('Authentication required');
    }

    try {
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

      final QueryResult result = await _client.mutate(options);

      if (result.hasException) {
        print('PreferencesRemoteDataSource: ❌ GraphQL error updating preferences');
        print(result.exception.toString());
        throw Exception('Failed to update preferences: ${result.exception.toString()}');
      }

      final data = result.data?['updateUserPreferences'];
      if (data == null) {
        print('PreferencesRemoteDataSource: ❌ No data returned after update');
        throw Exception('Failed to update preferences');
      }

      print('PreferencesRemoteDataSource: ✅ Preferences updated successfully');
      
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
      print('PreferencesRemoteDataSource: ❌ Error updating preferences: $e');
      throw Exception('Failed to update preferences: $e');
    }
  }

  @override
  Future<List<LandType>> getAvailableLandTypes() async {
    try {
      final QueryOptions options = QueryOptions(
        document: gql(PreferencesQueries.getAvailableLandTypes),
        fetchPolicy: FetchPolicy.networkOnly,
      );

      final QueryResult result = await _client.query(options);

      if (result.hasException) {
        print('PreferencesRemoteDataSource: ❌ GraphQL error fetching land types');
        print(result.exception.toString());
        return LandType.values;  // Return defaults if error
      }

      final data = result.data?['getAvailableLandTypes'] as List<dynamic>?;
      if (data == null || data.isEmpty) {
        print('PreferencesRemoteDataSource: ❌ No land types returned');
        return LandType.values;  // Return defaults if no data
      }

      print('PreferencesRemoteDataSource: ✅ Land types fetched successfully');
      
      return data.map((type) => _stringToLandType(type.toString())).toList();
    } catch (e) {
      print('PreferencesRemoteDataSource: ❌ Error fetching land types: $e');
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