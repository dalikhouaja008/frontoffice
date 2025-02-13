class User {
  final String id;
  final String username;
  final String email;
  final String role;
  final String? twoFactorSecret;
  final bool isTwoFactorEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    this.twoFactorSecret,
    this.isTwoFactorEnabled = false,
    required this.createdAt,
    required this.updatedAt,
  });

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? role,
    String? twoFactorSecret,
    bool? isTwoFactorEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
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
    );
  }

  // Pour la comparaison d'objets
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
          updatedAt == other.updatedAt;

  @override
  int get hashCode =>
      id.hashCode ^
      username.hashCode ^
      email.hashCode ^
      role.hashCode ^
      twoFactorSecret.hashCode ^
      isTwoFactorEnabled.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;

  @override
  String toString() {
    return 'User{id: $id, username: $username, email: $email, role: $role, '
        'isTwoFactorEnabled: $isTwoFactorEnabled, createdAt: $createdAt, '
        'updatedAt: $updatedAt}';
  }
}
