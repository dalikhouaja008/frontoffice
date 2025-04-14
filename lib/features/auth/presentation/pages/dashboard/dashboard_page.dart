// lib/features/auth/presentation/pages/dashboard/dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:the_boost/core/constants/colors.dart';
import 'package:the_boost/core/constants/dimensions.dart';
import 'package:the_boost/core/utils/responsive_helper.dart';
import 'package:the_boost/features/auth/presentation/pages/base_page.dart';
import 'package:the_boost/features/auth/presentation/pages/dashboard/widgets/dashboard_stats.dart';
import 'package:the_boost/features/auth/presentation/pages/dashboard/widgets/recent_activity.dart';
import 'package:the_boost/features/auth/presentation/pages/dashboard/widgets/your_lands.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return BasePage(
      title: 'Dashboard',
      currentRoute: '/dashboard',
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildDashboardHeader(context),
            const SizedBox(height: AppDimensions.paddingL),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? AppDimensions.paddingL : AppDimensions.paddingXXL,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const DashboardStats(),
                  const SizedBox(height: AppDimensions.paddingL),
                  const RecentActivity(),
                  const SizedBox(height: AppDimensions.paddingL),
                  const YourLands(), // Add the new section here
                  const SizedBox(height: AppDimensions.paddingXXL),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: AppColors.backgroundGreen,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppDimensions.radiusL),
          bottomRight: Radius.circular(AppDimensions.radiusL),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Investor, welcome in your dashboard !",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingS),
              const Text(
                "Here’s an overview of your land investments.",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          Image.asset(
            'assets/logo.png', // Replace with your logo asset path
            height: 60,
          ),
        ],
      ),
    );
  }
}