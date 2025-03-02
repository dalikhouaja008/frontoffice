// presentation/pages/base_page.dart
import 'package:flutter/material.dart';
import '../widgets/app_nav_bar.dart';
import '../widgets/app_footer.dart';

class BasePage extends StatelessWidget {
  final String title;
  final String currentRoute;
  final Widget body;
  final bool showNavBar;
  final bool showFooter;
  final Widget? drawer;
  final Widget? endDrawer;

  const BasePage({
    Key? key,
    required this.title,
    required this.currentRoute,
    required this.body,
    this.showNavBar = true,
    this.showFooter = true,
    this.drawer,
    this.endDrawer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: drawer,
      endDrawer: endDrawer,
      body: Column(
        children: [
          if (showNavBar)
            AppNavBar(
              currentRoute: currentRoute,
              onLoginPressed: () {
                Navigator.of(context).pushNamed('/auth');
              },
              onSignUpPressed: () {
                Navigator.of(context).pushNamed('/auth');
              },
            ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  body,
                  if (showFooter) AppFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}