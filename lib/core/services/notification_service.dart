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
  final FlutterSecureStorage _storage;
  final LandService _landService;
  final SecureStorageService _storageService;

  NotificationService({
    FlutterSecureStorage? storage,
    required LandService landService,
    required SecureStorageService storageService,
  })  : _storage = storage ?? const FlutterSecureStorage(),
        _landService = landService,
        _storageService = storageService;

  Future<List<UserNotification>> getNotifications() async {
    try {
      final storedNotifications = await _storage.read(key: _notificationsKey);
      if (storedNotifications == null) return [];

      final decodedData = jsonDecode(storedNotifications) as List<dynamic>;
      return decodedData.map((json) => UserNotification.fromJson(json)).toList();
    } catch (e) {
      print('[${DateTime.now()}] NotificationService: ❌ Error loading notifications: $e');
      return [];
    }
  }

  Future<void> saveNotifications(List<UserNotification> notifications) async {
    try {
      final jsonData = jsonEncode(notifications.map((n) => n.toJson()).toList());
      await _storage.write(key: _notificationsKey, value: jsonData);
    } catch (e) {
      print('[${DateTime.now()}] NotificationService: ❌ Error saving notifications: $e');
    }
  }

  Future<void> addNotification(UserNotification notification) async {
    try {
      final notifications = await getNotifications();
      notifications.insert(0, notification);

      if (notifications.length > 50) {
        notifications.removeRange(50, notifications.length);
      }

      await saveNotifications(notifications);
      print('[${DateTime.now()}] NotificationService: ✅ Added notification: ${notification.title}');
    } catch (e) {
      print('[${DateTime.now()}] NotificationService: ❌ Error adding notification: $e');
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      final notifications = await getNotifications();
      final updated =
          notifications.map((n) => n.id == notificationId ? n.markAsRead() : n).toList();
      await saveNotifications(updated);
    } catch (e) {
      print('[${DateTime.now()}] NotificationService: ❌ Error marking as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final notifications = await getNotifications();
      final updated = notifications.map((n) => n.markAsRead()).toList();
      await saveNotifications(updated);
    } catch (e) {
      print('[${DateTime.now()}] NotificationService: ❌ Error marking all as read: $e');
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      final notifications = await getNotifications();
      final updated = notifications.where((n) => n.id != notificationId).toList();
      await saveNotifications(updated);
    } catch (e) {
      print('[${DateTime.now()}] NotificationService: ❌ Error deleting notification: $e');
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final notifications = await getNotifications();
      return notifications.where((n) => !n.isRead).length;
    } catch (e) {
      print('[${DateTime.now()}] NotificationService: ❌ Error getting unread count: $e');
      return 0;
    }
  }

  Future<void> checkNewLandsForNotifications(
      UserPreferences preferences, DateTime lastCheckTime) async {
    if (!preferences.notificationsEnabled) return;

    try {
      final lands = await _landService.fetchLands();
      final newLands = lands.where((land) => land.createdAt.isAfter(lastCheckTime)).toList();

      for (final land in newLands) {
        if (_matchesPreferences(land, preferences)) {
          final notification = UserNotification.landMatch(land);
          await addNotification(notification);
        }
      }
    } catch (e) {
      print('[${DateTime.now()}] NotificationService: ❌ Error checking new lands: $e');
    }
  }

  bool _matchesPreferences(Land land, UserPreferences preferences) {
    final landPrice = land.totalPrice;
    return landPrice >= preferences.minPrice &&
        (preferences.maxPrice == double.infinity || landPrice <= preferences.maxPrice) &&
        (preferences.preferredLocations.isEmpty ||
            preferences.preferredLocations.any(
                (loc) => land.location.toLowerCase().contains(loc.toLowerCase())));
  }
}