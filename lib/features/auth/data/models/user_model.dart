// lib/features/auth/data/models/user_model.dart
import 'package:the_boost/features/auth/domain/entities/user.dart';
import 'package:the_boost/features/auth/domain/entities/user_preferences.dart';

class UserModel extends User {
  final String accessToken;
  final String refreshToken;

  UserModel({
    required String id,
    required String username,
    required String email,
    required String role,
    required this.accessToken,
    required this.refreshToken,
    String? twoFactorSecret,
    bool isTwoFactorEnabled = false,
    required DateTime createdAt,
    required DateTime updatedAt,
    UserPreferences? preferences,
    String? publicKey,
  }) : super(
          id: id,
          username: username,
          email: email,
          role: role,
          twoFactorSecret: twoFactorSecret,
          isTwoFactorEnabled: isTwoFactorEnabled,
          createdAt: createdAt,
          updatedAt: updatedAt,
          preferences: preferences,
          publicKey: publicKey,
        );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Check if the user data is nested inside a 'user' field or at the root
    final userData = json.containsKey('user') ? json['user'] : json;

    // Parse preferences if they exist
    UserPreferences? userPrefs;
    if (userData['preferences'] != null) {
      userPrefs = UserPreferences.fromJson(userData['preferences']);
    }

    return UserModel(
      id: userData['_id'] ?? "",
      username: userData['username'] ?? "Unknown",
      email: userData['email'] ?? "",
      role: userData['role'] ?? 'user',
      accessToken: json['accessToken'] ?? "",
      refreshToken: json['refreshToken'] ?? "",
      twoFactorSecret: userData['twoFactorSecret'],
      isTwoFactorEnabled: userData['isTwoFactorEnabled'] ?? false,
      createdAt: userData['createdAt'] != null
          ? DateTime.parse(userData['createdAt'])
          : DateTime.now(),
      updatedAt: userData['updatedAt'] != null
          ? DateTime.parse(userData['updatedAt'])
          : DateTime.now(),
      preferences: userPrefs,
      publicKey: userData['publicKey'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> userData = {
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
      userData['preferences'] = preferences!.toJson();
    }

    return {
      'user': userData,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }

  @override
  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    String? role,
    String? accessToken,
    String? refreshToken,
    String? twoFactorSecret,
    bool? isTwoFactorEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserPreferences? preferences,
    String? publicKey,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      role: role ?? this.role,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
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
      other is UserModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          username == other.username &&
          email == other.email &&
          role == other.role &&
          accessToken == other.accessToken &&
          refreshToken == other.refreshToken &&
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
      accessToken.hashCode ^
      refreshToken.hashCode ^
      twoFactorSecret.hashCode ^
      isTwoFactorEnabled.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode ^
      publicKey.hashCode;
}
