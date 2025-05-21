import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:the_boost/core/network/graphql_client.dart';
import 'package:the_boost/core/services/secure_storage_service.dart';
import 'package:the_boost/features/auth/data/graphql/preferences_queries.dart';
import 'package:the_boost/features/auth/domain/entities/user_preferences.dart';

abstract class PreferencesRemoteDataSource {
  Future<UserPreferences?> getUserPreferences();
  Future<UserPreferences> updateUserPreferences(UserPreferences preferences);
  Future<List<String>> getAvailableLandTypes(); // Added new method
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
      id: data['_id'] as String?, // Parse from _id key
      minPrice: (data['minPrice'] as num?)?.toDouble() ?? 0.0,
      maxPrice: (data['maxPrice'] as num?)?.toDouble() ?? double.infinity,
      preferredLocations: (data['preferredLocations'] as List<dynamic>?)
              ?.map((loc) => loc.toString())
              .toList() ??
          [],
      preferredLandTypes: (data['preferredLandTypes'] as List<dynamic>?)
              ?.map((type) => type.toString())
              .toList() ??
          ["Residential"], // Ensure not empty
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
    // Get the existing preferences first to have the id value if needed
    final existingPrefs = await getUserPreferences();
    // Use null-aware operator instead of explicit null check
    final String? prefsId = existingPrefs?.id;

    final GraphQLClient client = GraphQLService.getClientWithToken(accessToken);
    final MutationOptions options = MutationOptions(
      document: gql(PreferencesQueries.updateUserPreferences),
      variables: {
        'preferences': {
          '_id': prefsId, // Include the id if available
          'minPrice': preferences.minPrice,
          'maxPrice': preferences.maxPrice == double.infinity ? 1000000 : preferences.maxPrice,
          'preferredLocations': preferences.preferredLocations,
          'preferredLandTypes': preferences.preferredLandTypes.isEmpty ? ["Residential"] : preferences.preferredLandTypes, // Ensure not empty
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
      id: data['_id'] as String?, // Parse the id from _id
      minPrice: (data['minPrice'] as num?)?.toDouble() ?? 0.0,
      maxPrice: (data['maxPrice'] as num?)?.toDouble() ?? double.infinity,
      preferredLocations: (data['preferredLocations'] as List<dynamic>?)
              ?.map((loc) => loc.toString())
              .toList() ??
          [],
      preferredLandTypes: (data['preferredLandTypes'] as List<dynamic>?)
              ?.map((type) => type.toString())
              .toList() ??
          ["Residential"], // Ensure not empty
      maxDistanceKm: (data['maxDistanceKm'] as num?)?.toDouble() ?? 50.0,
      notificationsEnabled: data['notificationsEnabled'] as bool? ?? true,
      lastUpdated: DateTime.tryParse(data['lastUpdated'] as String? ?? '') ?? DateTime.now(),
    );
  } catch (e) {
    print('[${DateTime.now()}] PreferencesRemoteDataSource: ❌ Error updating preferences: $e');
    throw Exception('Failed to update preferences: $e');
  }
}

  // Implement the new method for land types
  @override
  Future<List<String>> getAvailableLandTypes() async {
    final String? accessToken = await _secureStorage.getAccessToken();
    if (accessToken == null) {
      print('[${DateTime.now()}] PreferencesRemoteDataSource: ❌ No access token found');
      return [];
    }

    try {
      final GraphQLClient client = GraphQLService.getClientWithToken(accessToken);
      final QueryOptions options = QueryOptions(
        document: gql(PreferencesQueries.getAvailableLandTypes),
        fetchPolicy: FetchPolicy.networkOnly,
      );

      final QueryResult result = await client.query(options);

      if (result.hasException) {
        print('[${DateTime.now()}] PreferencesRemoteDataSource: ❌ GraphQL error: ${result.exception}');
        return [];
      }

      final data = result.data?['getAvailableLandTypes'];
      if (data == null) {
        print('[${DateTime.now()}] PreferencesRemoteDataSource: ℹ️ No land types found');
        return [];
      }

      print('[${DateTime.now()}] PreferencesRemoteDataSource: ✅ Land types fetched');
      return (data as List<dynamic>).map((type) => type.toString()).toList();
    } catch (e) {
      print('[${DateTime.now()}] PreferencesRemoteDataSource: ❌ Error fetching land types: $e');
      return [];
    }
  }
}