// lib/features/auth/domain/entities/user_preferences.dart
import 'package:equatable/equatable.dart';

class UserPreferences extends Equatable {
  final double minPrice;
  final double maxPrice;
  final List<String> preferredLocations;
  final double maxDistanceKm;
  final bool notificationsEnabled;
  final DateTime lastUpdated;

  const UserPreferences({
    this.minPrice = 0.0,
    this.maxPrice = double.infinity,
    this.preferredLocations = const [],
    this.maxDistanceKm = 50.0,
    this.notificationsEnabled = true,
    required this.lastUpdated,
  });

  UserPreferences copyWith({
    double? minPrice,
    double? maxPrice,
    List<String>? preferredLocations,
    double? maxDistanceKm,
    bool? notificationsEnabled,
    DateTime? lastUpdated,
  }) {
    return UserPreferences(
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      preferredLocations: preferredLocations ?? this.preferredLocations,
      maxDistanceKm: maxDistanceKm ?? this.maxDistanceKm,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'minPrice': minPrice,
      'maxPrice': maxPrice == double.infinity ? -1 : maxPrice,
      'preferredLocations': preferredLocations,
      'maxDistanceKm': maxDistanceKm,
      'notificationsEnabled': notificationsEnabled,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      minPrice: (json['minPrice'] as num?)?.toDouble() ?? 0.0,
      maxPrice: (json['maxPrice'] as num?)?.toDouble() == -1
          ? double.infinity
          : (json['maxPrice'] as num?)?.toDouble() ?? double.infinity,
      preferredLocations:
          (json['preferredLocations'] as List<dynamic>?)?.cast<String>() ?? [],
      maxDistanceKm: (json['maxDistanceKm'] as num?)?.toDouble() ?? 50.0,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      lastUpdated:
          DateTime.tryParse(json['lastUpdated'] as String? ?? '') ?? DateTime.now(),
    );
  }

  factory UserPreferences.defaultPreferences() {
    return UserPreferences(
      minPrice: 0.0,
      maxPrice: 1000000.0,
      preferredLocations: [],
      maxDistanceKm: 50.0,
      notificationsEnabled: true,
      lastUpdated: DateTime.now(),
    );
  }

  bool get isConfigured => lastUpdated.isAfter(DateTime(2020));

  @override
  List<Object?> get props => [
        minPrice,
        maxPrice,
        preferredLocations,
        maxDistanceKm,
        notificationsEnabled,
        lastUpdated,
      ];
}