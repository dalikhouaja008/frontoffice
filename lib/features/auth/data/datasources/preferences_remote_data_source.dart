// lib/features/auth/data/datasources/preferences_remote_data_source.dart
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:the_boost/core/network/graphql_client.dart';
import 'package:the_boost/core/services/secure_storage_service.dart';
import 'package:the_boost/features/auth/data/graphql/preferences_queries.dart';
import 'package:the_boost/features/auth/domain/entities/user_preferences.dart';

abstract class PreferencesRemoteDataSource {
  Future<UserPreferences?> getUserPreferences();
  Future<UserPreferences> updateUserPreferences(UserPreferences preferences);
}

class PreferencesRemoteDataSourceImpl implements PreferencesRemoteDataSource {
  final SecureStorageService _secureStorage;

  PreferencesRemoteDataSourceImpl({required SecureStorageService secureStorage})
      : _secureStorage = secureStorage;

  @override
  Future<UserPreferences?> getUserPreferences() async {
    final String? accessToken = await _secureStorage.getAccessToken();
    if (accessToken == null) {
      print('[${DateTime.now()}] PreferencesRemoteDataSource: ❌ No access token found');
      return null;
    }

    try {
      final GraphQLClient client = GraphQLService.getClientWithToken(accessToken);
      final QueryOptions options = QueryOptions(
        document: gql(PreferencesQueries.getUserPreferences),
        fetchPolicy: FetchPolicy.networkOnly,
      );

      final QueryResult result = await client.query(options);

      if (result.hasException) {
        print('[${DateTime.now()}] PreferencesRemoteDataSource: ❌ GraphQL error: ${result.exception}');
        return null;
      }

      final data = result.data?['getUserPreferences'];
      if (data == null) {
        print('[${DateTime.now()}] PreferencesRemoteDataSource: ℹ️ No preferences found');
        return null;
      }

      print('[${DateTime.now()}] PreferencesRemoteDataSource: ✅ Preferences fetched');
      return UserPreferences(
        minPrice: (data['minPrice'] as num?)?.toDouble() ?? 0.0,
        maxPrice: (data['maxPrice'] as num?)?.toDouble() ?? double.infinity,
        preferredLocations: (data['preferredLocations'] as List<dynamic>?)
                ?.map((loc) => loc.toString())
                .toList() ??
            [],
        maxDistanceKm: (data['maxDistanceKm'] as num?)?.toDouble() ?? 50.0,
        notificationsEnabled: data['notificationsEnabled'] as bool? ?? true,
        lastUpdated: DateTime.tryParse(data['lastUpdated'] as String? ?? '') ?? DateTime.now(),
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
      final GraphQLClient client = GraphQLService.getClientWithToken(accessToken);
      final MutationOptions options = MutationOptions(
        document: gql(PreferencesQueries.updateUserPreferences),
        variables: {
          'preferences': {
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
        print('[${DateTime.now()}] PreferencesRemoteDataSource: ❌ GraphQL error: ${result.exception}');
        throw Exception('Failed to update preferences: ${result.exception}');
      }

      final data = result.data?['updateUserPreferences'];
      if (data == null) {
        print('[${DateTime.now()}] PreferencesRemoteDataSource: ❌ No data returned');
        throw Exception('Failed to update preferences');
      }

      print('[${DateTime.now()}] PreferencesRemoteDataSource: ✅ Preferences updated');
      return UserPreferences(
        minPrice: (data['minPrice'] as num?)?.toDouble() ?? 0.0,
        maxPrice: (data['maxPrice'] as num?)?.toDouble() ?? double.infinity,
        preferredLocations: (data['preferredLocations'] as List<dynamic>?)
                ?.map((loc) => loc.toString())
                .toList() ??
            [],
        maxDistanceKm: (data['maxDistanceKm'] as num?)?.toDouble() ?? 50.0,
        notificationsEnabled: data['notificationsEnabled'] as bool? ?? true,
        lastUpdated: DateTime.tryParse(data['lastUpdated'] as String? ?? '') ?? DateTime.now(),
      );
    } catch (e) {
      print('[${DateTime.now()}] PreferencesRemoteDataSource: ❌ Error updating preferences: $e');
      throw Exception('Failed to update preferences: $e');
    }
  }
}