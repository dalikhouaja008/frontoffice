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
  final String? landId;
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

  UserNotification markAsRead() {
    return copyWith(isRead: true);
  }

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

  factory UserNotification.landMatch(Land land) {
    return UserNotification(
      id: 'land_match_${land.id}_${DateTime.now().millisecondsSinceEpoch}',
      title: 'New Match: ${land.title}',
      message: 'Found a new land at ${land.location} matching your preferences. ${land.description != null ? "Description: ${land.description}" : ""}',
      type: NotificationType.MATCH_PREFERENCES,
      createdAt: DateTime.now(),
      landId: land.id,
      additionalData: {
        'landTitle': land.title,
        'price': land.priceland ?? '0',
        'location': land.location,
        'status': land.status,
        'ownerId': land.ownerId,
        'imageCIDs': land.imageCIDs,
        'description': land.description ?? '', // Use empty string if null
        'latitude': land.latitude, // Can be null, no change needed
        'longitude': land.longitude, // Can be null, no change needed
      },
    );
  }

  factory UserNotification.priceDrop(Land land, String previousPrice) {
      final currentPrice = land.priceland ?? '0';
      final prevPriceDouble = double.tryParse(previousPrice) ?? 0.0;
      final currPriceDouble = double.tryParse(currentPrice) ?? 0.0;
      final priceDropPercentage = prevPriceDouble > 0 
          ? ((prevPriceDouble - currPriceDouble) / prevPriceDouble * 100).toStringAsFixed(1)
          : '0.0';
          return UserNotification(
      id: 'price_drop_${land.id}_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Price Drop: ${land.title}',
      message:
        'Price for ${land.title} dropped by $priceDropPercentage% (from \$${previousPrice} to \$${currentPrice}).',
      type: NotificationType.PRICE_DROP,
      createdAt: DateTime.now(),
      landId: land.id,
      additionalData: {
        'landTitle': land.title,
        'previousPrice': previousPrice,
        'newPrice': land.priceland ?? '0',
        'dropPercentage': priceDropPercentage,
        'location': land.location,
        'status': land.status,
        'description': land.description ?? '', // Use empty string if null
        'latitude': land.latitude,
        'longitude': land.longitude,
      },
    );
  }

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