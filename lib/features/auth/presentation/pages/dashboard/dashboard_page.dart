import 'package:flutter/material.dart';
import 'package:the_boost/core/constants/colors.dart';
import 'package:the_boost/core/constants/dimensions.dart';
import 'package:the_boost/core/constants/text_styles.dart';
import 'package:the_boost/core/services/preferences_service.dart';
import 'package:the_boost/core/utils/responsive_helper.dart';
import 'package:the_boost/features/auth/domain/entities/user.dart';
import 'package:the_boost/features/auth/presentation/pages/base_page.dart';
import 'package:the_boost/features/auth/presentation/pages/dashboard/widgets/recent_activity.dart';
import 'package:the_boost/features/auth/presentation/widgets/dialogs/preferences_alert_dialog.dart';

import '../../../../../core/di/dependency_injection.dart';
import '../../../../../core/services/land_matching_service.dart';

class DashboardPage extends StatefulWidget {
  final User? user;

  const DashboardPage({super.key, this.user});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final PreferencesService _preferencesService = PreferencesService();

  @override
  void initState() {
    super.initState();

    print('[2025-03-02 19:21:51] DashboardPage: ✨ Initializing'
        '\n└─ User: ${widget.user?.username ?? 'Unknown'}'
        '\n└─ User email: ${widget.user?.email ?? 'Not provided'}');

    // Check for notifications and preferences when dashboard loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPreferencesAndNotifications();
    });
  }

  Future<void> _checkPreferencesAndNotifications() async {
    if (widget.user == null) return;

    print('[2025-03-02 19:21:51] DashboardPage: 🔍 Checking user preferences'
        '\n└─ User: ${widget.user!.username}');

    // First check if user has set preferences
    final hasPreferences = await _preferencesService.hasPreferences(widget.user!.id);

    // If not, show preferences setup dialog
    if (!hasPreferences && mounted) {
      print('[2025-03-02 19:21:51] DashboardPage: ⚠️ No preferences found, showing dialog'
          '\n└─ User: ${widget.user!.username}');

      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => PreferencesAlertDialog(user: widget.user!),
        );
      }
    } else {
      print('[2025-03-02 19:21:51] DashboardPage: ✅ User has preferences'
          '\n└─ User: ${widget.user!.username}');
    }

    // Start land matching service for this user
    final landMatchingService = getIt<LandMatchingService>();
    landMatchingService.startPeriodicMatching(widget.user!);

    // Check for new land notifications
    final matchingLands = await landMatchingService.findMatchingLands(widget.user!);

    if (matchingLands.isNotEmpty && mounted) {
      print('[2025-03-02 19:21:51] DashboardPage: 🔔 Found ${matchingLands.length} matching lands'
          '\n└─ User: ${widget.user!.username}');

      // Show a snackbar to alert user about new matches
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Found ${matchingLands.length} new properties matching your preferences!'),
          action: SnackBarAction(
            label: 'View',
            onPressed: () {
              _navigateToInvest(context);
            },
          ),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return BasePage(
      title: 'DASHBOARD',
      currentRoute: '/dashboard',
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildDashboardHeader(context, widget.user),
            const SizedBox(height: AppDimensions.paddingL),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? AppDimensions.paddingL : AppDimensions.paddingXXL,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInvestmentStats(),
                  const SizedBox(height: AppDimensions.paddingXL),
                  const RecentActivity(),
                  const SizedBox(height: AppDimensions.paddingXXL),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToInvest(BuildContext context) {
    try {
      print('[2025-03-02 19:21:51] DashboardPage: 🔄 Navigating to Invest page'
          '\n└─ User: ${widget.user?.username ?? 'Unknown'}');

      Navigator.pushNamed(context, '/invest');
    } catch (e) {
      print('[2025-03-02 19:21:51] DashboardPage: ❌ Navigation error'
          '\n└─ User: ${widget.user?.username ?? 'Unknown'}'
          '\n└─ Error: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Navigation error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildDashboardHeader(BuildContext context, User? user) {
    final isMobile = ResponsiveHelper.isMobile(context);
    // Use the username directly, capitalize the first letter, and handle null case
    final userName = user?.username != null
        ? user!.username[0].toUpperCase() + user.username.substring(1).toLowerCase()
        : 'Investor';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? AppDimensions.paddingL : AppDimensions.paddingXXL,
        vertical: AppDimensions.paddingXL,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFEFF7E7), // Light green background from screenshot
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "$userName, welcome in your dashboard !",
                style: AppTextStyles.h2.copyWith(
                  fontSize: isMobile ? 20 : 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Image.asset(
                'assets/logo.png', 
                height: 60,
              ),
            ],
          ),
          
          
        ],
      ),
    );
  }

  Widget _buildInvestmentStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatCard(".............", "0 €"),
        _buildStatCard("......", "0 €"),
        _buildStatCard("........", "0 €"),
      ],
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFDDE8D5)), // Light green border
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}