import 'dart:convert';
import 'package:the_boost/core/di/dependency_injection.dart';
import 'package:the_boost/core/services/land_service.dart';
import 'package:the_boost/core/services/notification_service.dart';
import 'package:the_boost/core/services/secure_storage_service.dart';
import 'package:the_boost/features/auth/data/models/land_model.dart';
import 'package:the_boost/features/auth/domain/entities/notification.dart';
import 'package:the_boost/features/auth/domain/entities/user_preferences.dart';
import 'package:the_boost/features/auth/domain/use_cases/preferences/get_preferences_usecase.dart';
import 'package:the_boost/features/auth/domain/use_cases/preferences/save_preferences_usecase.dart';

class PreferencesService {
  final SecureStorageService _storageService;
  final NotificationService _notificationService;
  final LandService _landService;

  // Cache variables
  UserPreferences? _cachedPreferences;
  String? _cachedUserId;
  DateTime? _cacheTimestamp;

  // Cache timeout (10 minutes)
  static const int _cacheTimeoutMinutes = 10;

  PreferencesService({
    SecureStorageService? storageService,
    NotificationService? notificationService,
    LandService? landService,
  })  : _storageService = storageService ?? getIt<SecureStorageService>(),
        _notificationService = notificationService ?? getIt<NotificationService>(),
        _landService = landService ?? getIt<LandService>();

  /// Key for storing user preferences
  String _getPreferencesKey(String userId) => 'user_preferences_$userId';

  /// Get preferences from the API or local storage as fallback
  Future<UserPreferences?> getPreferences(String userId) async {
    try {
      // Check if we have a valid cached value
      if (_cachedUserId == userId &&
          _cachedPreferences != null &&
          _cacheTimestamp != null) {
        final now = DateTime.now();
        final cacheAge = now.difference(_cacheTimestamp!).inMinutes;

        if (cacheAge < _cacheTimeoutMinutes) {
          print('[${DateTime.now()}] PreferencesService: ✅ Using cached preferences'
              '\n└─ User ID: $userId'
              '\n└─ Cache age: $cacheAge minutes');
          return _cachedPreferences;
        }
      }

      print('[${DateTime.now()}] PreferencesService: 🌐 Fetching preferences from API'
          '\n└─ User ID: $userId');

      // Try to get from API first
      final getPreferencesUseCase = getIt<GetPreferencesUseCase>();
      final remotePrefs = await getPreferencesUseCase.execute();

      if (remotePrefs != null) {
        // Update cache
        _cachedPreferences = remotePrefs;
        _cachedUserId = userId;
        _cacheTimestamp = DateTime.now();

        print('[${DateTime.now()}] PreferencesService: ✅ Preferences loaded from API'
            '\n└─ User ID: $userId'
            '\n└─ Land Types: ${remotePrefs.preferredLandTypes.length}'
            '\n└─ Price Range: \$${remotePrefs.minPrice.toInt()}-\$${remotePrefs.maxPrice == double.infinity ? "∞" : remotePrefs.maxPrice.toInt()}'
            '\n└─ Locations: ${remotePrefs.preferredLocations.join(", ")}');

        return remotePrefs;
      }

      // If API fails, try loading from local backup
      return await _loadLocalBackup(userId);
    } catch (e) {
      print('[${DateTime.now()}] PreferencesService: ❌ Error loading preferences'
          '\n└─ User ID: $userId'
          '\n└─ Error: $e');

      return null;
    }
  }

  /// Save preferences to the API and local backup
  Future<void> savePreferences(String userId, UserPreferences preferences) async {
    try {
      print('[${DateTime.now()}] PreferencesService: 🌐 Saving preferences to API'
          '\n└─ User ID: $userId'
          '\n└─ Land Types: ${preferences.preferredLandTypes.length}'
          '\n└─ Price Range: \$${preferences.minPrice.toInt()}-\$${preferences.maxPrice == double.infinity ? "∞" : preferences.maxPrice.toInt()}'
          '\n└─ Locations: ${preferences.preferredLocations.join(", ")}');

      // Send to API
      final savePreferencesUseCase = getIt<SavePreferencesUseCase>();
      final updatedPrefs = await savePreferencesUseCase.execute(preferences);

      // Update cache with the response from the API
      _cachedPreferences = updatedPrefs;
      _cachedUserId = userId;
      _cacheTimestamp = DateTime.now();

      print('[${DateTime.now()}] PreferencesService: ✅ Preferences saved to API'
          '\n└─ User ID: $userId');

      // Also update local backup
      await _storeLocalBackup(userId, updatedPrefs);

      // Check for matches after updating preferences
      await _checkForMatchingLands(userId, updatedPrefs);
    } catch (e) {
      print('[${DateTime.now()}] PreferencesService: ⚠️ API save failed, saving locally only'
          '\n└─ User ID: $userId'
          '\n└─ Error: $e');

      // Save locally as backup
      await _storeLocalBackup(userId, preferences);

      // Still update cache
      _cachedPreferences = preferences;
      _cachedUserId = userId;
      _cacheTimestamp = DateTime.now();

      rethrow; // Re-throw for UI handling
    }
  }

