enum UserRole {
  ADMIN,
  USER,
  NOTAIRE,
  GEOMETRE,
  EXPERT_JURIDIQUE;

  static UserRole fromString(String role) {
    return UserRole.values.firstWhere(
      (e) => e.toString().split('.').last == role.toUpperCase(),
      orElse: () => UserRole.USER,
    );
  }

  String get value => toString().split('.').last;
}