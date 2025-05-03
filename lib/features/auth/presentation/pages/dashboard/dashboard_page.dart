// lib/features/auth/presentation/pages/dashboard/dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:the_boost/core/constants/colors.dart';
import 'package:the_boost/core/constants/dimensions.dart';
import 'package:the_boost/core/constants/text_styles.dart';
import 'package:the_boost/core/services/preferences_service.dart';
import 'package:the_boost/core/utils/responsive_helper.dart';
import 'package:the_boost/features/auth/domain/entities/user.dart';
import 'package:the_boost/features/auth/presentation/pages/dashboard/widgets/dashboard_stats.dart';
import 'package:the_boost/features/auth/presentation/pages/dashboard/widgets/investment_portfolio.dart';
import 'package:the_boost/features/auth/presentation/pages/dashboard/widgets/recent_activity.dart';
import 'package:the_boost/features/auth/presentation/pages/base_page.dart';
import 'package:the_boost/features/auth/presentation/widgets/dialogs/preferences_alert_dialog.dart';

import '../../../../../core/di/dependency_injection.dart';

class DashboardPage extends StatefulWidget {
  final User? user;
  
  const DashboardPage({super.key, this.user});

  @override
  // ignore: library_private_types_in_public_api
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final PreferencesService _preferencesService = PreferencesService();
  
  @override
  void initState() {
    super.initState();
    
    print('[2025-03-02 19:21:51] DashboardPage: ✨ Initializing'
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
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    
    return BasePage(
      title: 'Dashboard',
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
                  DashboardStats(),
                  const SizedBox(height: AppDimensions.paddingXL),
                  
                  const SectionTitle(title: "Your Portfolio"),
                  const SizedBox(height: AppDimensions.paddingL),
                  InvestmentPortfolio(),
                  const SizedBox(height: AppDimensions.paddingXL),
                  
                  SectionTitle(title: "Recent Activity"),
                  const SizedBox(height: AppDimensions.paddingL),
                  RecentActivity(),
                  const SizedBox(height: AppDimensions.paddingXL),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SectionTitle(title: "Featured Properties"),
                      TextButton(
                        onPressed: () {
                          _navigateToInvest(context);
                        },
                        child: const Text(
                          "See all",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.paddingL),
                  // Remplacez FeaturedProperties par un widget statique
                  _buildEmptyFeaturedProperties(),
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
      print('[2025-03-02 19:21:51] DashboardPage: 🔄 Navigating to Invest page');
            
      Navigator.pushNamed(context, '/invest');
    } catch (e) {
      print('[2025-03-02 19:21:51] DashboardPage: ❌ Navigation error'
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
    final userName = user?.username.split(' ')[0] ?? 'Investor';
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? AppDimensions.paddingL : AppDimensions.paddingXXL,
        vertical: AppDimensions.paddingXL,
      ),
      decoration: const BoxDecoration(
        color: AppColors.backgroundGreen,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Welcome back, $userName!",
            style: AppTextStyles.h2.copyWith(
              fontSize: isMobile ? 24 : 32,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingS),
          Text(
            "Here's a summary of your investment portfolio",
            style: AppTextStyles.body2,
          ),
          const SizedBox(height: AppDimensions.paddingL),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.search),
                label: const Text("Discover Properties"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingL,
                    vertical: AppDimensions.paddingM,
                  ),
                ),
                onPressed: () => _navigateToInvest(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyFeaturedProperties() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.real_estate_agent,
              size: 50,
              color: Colors.grey[400],
            ),
            const SizedBox(height: AppDimensions.paddingM),
            Text(
              "Featured properties coming soon",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingM),
            ElevatedButton(
              onPressed: () => _navigateToInvest(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text("View All Properties"),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget utilitaire pour les titres de section
class SectionTitle extends StatelessWidget {
  final String title;
  
  const SectionTitle({super.key, required this.title});
  
  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.h3,
    );
  }
}