import 'package:flutter/material.dart';
import 'package:the_boost/core/utils/constants.dart';

class SocialIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const SocialIcon({
    Key? key,
    required this.icon,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Icon(
        icon,
        color: kTextColor,
        size: 24,
      ),
    );
  }
}