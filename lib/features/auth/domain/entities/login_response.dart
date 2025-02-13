import 'package:the_boost/features/auth/domain/entities/user.dart';

class LoginResponse {
  final String? accessToken;
  final String? refreshToken;
  final User user;
  // Ces valeurs sont optionnelles car elles ne sont pas toujours présentes dans la réponse
  final bool requiresTwoFactor;
  final String? tempToken;

  LoginResponse({
    this.accessToken,
    this.refreshToken,
    required this.user,
    // Valeur par défaut à false si non spécifiée
    this.requiresTwoFactor = false,
    this.tempToken,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
      user: User.fromJson(json['user']),
      // Si ces champs ne sont pas présents dans la réponse, on utilise des valeurs par défaut
      requiresTwoFactor: json['requiresTwoFactor'] ?? false,
      tempToken: json['tempToken'],
    );
  }
}