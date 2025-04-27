// lib/features/auth/presentation/widgets/menu/widgets/security_badge.dart
import 'package:flutter/material.dart';

class SecurityBadge extends StatelessWidget {
  final String message;

  const SecurityBadge({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.redAccent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        message,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
}