import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class SocialButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;
  final AuthService? authService;
  final bool isGoogle;

  const SocialButton({
    Key? key,
    required this.icon,
    required this.color,
    this.onPressed,
    this.authService,
    this.isGoogle = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isGoogle ? _handleGoogleSignIn : onPressed,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.1),
        ),
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }

  Future<void> _handleGoogleSignIn() async {
    if (authService != null) {
      final token = await authService!.signInWithGoogle();
      if (token != null) {
        // Handle successful sign in
        print('Signed in successfully');
      } else {
        // Handle sign in failure
        print('Sign in failed');
      }
    }
  }
}