// lib/core/services/preferences_service.dart
import 'dart:convert';
import 'package:the_boost/core/services/notification_service.dart';
import 'package:the_boost/core/services/secure_storage_service.dart';
import 'package:the_boost/features/auth/data/datasources/static_lands.dart';
import 'package:the_boost/features/auth/data/models/land_model.dart';
import 'package:the_boost/features/auth/domain/entities/notification.dart';
import 'package:the_boost/features/auth/domain/entities/user.dart';
import 'package:the_boost/features/auth/domain/entities/user_preferences.dart';

class PreferencesService {
  final SecureStorageService _storageService;
  final NotificationService _notificationService;
  
  PreferencesService({
    SecureStorageService? storageService,
    NotificationService? notificationService,
  }) : _storageService = storageService ?? SecureStorageService(),
       _notificationService = notificationService ?? NotificationService();
  
  // Key for storing user preferences
  String _getPreferencesKey(String userId) => 'user_preferences_$userId';
  
  // Save user preferences
  Future<void> savePreferences(String userId, UserPreferences preferences) async {
    try {
      final jsonData = jsonEncode(preferences.toJson());
      await _storageService.write(
        key: _getPreferencesKey(userId),
        value: jsonData,
      );
      
      // After saving preferences, check for matching lands to notify
      await _checkForMatchingLands(userId, preferences);
      
      print('[${DateTime.now()}] PreferencesService: ✅ Preferences saved'
          '\n└─ User ID: $userId'
          '\n└─ Land Types: ${preferences.preferredLandTypes.length}'
          '\n└─ Price Range: \$${preferences.minPrice.toInt()}-\$${preferences.maxPrice == double.infinity ? "∞" : preferences.maxPrice.toInt()}'
          '\n└─ Locations: ${preferences.preferredLocations.join(", ")}');
    } catch (e) {
      print('[${DateTime.now()}] PreferencesService: ❌ Error saving preferences'
          '\n└─ User ID: $userId'
          '\n└─ Error: $e');
      rethrow;
    }
  }
  
  // Load user preferences
  Future<UserPreferences?> getPreferences(String userId) async {
    try {
      final jsonData = await _storageService.read(key: _getPreferencesKey(userId));
      
      if (jsonData == null) {
        print('[${DateTime.now()}] PreferencesService: ℹ️ No preferences found'
            '\n└─ User ID: $userId');
        return null;
      }
      
      final preferences = UserPreferences.fromJson(jsonDecode(jsonData));
      
      print('[${DateTime.now()}] PreferencesService: ✅ Preferences loaded'
          '\n└─ User ID: $userId'
          '\n└─ Land Types: ${preferences.preferredLandTypes.length}'
          '\n└─ Price Range: \$${preferences.minPrice.toInt()}-\$${preferences.maxPrice == double.infinity ? "∞" : preferences.maxPrice.toInt()}'
          '\n└─ Locations: ${preferences.preferredLocations.join(", ")}');
      
      return preferences;
    } catch (e) {
      print('[${DateTime.now()}] PreferencesService: ❌ Error loading preferences'
          '\n└─ User ID: $userId'
          '\n└─ Error: $e');
      return null;
    }
  }
  
  // Check if user has configured preferences
  Future<bool> hasPreferences(String userId) async {
    try {
      return await _storageService.containsKey(key: _getPreferencesKey(userId));
    } catch (e) {
      print('[${DateTime.now()}] PreferencesService: ❌ Error checking preferences'
          '\n└─ User ID: $userId'
          '\n└─ Error: $e');
      return false;
    }
  }
  
  // Delete user preferences
  Future<void> deletePreferences(String userId) async {
    try {
      await _storageService.delete(key: _getPreferencesKey(userId));
      
      print('[${DateTime.now()}] PreferencesService: ✅ Preferences deleted'
          '\n└─ User ID: $userId');
    } catch (e) {
      print('[${DateTime.now()}] PreferencesService: ❌ Error deleting preferences'
          '\n└─ User ID: $userId'
          '\n└─ Error: $e');
      rethrow;
    }
  }
  
  // Check for lands that match preferences and send notifications
  Future<void> _checkForMatchingLands(String userId, UserPreferences preferences) async {
    // Skip if notifications are disabled
    if (!preferences.notificationsEnabled) {
      return;
    }
    
    try {
      // Get all lands from static data
      // In a real app, this would be an API call
      final lands = StaticLandsData.getLands();
      
      // Filter lands based on preferences
      final matchingLands = lands.where((land) {
        // Check land type
        if (!preferences.preferredLandTypes.contains(land.type)) {
          return false;
        }
        
        // Check price range
        if (land.price < preferences.minPrice || 
            (preferences.maxPrice != double.infinity && land.price > preferences.maxPrice)) {
          return false;
        }
        
        // Check location (simple substring match)
        if (preferences.preferredLocations.isNotEmpty) {
          bool locationMatch = false;
          for (final location in preferences.preferredLocations) {
            if (land.location.toLowerCase().contains(location.toLowerCase())) {
              locationMatch = true;
              break;
            }
          }
          if (!locationMatch) return false;
        }
        
        return true;
      }).toList();
      
      // Create notifications for matching lands
      for (final land in matchingLands) {
        final notification = UserNotification.landMatch(land);
        await _notificationService.addNotification(notification);
        
        print('[${DateTime.now()}] PreferencesService: 🔔 Created land match notification'
            '\n└─ User ID: $userId'
            '\n└─ Land: ${land.name}'
            '\n└─ Land Type: ${land.type}'
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
  
  // Check and send notifications for new lands
  Future<void> checkForNewLandNotifications(User user) async {
    final preferences = await getPreferences(user.id);
    
    if (preferences == null || !preferences.notificationsEnabled) {
      return;
    }
    
    // In a real app, you'd fetch only new lands since the last check
    // Here we'll just check all lands
    await _checkForMatchingLands(user.id, preferences);
  }
}