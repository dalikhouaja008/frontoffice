// lib/features/auth/domain/entities/user.dart
import 'dart:convert';
import 'package:the_boost/features/auth/domain/entities/user_preferences.dart';

class User {
  final String id;
  final String username;
  final String email;
  final String role;
  final String? twoFactorSecret;
  final bool isTwoFactorEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserPreferences? preferences;
  final String token;
  final String? publicKey;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    this.twoFactorSecret,
    this.isTwoFactorEnabled = false,
    required this.createdAt,
    required this.updatedAt,
    this.preferences,
    this.token = '',
    this.publicKey,
  });

  // Ajout de la méthode fromJson
  factory User.fromJson(Map<String, dynamic> json) {
    print('[2025-02-13 20:50:39] 🔄 Parsing User from JSON:'
        '\n${const JsonEncoder.withIndent('  ').convert(json)}');

    try {
      // Parse preferences if they exist
      UserPreferences? userPrefs;
      if (json['preferences'] != null) {
        userPrefs = UserPreferences.fromJson(json['preferences']);
      }

      return User(
        id: json['_id'] as String? ?? '',
        username: json['username'] as String? ?? '',
        email: json['email'] as String? ?? '',
        role: json['role'] as String? ?? '',
        twoFactorSecret: json['twoFactorSecret'] as String?,
        isTwoFactorEnabled: json['isTwoFactorEnabled'] as bool? ?? false,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : DateTime.now(),
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : DateTime.now(),
        preferences: userPrefs,
        publicKey: json['publicKey'] as String?,
      );
    } catch (e) {
      print('[2025-02-13 20:50:39] ❌ Error parsing User from JSON:'
          '\n└─ Error: $e'
          '\n└─ JSON: ${json.toString()}');
      rethrow;
    }
  }

  // Ajout de la méthode toJson
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      '_id': id,
      'username': username,
      'email': email,
      'role': role,
      'twoFactorSecret': twoFactorSecret,
      'isTwoFactorEnabled': isTwoFactorEnabled,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'publicKey': publicKey,
    };

    if (preferences != null) {
      data['preferences'] = preferences!.toJson();
    }

    return data;
  }

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? role,
    String? twoFactorSecret,
    bool? isTwoFactorEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserPreferences? preferences,
    String? publicKey,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      role: role ?? this.role,
      twoFactorSecret: twoFactorSecret ?? this.twoFactorSecret,
      isTwoFactorEnabled: isTwoFactorEnabled ?? this.isTwoFactorEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      preferences: preferences ?? this.preferences,
      publicKey: publicKey ?? this.publicKey,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          username == other.username &&
          email == other.email &&
          role == other.role &&
          twoFactorSecret == other.twoFactorSecret &&
          isTwoFactorEnabled == other.isTwoFactorEnabled &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          publicKey == other.publicKey;

  @override
  int get hashCode =>
      id.hashCode ^
      username.hashCode ^
      email.hashCode ^
      role.hashCode ^
      twoFactorSecret.hashCode ^
      isTwoFactorEnabled.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode ^
      publicKey.hashCode;

  @override
  String toString() {
    return 'User{id: $id, username: $username, email: $email, role: $role, '
        'isTwoFactorEnabled: $isTwoFactorEnabled, createdAt: $createdAt, '
        'updatedAt: $updatedAt, publicKey: $publicKey}';
  }
}
