// lib/features/auth/domain/entities/user_preferences.dart
import 'package:the_boost/features/auth/data/models/land_model.dart';

class UserPreferences {
  final List<LandType> preferredLandTypes;
  final double minPrice;
  final double maxPrice;
  final List<String> preferredLocations;
  final double maxDistanceKm;
  final bool notificationsEnabled;
  final DateTime lastUpdated;

  const UserPreferences({
    required this.preferredLandTypes,
    this.minPrice = 0.0,
    this.maxPrice = double.infinity,
    this.preferredLocations = const [],
    this.maxDistanceKm = 50.0,
    this.notificationsEnabled = true,
    required this.lastUpdated,
  });

  // Clone the preferences with updated values
  UserPreferences copyWith({
    List<LandType>? preferredLandTypes,
    double? minPrice,
    double? maxPrice,
    List<String>? preferredLocations,
    double? maxDistanceKm,
    bool? notificationsEnabled,
    DateTime? lastUpdated,
  }) {
    return UserPreferences(
      preferredLandTypes: preferredLandTypes ?? this.preferredLandTypes,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      preferredLocations: preferredLocations ?? this.preferredLocations,
      maxDistanceKm: maxDistanceKm ?? this.maxDistanceKm,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'preferredLandTypes': preferredLandTypes.map((type) => type.toString().split('.').last).toList(),
      'minPrice': minPrice,
      'maxPrice': maxPrice == double.infinity ? -1 : maxPrice, // Handle infinity
      'preferredLocations': preferredLocations,
      'maxDistanceKm': maxDistanceKm,
      'notificationsEnabled': notificationsEnabled,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  // Create from JSON
  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      preferredLandTypes: (json['preferredLandTypes'] as List<dynamic>)
          .map((type) => LandType.values.firstWhere(
                (e) => e.toString() == 'LandType.${type}',
                orElse: () => LandType.RESIDENTIAL,
              ))
          .toList(),
      minPrice: json['minPrice'] as double,
      maxPrice: json['maxPrice'] == -1 ? double.infinity : json['maxPrice'] as double,
      preferredLocations: (json['preferredLocations'] as List<dynamic>).cast<String>(),
      maxDistanceKm: json['maxDistanceKm'] as double,
      notificationsEnabled: json['notificationsEnabled'] as bool,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  // Create default preferences
  factory UserPreferences.defaultPreferences() {
    return UserPreferences(
      preferredLandTypes: [LandType.RESIDENTIAL],
      minPrice: 0.0,
      maxPrice: 1000000.0,
      preferredLocations: [],
      maxDistanceKm: 50.0,
      notificationsEnabled: true,
      lastUpdated: DateTime.now(),
    );
  }

  // Check if preferences have been set up by the user
  bool get isConfigured => preferredLandTypes.isNotEmpty && lastUpdated.isAfter(DateTime(2025));
}