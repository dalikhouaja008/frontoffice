import 'package:the_boost/features/auth/domain/entities/user.dart';

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
  }) : super(
          id: id,
          username: username,
          email: email,
          role: role,
          twoFactorSecret: twoFactorSecret,
          isTwoFactorEnabled: isTwoFactorEnabled,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['user']['_id'] ?? "",
      username: json['user']['username'] ?? "Unknown",
      email: json['user']['email'] ?? "",
      role: json['user']['role'] ?? 'user',
      accessToken: json['accessToken'] ?? "",
      refreshToken: json['refreshToken'] ?? "",
      twoFactorSecret: json['user']['twoFactorSecret'],
      isTwoFactorEnabled: json['user']['isTwoFactorEnabled'] ?? false,
      createdAt: json['user']['createdAt'] != null 
          ? DateTime.parse(json['user']['createdAt']) 
          : DateTime.now(),
      updatedAt: json['user']['updatedAt'] != null 
          ? DateTime.parse(json['user']['updatedAt']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': {
        '_id': id,
        'username': username,
        'email': email,
        'role': role,
        'twoFactorSecret': twoFactorSecret,
        'isTwoFactorEnabled': isTwoFactorEnabled,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      },
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }

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
          updatedAt == other.updatedAt;

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
      updatedAt.hashCode;
}