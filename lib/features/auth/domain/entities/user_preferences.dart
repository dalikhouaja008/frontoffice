// lib/features/auth/domain/entities/user_preferences.dart
import 'package:flutter/foundation.dart';

class UserPreferences {
  final List<String> preferredCategories;
  final double minPrice;
  final double maxPrice;
  final double minReturn;
  final double maxReturn;
  final List<String> preferredRiskLevels;
  final List<String> preferredLocations;
  final bool notificationsEnabled;

  const UserPreferences({
    this.preferredCategories = const [],
    this.minPrice = 0,
    this.maxPrice = 50000,
    this.minReturn = 0,
    this.maxReturn = 20,
    this.preferredRiskLevels = const [],
    this.preferredLocations = const [],
    this.notificationsEnabled = true,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      preferredCategories: List<String>.from(json['preferredCategories'] ?? []),
      minPrice: (json['minPrice'] ?? 0).toDouble(),
      maxPrice: (json['maxPrice'] ?? 50000).toDouble(),
      minReturn: (json['minReturn'] ?? 0).toDouble(),
      maxReturn: (json['maxReturn'] ?? 20).toDouble(),
      preferredRiskLevels: List<String>.from(json['preferredRiskLevels'] ?? []),
      preferredLocations: List<String>.from(json['preferredLocations'] ?? []),
      notificationsEnabled: json['notificationsEnabled'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'preferredCategories': preferredCategories,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'minReturn': minReturn,
      'maxReturn': maxReturn,
      'preferredRiskLevels': preferredRiskLevels,
      'preferredLocations': preferredLocations,
      'notificationsEnabled': notificationsEnabled,
    };
  }

  UserPreferences copyWith({
    List<String>? preferredCategories,
    double? minPrice,
    double? maxPrice,
    double? minReturn,
    double? maxReturn,
    List<String>? preferredRiskLevels,
    List<String>? preferredLocations,
    bool? notificationsEnabled,
  }) {
    return UserPreferences(
      preferredCategories: preferredCategories ?? this.preferredCategories,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minReturn: minReturn ?? this.minReturn,
      maxReturn: maxReturn ?? this.maxReturn,
      preferredRiskLevels: preferredRiskLevels ?? this.preferredRiskLevels,
      preferredLocations: preferredLocations ?? this.preferredLocations,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserPreferences &&
        listEquals(other.preferredCategories, preferredCategories) &&
        other.minPrice == minPrice &&
        other.maxPrice == maxPrice &&
        other.minReturn == minReturn &&
        other.maxReturn == maxReturn &&
        listEquals(other.preferredRiskLevels, preferredRiskLevels) &&
        listEquals(other.preferredLocations, preferredLocations) &&
        other.notificationsEnabled == notificationsEnabled;
  }

  @override
  int get hashCode {
    return Object.hash(
      Object.hashAll(preferredCategories),
      minPrice,
      maxPrice,
      minReturn,
      maxReturn,
      Object.hashAll(preferredRiskLevels),
      Object.hashAll(preferredLocations),
      notificationsEnabled,
    );
  }
}