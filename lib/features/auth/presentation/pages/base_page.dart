// lib/features/auth/presentation/pages/base_page.dart
import 'package:flutter/material.dart';

class BasePage extends StatelessWidget {
  final String title;
  final String currentRoute;
  final Widget body;

  const BasePage({
    Key? key,
    required this.title,
    required this.currentRoute,
    required this.body,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.green,
      ),
      body: body,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentRoute == '/dashboard' ? 0 : 1,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/dashboard');
          } else {
            Navigator.pushNamed(context, '/explore');
          }
        },
      ),
    );
  }
}