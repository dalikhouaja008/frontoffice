// lib/core/services/notification_service.dart
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:the_boost/features/auth/data/models/land_model.dart';
import 'package:the_boost/features/auth/domain/entities/notification.dart';
import 'package:the_boost/features/auth/domain/entities/user_preferences.dart';

class NotificationService {
  static const String _notificationsKey = 'user_notifications';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  // Load notifications from secure storage
  Future<List<UserNotification>> getNotifications() async {
    try {
      final String? storedNotifications = await _storage.read(key: _notificationsKey);
      
      if (storedNotifications == null) {
        return [];
      }
      
      final List<dynamic> decodedData = jsonDecode(storedNotifications);
      return decodedData
          .map((notifJson) => UserNotification.fromJson(notifJson))
          .toList();
    } catch (e) {
      print('Error loading notifications: $e');
      return [];
    }
  }
  
  // Save notifications to secure storage
  Future<void> saveNotifications(List<UserNotification> notifications) async {
    try {
      final jsonData = notifications.map((notif) => notif.toJson()).toList();
      await _storage.write(key: _notificationsKey, value: jsonEncode(jsonData));
    } catch (e) {
      print('Error saving notifications: $e');
    }
  }
  
  // Add a new notification
  Future<void> addNotification(UserNotification notification) async {
    final notifications = await getNotifications();
    notifications.insert(0, notification); // Add at the beginning
    
    // Limit to most recent 50 notifications
    if (notifications.length > 50) {
      notifications.removeRange(50, notifications.length);
    }
    
    await saveNotifications(notifications);
  }
  
  // Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    final notifications = await getNotifications();
    
    final updatedNotifications = notifications.map((notif) {
      if (notif.id == notificationId) {
        return notif.markAsRead();
      }
      return notif;
    }).toList();
    
    await saveNotifications(updatedNotifications);
  }
  
  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    final notifications = await getNotifications();
    
    final updatedNotifications = notifications.map((notif) => notif.markAsRead()).toList();
    
    await saveNotifications(updatedNotifications);
  }
  
  // Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    final notifications = await getNotifications();
    
    final updatedNotifications = notifications.where((notif) => notif.id != notificationId).toList();
    
    await saveNotifications(updatedNotifications);
  }
  
  // Get unread notifications count
  Future<int> getUnreadCount() async {
    final notifications = await getNotifications();
    return notifications.where((notif) => !notif.isRead).length;
  }
  
  // Check if a land matches user preferences
  bool landMatchesPreferences(Land land, UserPreferences preferences) {
    // Check land type
    if (!preferences.preferredLandTypes.contains(land.type)) {
      return false;
    }
    
    // Check price range
    if (land.price < preferences.minPrice || land.price > preferences.maxPrice) {
      return false;
    }
    
    // Check location (simple string contains check)
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
  }
  
  // Generate notifications for new lands that match preferences
  Future<void> checkNewLandsForNotifications(
    List<Land> newLands,
    UserPreferences preferences,
  ) async {
    if (!preferences.notificationsEnabled) return;
    
    for (final land in newLands) {
      if (landMatchesPreferences(land, preferences)) {
        final notification = UserNotification.landMatch(land);
        await addNotification(notification);
      }
    }
  }
}