import '../../domain/entities/user.dart';

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
  }) : super(id: id, username: username, email: email, role: role);

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['user']['_id'] ?? "",  // ✅ Changed from `id` to `_id`
      username: json['user']['username'] ?? "Unknown", // ✅ Using `username` instead of `name`
      email: json['user']['email'] ?? "",
      role: json['user']['role'] ?? 'user', // Default role if null
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
    );
  }
}
