import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SocialButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final bool isLoading;

  const SocialButton({
    Key? key,
    required this.icon,
    required this.color,
    required this.onPressed,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: "Sign in with ${icon.toString().replaceFirst("IconData(U+", "").replaceFirst(")", "")}",
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.1),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: isLoading
              ? CircularProgressIndicator(color: color, strokeWidth: 2)
              : Icon(icon, color: color, size: 28),
        ),
      ),
    );
  }
}