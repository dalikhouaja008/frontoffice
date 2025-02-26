import 'package:flutter/material.dart';

class SuccessDialog extends StatelessWidget {
  final String title;
  final String buttonText;
  final VoidCallback onButtonPressed;
  final IconData? icon;
  final Color? iconColor;
  final Color? buttonColor;
  final String? subtitle;
  final Widget? customContent;

  const SuccessDialog({
    super.key,
    this.title = 'Opération réussie',
    this.buttonText = 'Terminer',
    required this.onButtonPressed,
    this.icon = Icons.check_circle_outline,
    this.iconColor = Colors.green,
    this.buttonColor = Colors.green,
    this.subtitle,
    this.customContent,
  });

  @override
  Widget build(BuildContext context) {
    print('[2025-02-15 13:23:11] 🎉 Building CustomSuccessSection'
          '\n└─ User: raednas'
          '\n└─ Title: $title');

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 64,
          color: iconColor,
        ),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
        if (customContent != null) ...[
          const SizedBox(height: 16),
          customContent!,
        ],
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            print('[2025-02-15 13:23:11] 👆 Success button pressed'
                  '\n└─ User: raednas'
                  '\n└─ Action: $buttonText');
            onButtonPressed();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            padding: const EdgeInsets.symmetric(
              horizontal: 32,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: Text(buttonText),
        ),
      ],
    );
  }
}