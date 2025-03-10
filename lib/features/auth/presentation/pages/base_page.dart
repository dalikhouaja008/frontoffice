// lib/features/auth/presentation/pages/base_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_boost/features/auth/presentation/bloc/login/login_bloc.dart';
import 'package:the_boost/features/auth/presentation/bloc/login/login_state.dart';
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
    // Use BlocBuilder to ensure the page rebuilds when auth state changes
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        print('[2025-03-09 11:15:42] BasePage: 🔄 Building BasePage for route: $currentRoute'
              '\n└─ Auth state: ${state.runtimeType}');
        
        return Scaffold(
          drawer: drawer,
          endDrawer: endDrawer,
          body: Column(
            children: [
              if (showNavBar) 
                // The AppNavBar already has its own BlocBuilder to access the LoginBloc
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
                      if (showFooter) const AppFooter(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}