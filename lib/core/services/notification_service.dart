// lib/core/services/notification_service.dart
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:the_boost/core/services/land_service.dart';
import 'package:the_boost/core/services/secure_storage_service.dart';
import 'package:the_boost/features/auth/data/models/land_model.dart';
import 'package:the_boost/features/auth/domain/entities/notification.dart';
import 'package:the_boost/features/auth/domain/entities/user_preferences.dart';

class NotificationService {
  static const String _notificationsKey = 'user_notifications';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final LandService _landService;
  final SecureStorageService _storageService;

NotificationService({
    required LandService landService,
    required SecureStorageService storageService,
  })  : _landService = landService,
        _storageService = storageService;
  /// Load notifications from secure storage
  Future<List<UserNotification>> getNotifications() async {
    try {
      final String? storedNotifications = await _storage.read(key: _notificationsKey);

      if (storedNotifications == null) {
        return [];
      }

      final List<dynamic> decodedData = jsonDecode(storedNotifications);
      return decodedData.map((json) => UserNotification.fromJson(json)).toList();
    } catch (e) {
      print('[${DateTime.now()}] NotificationService: ❌ Error loading notifications'
          '\n└─ Error: $e');
      return [];
    }
  }

  /// Save notifications to secure storage
  Future<void> saveNotifications(List<UserNotification> notifications) async {
    try {
      final List<Map<String, dynamic>> jsonData =
          notifications.map((notif) => notif.toJson()).toList();
      await _storage.write(key: _notificationsKey, value: jsonEncode(jsonData));
    } catch (e) {
      print('[${DateTime.now()}] NotificationService: ❌ Error saving notifications'
          '\n└─ Error: $e');
    }
  }

  /// Add a new notification
  Future<void> addNotification(UserNotification notification) async {
    try {
      final List<UserNotification> notifications = await getNotifications();
      notifications.insert(0, notification); // Add at the beginning

      // Limit to most recent 50 notifications
      if (notifications.length > 50) {
        notifications.removeRange(50, notifications.length);
      }

      await saveNotifications(notifications);
    } catch (e) {
      print('[${DateTime.now()}] NotificationService: ❌ Error adding notification'
          '\n└─ Error: $e');
    }
  }

  /// Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      final List<UserNotification> notifications = await getNotifications();

      final List<UserNotification> updatedNotifications = notifications.map((notif) {
        if (notif.id == notificationId) {
          return notif.markAsRead();
        }
        return notif;
      }).toList();

      await saveNotifications(updatedNotifications);
    } catch (e) {
      print('[${DateTime.now()}] NotificationService: ❌ Error marking notification as read'
          '\n└─ Error: $e');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      final List<UserNotification> notifications = await getNotifications();

      final List<UserNotification> updatedNotifications =
          notifications.map((notif) => notif.markAsRead()).toList();

      await saveNotifications(updatedNotifications);
    } catch (e) {
      print('[${DateTime.now()}] NotificationService: ❌ Error marking all notifications as read'
          '\n└─ Error: $e');
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      final List<UserNotification> notifications = await getNotifications();

      final List<UserNotification> updatedNotifications =
          notifications.where((notif) => notif.id != notificationId).toList();

      await saveNotifications(updatedNotifications);
    } catch (e) {
      print('[${DateTime.now()}] NotificationService: ❌ Error deleting notification'
          '\n└─ Error: $e');
    }
  }

  /// Get unread notifications count
  Future<int> getUnreadCount() async {
    try {
      final List<UserNotification> notifications = await getNotifications();
      return notifications.where((notif) => !notif.isRead).length;
    } catch (e) {
      print('[${DateTime.now()}] NotificationService: ❌ Error getting unread count'
          '\n└─ Error: $e');
      return 0;
    }
  }

  /// Check if a land matches user preferences
  bool landMatchesPreferences(Land land, UserPreferences preferences) {
    // Check land type
    if (!preferences.preferredLandTypes.contains(land.type)) {
      return false;
    }

    // Check price range
    if (land.price < preferences.minPrice ||
        (preferences.maxPrice != double.infinity && land.price > preferences.maxPrice)) {
      return false;
    }

    // Check location (simple string contains check)
    if (preferences.preferredLocations.isNotEmpty) {
      bool locationMatch = preferences.preferredLocations.any((location) {
        return land.location.toLowerCase().contains(location.toLowerCase());
      });
      if (!locationMatch) return false;
    }

    return true;
  }

  /// Generate notifications for new lands that match preferences
  Future<void> checkNewLandsForNotifications(UserPreferences preferences, DateTime lastCheckTime) async {
    if (!preferences.notificationsEnabled) return;

    try {
      // Fetch new lands from the backend
      final List<Land> lands = await _landService.fetchLands();

      // Filter lands created after the last check time
      final List<Land> newLands = lands.where((land) {
        return land.createdAt.isAfter(lastCheckTime);
      }).toList();

      // Check if lands match user preferences
      for (final Land land in newLands) {
        if (_landMatchesPreferences(land, preferences)) {
          final UserNotification notification = UserNotification.landMatch(land);
          await addNotification(notification);

          print('[${DateTime.now()}] NotificationService: 🔔 Created land match notification'
              '\n└─ Land ID: ${land.id}'
              '\n└─ Land Name: ${land.title}'
              '\n└─ Price: ${land.price}'
              '\n└─ Location: ${land.location}');
        }
      }

      if (newLands.isNotEmpty) {
        print('[${DateTime.now()}] NotificationService: ✅ Found ${newLands.length} matching lands');
      }
    } catch (e) {
      print('[${DateTime.now()}] NotificationService: ❌ Error checking new lands'
          '\n└─ Error: $e');
    }
  }

  /// Check if a land matches user preferences
  bool _landMatchesPreferences(Land land, UserPreferences preferences) {
    // Check land type
    if (!preferences.preferredLandTypes.contains(land.type)) return false;

    // Check price range
    if (land.price < preferences.minPrice ||
        (preferences.maxPrice != double.infinity && land.price > preferences.maxPrice)) {
      return false;
    }

    // Check location (substring match)
    if (preferences.preferredLocations.isNotEmpty) {
      bool locationMatch = false;
      for (final String location in preferences.preferredLocations) {
        if (land.location.toLowerCase().contains(location.toLowerCase())) {
          locationMatch = true;
          break;
        }
      }
      if (!locationMatch) return false;
    }

    return true;
  }

}