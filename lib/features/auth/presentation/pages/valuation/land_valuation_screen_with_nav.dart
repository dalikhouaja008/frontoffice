// lib/features/auth/presentation/pages/valuation/land_valuation_screen_with_nav.dart
// Create a wrapper to integrate with the existing navigation

import 'package:flutter/material.dart';
import 'package:the_boost/features/auth/presentation/pages/base_page.dart';
import 'package:the_boost/core/services/prop_service.dart';
import 'land_valuation_home_screen.dart';

class LandValuationScreenWithNav extends StatelessWidget {
  final ApiService? apiService;

  const LandValuationScreenWithNav({
    Key? key,
    this.apiService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Land Valuation',
      currentRoute: '/land-valuation',
      body: LandValuationHomeScreen(
        apiService: apiService,
      ),
    );
  }
}