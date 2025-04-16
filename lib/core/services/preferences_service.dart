// lib/core/services/preferences_service.dart
import 'dart:convert';
import 'dart:async'; // Add this import for Timer
import 'package:the_boost/core/di/dependency_injection.dart';
import 'package:the_boost/core/services/land_service.dart';
import 'package:the_boost/core/services/notification_service.dart';
import 'package:the_boost/core/services/secure_storage_service.dart';
import 'package:the_boost/features/auth/data/models/land_model.dart';
import 'package:the_boost/features/auth/domain/entities/notification.dart';
import 'package:the_boost/features/auth/domain/entities/user.dart';
import 'package:the_boost/features/auth/domain/entities/user_preferences.dart';
import 'package:the_boost/features/auth/domain/use_cases/preferences/get_preferences_usecase.dart';
import 'package:the_boost/features/auth/domain/use_cases/preferences/save_preferences_usecase.dart';

class PreferencesService {
  final SecureStorageService _storageService;
  final NotificationService _notificationService;
  final LandService _landService;

  // Cache for preferences to avoid excessive API calls
  UserPreferences? _cachedPreferences;
  String? _cachedUserId;
  DateTime? _cacheTimestamp;

  // Periodic matching timer
  Timer? _periodicTimer;

  // Cache timeout (10 minutes)
  static const _cacheTimeoutMinutes = 10;

  PreferencesService({
    SecureStorageService? storageService,
    NotificationService? notificationService,
    LandService? landService,
  })  : _storageService = storageService ?? SecureStorageService(),
        _notificationService = notificationService ?? getIt<NotificationService>(),
        _landService = landService ?? getIt<LandService>();

  // Key for storing user preferences
  String _getPreferencesKey(String userId) => 'user_preferences_$userId';

  // Start periodic matching for a user
  void startPeriodicMatching(String userId, {Duration period = const Duration(minutes: 30)}) {
    stopPeriodicMatching();

    print('[${DateTime.now()}] PreferencesService: 🔄 Starting periodic matching'
        '\n└─ User ID: $userId'
        '\n└─ Period: ${period.inMinutes} minutes');

    // Perform an initial check
    checkForNewLandNotifications(userId);

    // Set up periodic checks
    _periodicTimer = Timer.periodic(period, (_) => checkForNewLandNotifications(userId));
  }

  // Stop periodic matching
  void stopPeriodicMatching() {
    _periodicTimer?.cancel();
    _periodicTimer = null;
    print('[${DateTime.now()}] PreferencesService: 🛑 Stopped periodic matching');
  }

