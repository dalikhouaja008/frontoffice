import 'package:flutter/material.dart';
import 'package:the_boost/core/utils/constants.dart';
import 'package:the_boost/features/auth/domain/entities/user.dart';
import 'package:the_boost/features/auth/presentation/pages/login_screen.dart';


class UserProfile extends StatelessWidget {
  final User user;
  final VoidCallback? on2FAButtonPressed;

  const UserProfile({
    Key? key,
    required this.user,
    this.on2FAButtonPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Bouton 2FA si non activé
        if (!user.isTwoFactorEnabled && on2FAButtonPressed != null)
          IconButton(
            icon: const Icon(Icons.security_outlined),
            onPressed: on2FAButtonPressed,
            tooltip: 'Activer 2FA',
            color: Colors.orange,
          ),
        // Profile Section
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: kPrimaryColor,
                child: Text(
                  user.username[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.username,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: kTextColor,
                    ),
                  ),
                  Text(
                    user.role,
                    style: const TextStyle(
                      fontSize: 12,
                      color: kTextColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.logout_rounded),
          color: kTextLightColor,
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          },
        ),
      ],
    );
  }
}