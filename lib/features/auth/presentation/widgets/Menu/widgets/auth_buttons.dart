import 'package:flutter/material.dart';
import 'package:the_boost/core/utils/constants.dart';
import 'package:the_boost/features/auth/presentation/pages/login_screen.dart';


class AuthButtons extends StatelessWidget {
  final VoidCallback? onSignInPressed;
  final VoidCallback? onSignUpPressed;

  const AuthButtons({
    Key? key,
    this.onSignInPressed,
    this.onSignUpPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Sign In Button
        OutlinedButton(
          onPressed: onSignInPressed ?? () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          },
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: kPrimaryColor),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            "Se connecter",
            style: TextStyle(
              color: kPrimaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Sign Up Button
        ElevatedButton(
          onPressed: onSignUpPressed ?? () {
            // Navigation vers la page d'inscription par défaut
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            "S'inscrire",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}