// lib/core/services/notification_manager.dart
import 'dart:math';
import 'package:the_boost/core/services/notification_service.dart';
import 'package:the_boost/features/auth/domain/entities/property.dart';
import 'package:the_boost/features/auth/domain/entities/user.dart';

class NotificationManager {
  final NotificationService _notificationService = NotificationService();
  
  // Check if a user should receive notifications for a new property
  Future<void> checkPropertyForNotifications(Property property, User user) async {
    if (!user.preferences.notificationsEnabled) {
      return;
    }
    
    if (_notificationService.propertyMatchesPreferences(property, user.preferences)) {
      await _generatePropertyNotification(property);
    }
  }
  
  // Generate a notification for a new property
  Future<void> _generatePropertyNotification(Property property) async {
    final notification = NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'New Investment Opportunity',
      message: 'Property "${property.title}" matches your investment preferences.',
      createdAt: DateTime.now(),
      propertyId: property.id,
    );
    
    await _notificationService.addNotification(notification);
  }
  
  // Generate a welcome notification for new users
  Future<void> generateWelcomeNotification(User user) async {
    final notification = NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Welcome to TheBoost',
      message: 'Hello ${user.username}! Set your investment preferences to receive personalized recommendations.',
      createdAt: DateTime.now(),
    );
    
    await _notificationService.addNotification(notification);
  }
  
  // Generate a notification when user preferences are updated
  Future<void> generatePreferencesUpdatedNotification() async {
    final notification = NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Preferences Updated',
      message: 'Your investment preferences have been updated. We\'ll notify you about matching properties.',
      createdAt: DateTime.now(),
    );
    
    await _notificationService.addNotification(notification);
  }
  
  // Generate a notification for price changes
  Future<void> generatePriceChangeNotification(Property property, double oldPrice, double newPrice) async {
    final percentChange = ((newPrice - oldPrice) / oldPrice * 100).toStringAsFixed(1);
    final direction = newPrice > oldPrice ? 'increased' : 'decreased';
    
    final notification = NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Price Update',
      message: 'The minimum investment for "${property.title}" has $direction by $percentChange%.',
      createdAt: DateTime.now(),
      propertyId: property.id,
    );
    
    await _notificationService.addNotification(notification);
  }
  
  // Generate sample notifications for testing
  Future<void> generateSampleNotifications() async {
    final random = Random();
    final sampleProperties = [
      Property(
        id: '1',
        title: 'Urban Development Land - Downtown Metro',
        location: 'Phoenix, Arizona',
        category: 'Urban Development',
        minInvestment: 500,
        tokenPrice: 50,
        totalValue: 2500000,
        projectedReturn: 12.5,
        riskLevel: 'Medium',
        availableTokens: 18500,
        fundingPercentage: 0.78,
        imageUrl: 'assets/images/property1.jpg',
        isFeatured: true,
      ),
      Property(
        id: '2',
        title: 'Agricultural Farmland - Riverside County',
        location: 'Riverside, California',
        category: 'Agricultural',
        minInvestment: 100,
        tokenPrice: 10,
        totalValue: 1200000,
        projectedReturn: 7.8,
        riskLevel: 'Low',
        availableTokens: 42000,
        fundingPercentage: 0.65,
        imageUrl: 'assets/images/property2.jpg',
        isFeatured: false,
      ),
      Property(
        id: '3',
        title: 'Commercial District - Tech Corridor',
        location: 'Austin, Texas',
        category: 'Commercial',
        minInvestment: 1000,
        tokenPrice: 100,
        totalValue: 5800000,
        projectedReturn: 15.2,
        riskLevel: 'Medium-High',
        availableTokens: 15000,
        fundingPercentage: 0.82,
        imageUrl: 'assets/images/property3.jpg',
        isFeatured: true,
      ),
    ];
    
    // Generate 3 random notifications
    for (var i = 0; i < 3; i++) {
      final property = sampleProperties[random.nextInt(sampleProperties.length)];
      final notificationType = random.nextInt(3);
      
      switch (notificationType) {
        case 0:
          // New property notification
          await _generatePropertyNotification(property);
          break;
        case 1:
          // Price change notification
          final oldPrice = property.minInvestment;
          final newPrice = oldPrice * (1 + (random.nextDouble() * 0.2 - 0.1)); // +/- 10%
          await generatePriceChangeNotification(property, oldPrice, newPrice);
          break;
        case 2:
          // System notification
          final notification = NotificationItem(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: 'System Update',
            message: 'We\'ve improved our recommendation algorithm to better match your preferences.',
            createdAt: DateTime.now(),
          );
          await _notificationService.addNotification(notification);
          break;
      }
    }
  }
  
  // Get the number of unread notifications
  Future<int> getUnreadCount() async {
    return await _notificationService.getUnreadCount();
  }
  
  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    await _notificationService.markAllAsRead();
  }
  
  // Clear all notifications
  Future<void> clearAllNotifications() async {
    await _notificationService.clearAllNotifications();
  }
  
  // Get all notifications
  Future<List<NotificationItem>> getNotifications() async {
    return await _notificationService.getNotifications();
  }
}