  /// Delete preferences
  Future<void> deletePreferences(String userId) async {
    try {
      print('[${DateTime.now()}] PreferencesService: 🗑 Deleting preferences'
          '\n└─ User ID: $userId');

      // Clear cache
      _cachedPreferences = null;
      _cachedUserId = null;
      _cacheTimestamp = null;

      // Delete from local storage
      await _storageService.delete(key: _getPreferencesKey(userId));
    } catch (e) {
      print('[${DateTime.now()}] PreferencesService: ❌ Error deleting preferences'
          '\n└─ User ID: $userId'
          '\n└─ Error: $e');
      rethrow;
    }
  }

  /// Check if user has configured preferences
  Future<bool> hasPreferences(String userId) async {
    try {
      // Try to get preferences from API first
      final preferences = await getPreferences(userId);
      return preferences != null && preferences.isConfigured;
    } catch (e) {
      print('[${DateTime.now()}] PreferencesService: ❌ Error checking preferences'
          '\n└─ User ID: $userId'
          '\n└─ Error: $e');
      // Fall back to local storage check
      return await _storageService.containsKey(key: _getPreferencesKey(userId));
    }
  }

  /// Check for lands that match preferences and send notifications
  Future<void> _checkForMatchingLands(String userId, UserPreferences preferences) async {
    if (!preferences.notificationsEnabled) return;

    try {
      // Fetch lands dynamically from the backend
      final List<Land> lands = await _landService.fetchLands();

      // Pre-process preferred locations for efficiency
      final preferredLocationsLower = preferences.preferredLocations.map((loc) => loc.toLowerCase()).toList();

      // Filter lands based on preferences
      final List<Land> matchingLands = lands.where((land) {
        // Check land type
        if (!preferences.preferredLandTypes.contains(land.type)) return false;

        // Check price range
        if (land.price < preferences.minPrice ||
            (preferences.maxPrice != double.infinity && land.price > preferences.maxPrice)) {
          return false;
        }

        // Check location (substring match)
        if (preferredLocationsLower.isNotEmpty) {
          bool locationMatch = false;
          for (final String location in preferredLocationsLower) {
            if (land.location.toLowerCase().contains(location)) {
              locationMatch = true;
              break;
            }
          }
          if (!locationMatch) return false;
        }

        return true;
      }).toList();

      // Create notifications for matching lands
      for (final Land land in matchingLands) {
        final notification = UserNotification.landMatch(land);
        await _notificationService.addNotification(notification);

        print('[${DateTime.now()}] PreferencesService: 🔔 Created land match notification'
            '\n└─ User ID: $userId'
            '\n└─ Land ID: ${land.id}'
            '\n└─ Title: ${land.title}'
            '\n└─ Price: ${land.price}'
            '\n└─ Location: ${land.location}');
      }

      if (matchingLands.isNotEmpty) {
        print('[${DateTime.now()}] PreferencesService: ✅ Found ${matchingLands.length} matching lands'
            '\n└─ User ID: $userId');
      }
    } catch (e) {
      print('[${DateTime.now()}] PreferencesService: ❌ Error checking matching lands'
          '\n└─ User ID: $userId'
          '\n└─ Error: $e');
    }
  }

  /// Load local backup of preferences
  Future<UserPreferences?> _loadLocalBackup(String userId) async {
    try {
      final String? storedData = await _storageService.read(key: _getPreferencesKey(userId));

      if (storedData == null) {
        print('[${DateTime.now()}] PreferencesService: ❌ No local backup found'
            '\n└─ User ID: $userId');
        return null;
      }

      final Map<String, dynamic> jsonData = jsonDecode(storedData);
      final preferences = UserPreferences.fromJson(jsonData);

      print('[${DateTime.now()}] PreferencesService: ✅ Loaded preferences from local backup'
          '\n└─ User ID: $userId'
          '\n└─ Land Types: ${preferences.preferredLandTypes.length}'
          '\n└─ Price Range: \$${preferences.minPrice.toInt()}-\$${preferences.maxPrice == double.infinity ? "∞" : preferences.maxPrice.toInt()}'
          '\n└─ Locations: ${preferences.preferredLocations.join(", ")}');

      return preferences;
    } catch (e) {
      print('[${DateTime.now()}] PreferencesService: ❌ Error loading local backup'
          '\n└─ User ID: $userId'
          '\n└─ Error: $e');
      return null;
    }
  }

  /// Store a local backup of preferences
  Future<void> _storeLocalBackup(String userId, UserPreferences preferences) async {
    try {
      final jsonData = jsonEncode(preferences.toJson());
      await _storageService.write(key: _getPreferencesKey(userId), value: jsonData);

      print('[${DateTime.now()}] PreferencesService: ✅ Local backup saved'
          '\n└─ User ID: $userId');
    } catch (e) {
      print('[${DateTime.now()}] PreferencesService: ⚠️ Failed to save local backup'
          '\n└─ User ID: $userId'
          '\n└─ Error: $e');
    }
  }
}