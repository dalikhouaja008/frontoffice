// lib/features/auth/domain/entities/user_preferences.dart
import 'package:equatable/equatable.dart';

class UserPreferences extends Equatable {
  final String? id; // Changed from _id to public id
  final double minPrice;
  final double maxPrice;
  final List<String> preferredLocations;
  final List<String> preferredLandTypes;
  final double maxDistanceKm;
  final bool notificationsEnabled;
  final DateTime lastUpdated;

  const UserPreferences({
    this.id, // Changed from _id to id
    this.minPrice = 0.0,
    this.maxPrice = double.infinity,
    this.preferredLocations = const [],
    this.preferredLandTypes = const ["Residential"], // Default to prevent empty array
    this.maxDistanceKm = 50.0,
    this.notificationsEnabled = true,
    required this.lastUpdated,
  });

  // Update copyWith to include id
  UserPreferences copyWith({
    String? id,
    double? minPrice,
    double? maxPrice,
    List<String>? preferredLocations,
    List<String>? preferredLandTypes,
    double? maxDistanceKm,
    bool? notificationsEnabled,
    DateTime? lastUpdated,
  }) {
    return UserPreferences(
      id: id ?? this.id,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      preferredLocations: preferredLocations ?? this.preferredLocations,
      preferredLandTypes: preferredLandTypes ?? this.preferredLandTypes,
      maxDistanceKm: maxDistanceKm ?? this.maxDistanceKm,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  // Update toJson to include id
  Map<String, dynamic> toJson() {
    return {
      '_id': id, // Keep the key as '_id' for the API
      'minPrice': minPrice,
      'maxPrice': maxPrice == double.infinity ? -1 : maxPrice,
      'preferredLocations': preferredLocations,
      'preferredLandTypes': preferredLandTypes.isEmpty ? ["Residential"] : preferredLandTypes,
      'maxDistanceKm': maxDistanceKm,
      'notificationsEnabled': notificationsEnabled,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  // Update fromJson to parse id correctly
  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      id: json['_id'] as String?, // Parse from '_id' key
      minPrice: (json['minPrice'] as num?)?.toDouble() ?? 0.0,
      maxPrice: (json['maxPrice'] as num?)?.toDouble() == -1
          ? double.infinity
          : (json['maxPrice'] as num?)?.toDouble() ?? double.infinity,
      preferredLocations:
          (json['preferredLocations'] as List<dynamic>?)?.cast<String>() ?? [],
      preferredLandTypes:
          (json['preferredLandTypes'] as List<dynamic>?)?.cast<String>() ?? ["Residential"],
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
      preferredLandTypes: ["Residential"], // Default to prevent empty array
      maxDistanceKm: 50.0,
      notificationsEnabled: true,
      lastUpdated: DateTime.now(),
    );
  }

  // Add the isConfigured getter that was missing
  bool get isConfigured => lastUpdated.isAfter(DateTime(2020));

  // Update props to include id
  @override
  List<Object?> get props => [
        id,
        minPrice,
        maxPrice,
        preferredLocations,
        preferredLandTypes,
        maxDistanceKm,
        notificationsEnabled,
        lastUpdated,
      ];
}