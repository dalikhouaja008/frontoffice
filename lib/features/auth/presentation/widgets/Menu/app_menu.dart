// lib/features/auth/presentation/widgets/menu/app_menu.dart
import 'package:flutter/material.dart';
import 'package:the_boost/features/auth/domain/entities/user.dart';

class AppMenu extends StatelessWidget {
  final User? user;
  final int selectedIndex;
  final Function(int) onMenuItemSelected;
  final VoidCallback? on2FAButtonPressed;

  const AppMenu({
    Key? key,
    required this.user,
    required this.selectedIndex,
    required this.onMenuItemSelected,
    this.on2FAButtonPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            user != null ? 'Welcome, ${user!.username}' : 'Guest',
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
          Row(
            children: [
              TextButton(
                onPressed: () => onMenuItemSelected(0),
                child: Text(
                  'Home',
                  style: TextStyle(
                    color: selectedIndex == 0 ? Colors.white : Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => onMenuItemSelected(1),
                child: Text(
                  'Invest',
                  style: TextStyle(
                    color: selectedIndex == 1 ? Colors.white : Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (user != null && on2FAButtonPressed != null)
                TextButton(
                  onPressed: on2FAButtonPressed,
                  child: const Text(
                    'Enable 2FA',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}