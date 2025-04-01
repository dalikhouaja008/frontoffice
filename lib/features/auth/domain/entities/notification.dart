// lib/features/auth/domain/entities/notification.dart
import 'package:the_boost/features/auth/data/models/land_model.dart';

/// Enum représentant les types de notifications
enum NotificationType {
  NEW_LAND,
  PRICE_DROP,
  MATCH_PREFERENCES,
  SYSTEM_ALERT,
  DOCUMENT_UPDATE
}

/// Représente une notification utilisateur
class UserNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;
  final String? landId; // Référence optionnelle à une terre spécifique
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

  /// Méthode pour copier une notification avec des modifications
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

  /// Marque la notification comme lue
  UserNotification markAsRead() {
    return copyWith(isRead: true);
  }

  /// Convertit la notification en JSON pour le stockage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.toString().split('.').last, // Convertit l'énumération en chaîne
      'createdAt': createdAt.toIso8601String(), // Format ISO 8601 pour la date
      'isRead': isRead,
      'landId': landId,
      'additionalData': additionalData,
    };
  }

  /// Crée une notification à partir d'un JSON
  factory UserNotification.fromJson(Map<String, dynamic> json) {
    return UserNotification(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: _notificationTypeFromString(json['type'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      isRead: json['isRead'] as bool,
      landId: json['landId'] as String?,
      additionalData: json['additionalData'] as Map<String, dynamic>?,
    );
  }

  /// Fabrique pour créer des notifications de correspondance de terres
  factory UserNotification.landMatch(Land land) {
    return UserNotification(
      id: 'land_match_${land.id}_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Nouvelle correspondance de terre : ${land.title}',
      message:
          'Nous avons trouvé une nouvelle terre à ${land.location} qui correspond à vos préférences.',
      type: NotificationType.MATCH_PREFERENCES,
      createdAt: DateTime.now(),
      landId: land.id,
      additionalData: {
        'landTitle': land.title,
        'landType': land.type.toString().split('.').last,
        'price': land.price,
        'location': land.location,
        'status': land.status.toString().split('.').last,
        'ownerId': land.ownerId,
        'imageCIDs': land.imageCIDs,
      },
    );
  }

  /// Fabrique pour créer des notifications de baisse de prix
  factory UserNotification.priceDrop(Land land, double previousPrice) {
    final priceDropPercentage =
        ((previousPrice - land.price) / previousPrice * 100).toStringAsFixed(1);

    return UserNotification(
      id: 'price_drop_${land.id}_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Baisse de prix : ${land.title}',
      message:
          'Le prix de ${land.title} a baissé de $priceDropPercentage% (de \$${previousPrice.toStringAsFixed(2)} à \$${land.price.toStringAsFixed(2)}).',
      type: NotificationType.PRICE_DROP,
      createdAt: DateTime.now(),
      landId: land.id,
      additionalData: {
        'landTitle': land.title,
        'previousPrice': previousPrice,
        'newPrice': land.price,
        'dropPercentage': priceDropPercentage,
        'location': land.location,
        'status': land.status.toString().split('.').last,
        'ownerId': land.ownerId,
        'imageCIDs': land.imageCIDs,
      },
    );
  }

  /// Fabrique pour créer des alertes système
  factory UserNotification.systemAlert(String title, String message) {
    return UserNotification(
      id: 'system_alert_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      message: message,
      type: NotificationType.SYSTEM_ALERT,
      createdAt: DateTime.now(),
    );
  }

  /// Méthode d'aide pour convertir une chaîne en énumération NotificationType
  static NotificationType _notificationTypeFromString(String typeString) {
    return NotificationType.values.firstWhere(
      (e) => e.toString().split('.').last == typeString,
      orElse: () => NotificationType.SYSTEM_ALERT, // Valeur par défaut en cas d'erreur
    );
  }
}