  // Get preferences from the API or local storage as fallback
  Future<UserPreferences?> getPreferences(String userId) async {
    try {
      // Check if we have a valid cached value
      if (_cachedUserId == userId && _cachedPreferences != null && _cacheTimestamp != null) {
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

      try {
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
              '\n└─ Price Range: \$${remotePrefs.minPrice.toInt()}-\$${remotePrefs.maxPrice == double.infinity ? "∞" : remotePrefs.maxPrice.toInt()}'
              '\n└─ Locations: ${remotePrefs.preferredLocations.join(", ")}');

          // Also store a local copy as backup
          await _storeLocalBackup(userId, remotePrefs);

          return remotePrefs;
        }
      } catch (e) {
        print('[${DateTime.now()}] PreferencesService: ⚠️ API fetch failed, using local backup'
            '\n└─ User ID: $userId'
            '\n└─ Error: $e');
      }

      // If API fetch failed or returned null, try local backup
      return await _getLocalBackup(userId);
    } catch (e) {
      print('[${DateTime.now()}] PreferencesService: ❌ Error loading preferences'
          '\n└─ User ID: $userId'
          '\n└─ Error: $e');
      return null;
    }
  }

  // Store a local backup of preferences
  Future<void> _storeLocalBackup(String userId, UserPreferences preferences) async {
    try {
      final jsonData = jsonEncode(preferences.toJson());
      await _storageService.write(
        key: _getPreferencesKey(userId),
        value: jsonData,
      );

      print('[${DateTime.now()}] PreferencesService: ✅ Local backup saved'
          '\n└─ User ID: $userId');
    } catch (e) {
      print('[${DateTime.now()}] PreferencesService: ⚠️ Failed to save local backup'
          '\n└─ User ID: $userId'
          '\n└─ Error: $e');
    }
  }

  bool _matchesPreferences(Land land, UserPreferences preferences) {
    final landPrice = land.totalPrice ?? 0.0; // Handle null totalPrice
    return landPrice >= preferences.minPrice &&
        (preferences.maxPrice == double.infinity || landPrice <= preferences.maxPrice) &&
        (preferences.preferredLocations.isEmpty ||
            preferences.preferredLocations.any(
                (loc) => land.location.toLowerCase().contains(loc.toLowerCase())));
  }

  // Get preferences from local backup
  Future<UserPreferences?> _getLocalBackup(String userId) async {
    try {
      final jsonData = await _storageService.read(key: _getPreferencesKey(userId));

      if (jsonData == null) {
        print('[${DateTime.now()}] PreferencesService: ℹ️ No local backup found'
            '\n└─ User ID: $userId');
        return null;
      }

      final preferences = UserPreferences.fromJson(jsonDecode(jsonData));

      print('[${DateTime.now()}] PreferencesService: ✅ Local backup loaded'
          '\n└─ User ID: $userId'
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

  // Save preferences to the API and local backup
  Future<void> savePreferences(String userId, UserPreferences preferences) async {
    try {
      print('[${DateTime.now()}] PreferencesService: 🌐 Saving preferences to API'
          '\n└─ User ID: $userId'
          '\n└─ Price Range: \$${preferences.minPrice.toInt()}-\$${preferences.maxPrice == double.infinity ? "∞" : preferences.maxPrice.toInt()}'
          '\n└─ Locations: ${preferences.preferredLocations.join(", ")}');

      try {
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

        // Re-throw for UI handling
        throw e;
      }
    } catch (e) {
      print('[${DateTime.now()}] PreferencesService: ❌ Error saving preferences'
          '\n└─ User ID: $userId'
          '\n└─ Error: $e');
      rethrow;
    }
  }

  // Check if user has configured preferences
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

  // Delete user preferences
  Future<void> deletePreferences(String userId) async {
    try {
      // Clear cache
      if (_cachedUserId == userId) {
        _cachedPreferences = null;
        _cachedUserId = null;
        _cacheTimestamp = null;
      }

      // Remove from local storage
      await _storageService.delete(key: _getPreferencesKey(userId));

      print('[${DateTime.now()}] PreferencesService: ✅ Preferences deleted'
          '\n└─ User ID: $userId');

      // TODO: Add API call to delete preferences when endpoint is available
    } catch (e) {
      print('[${DateTime.now()}] PreferencesService: ❌ Error deleting preferences'
          '\n└─ User ID: $userId'
          '\n└─ Error: $e');
      rethrow;
    }
  }

  // Check for lands that match preferences and send notifications
  Future<void> _checkForMatchingLands(String userId, UserPreferences preferences) async {
    if (!preferences.notificationsEnabled) return;

    try {
      final lands = await _landService.fetchLands();
      final matchingLands = lands.where((land) => _matchesPreferences(land, preferences)).toList();
      for (final land in matchingLands) {
        final notification = UserNotification.landMatch(land);
        await _notificationService.addNotification(notification);
        print('[${DateTime.now()}] PreferencesService: 🔔 Notification created'
            '\n└─ User ID: $userId'
            '\n└─ Land: ${land.title}');
      }
    } catch (e) {
      print('[${DateTime.now()}] PreferencesService: ❌ Error checking matches'
          '\n└─ User ID: $userId'
          '\n└─ Error: $e');
    }
  }

  // Check and send notifications for new lands
  Future<void> checkForNewLandNotifications(String userId) async {
    final preferences = await getPreferences(userId);

    if (preferences == null || !preferences.notificationsEnabled) {
      return;
    }

    // In a real app, you'd fetch only new lands since the last check
    // Here we'll just check all lands
    await _checkForMatchingLands(userId, preferences);
  }

  // Update user with preferences in one operation
  Future<User> updateUserWithPreferences(User user, UserPreferences preferences) async {
    try {
      // Save preferences to storage
      await savePreferences(user.id, preferences);

      // Return updated user object
      return user.copyWith(preferences: preferences);
    } catch (e) {
      print('[${DateTime.now()}] PreferencesService: ❌ Error updating user preferences'
          '\n└─ User ID: ${user.id}'
          '\n└─ Error: $e');
      rethrow;
    }
  }
}