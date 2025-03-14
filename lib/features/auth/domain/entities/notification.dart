// lib/features/auth/domain/entities/notification.dart
import 'package:the_boost/features/auth/data/models/land_model.dart';

enum NotificationType {
  NEW_LAND,
  PRICE_DROP,
  MATCH_PREFERENCES,
  SYSTEM_ALERT,
  DOCUMENT_UPDATE
}

class UserNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;
  final String? landId; // Optional reference to a specific land
  final Map<String, dynamic>? additionalData;
  
  const UserNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.landId,
    this.additionalData,
  });

  // Copy with method for updating notification properties
  UserNotification copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    DateTime? createdAt,
    bool? isRead,
    String? landId,
    Map<String, dynamic>? additionalData,
  }) {
    return UserNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      landId: landId ?? this.landId,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  // Mark as read
  UserNotification markAsRead() {
    return copyWith(isRead: true);
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'landId': landId,
      'additionalData': additionalData,
    };
  }

  // Create from JSON
  factory UserNotification.fromJson(Map<String, dynamic> json) {
    return UserNotification(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == 'NotificationType.${json['type']}',
        orElse: () => NotificationType.SYSTEM_ALERT,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      isRead: json['isRead'] as bool,
      landId: json['landId'] as String?,
      additionalData: json['additionalData'] as Map<String, dynamic>?,
    );
  }

  // Factory for creating land match notifications
  factory UserNotification.landMatch(Land land) {
    return UserNotification(
      id: 'land_match_${land.id}_${DateTime.now().millisecondsSinceEpoch}',
      title: 'New Land Match: ${land.name}',
      message: 'We found a new land in ${land.location} that matches your preferences.',
      type: NotificationType.MATCH_PREFERENCES,
      createdAt: DateTime.now(),
      landId: land.id,
      additionalData: {
        'landName': land.name,
        'landType': land.type.toString().split('.').last,
        'price': land.price,
        'location': land.location,
      },
    );
  }

  // Factory for creating price drop notifications
  factory UserNotification.priceDrop(Land land, double previousPrice) {
    final priceDropPercentage = ((previousPrice - land.price) / previousPrice * 100).toStringAsFixed(1);
    
    return UserNotification(
      id: 'price_drop_${land.id}_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Price Drop: ${land.name}',
      message: 'The price of ${land.name} has dropped by $priceDropPercentage%.',
      type: NotificationType.PRICE_DROP,
      createdAt: DateTime.now(),
      landId: land.id,
      additionalData: {
        'landName': land.name,
        'previousPrice': previousPrice,
        'newPrice': land.price,
        'dropPercentage': priceDropPercentage,
      },
    );
  }

  // Factory for creating system alerts
  factory UserNotification.systemAlert(String title, String message) {
    return UserNotification(
      id: 'system_alert_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      message: message,
      type: NotificationType.SYSTEM_ALERT,
      createdAt: DateTime.now(),
    );
  }
}