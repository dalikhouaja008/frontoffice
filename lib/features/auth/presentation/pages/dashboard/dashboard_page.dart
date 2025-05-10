import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_boost/core/constants/colors.dart';
import 'package:the_boost/core/constants/dimensions.dart';
import 'package:the_boost/core/constants/text_styles.dart';
import 'package:the_boost/core/di/dependency_injection.dart';
import 'package:the_boost/core/services/preferences_service.dart';
import 'package:the_boost/core/utils/responsive_helper.dart';
import 'package:the_boost/features/auth/domain/entities/user.dart';
import 'package:the_boost/features/auth/presentation/bloc/investment/investment_bloc.dart';
import 'package:the_boost/features/auth/presentation/pages/dashboard/widgets/dashboard_stats.dart';
import 'package:the_boost/features/auth/presentation/pages/dashboard/widgets/investment_portfolio.dart';
import 'package:the_boost/features/auth/presentation/pages/dashboard/widgets/recent_activity.dart';
import 'package:the_boost/features/auth/presentation/pages/base_page.dart';
import 'package:the_boost/features/auth/presentation/widgets/dialogs/preferences_alert_dialog.dart';

class DashboardPage extends StatefulWidget {
  final User? user;

  const DashboardPage({super.key, this.user});

  @override
  // ignore: library_private_types_in_public_api
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final PreferencesService _preferencesService = PreferencesService();
  late final InvestmentBloc _investmentBloc;

  @override
  void initState() {
    super.initState();
    _investmentBloc = getIt<InvestmentBloc>();

    print(' DashboardPage: ✨ Initializing'
        '\n└─ User email: ${widget.user?.email ?? 'Not provided'}');

    // Load investment data when dashboard loads
    _investmentBloc.add(LoadEnhancedTokens());

    // Check for notifications and preferences when dashboard loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPreferencesAndNotifications();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _checkPreferencesAndNotifications() async {
    if (widget.user == null) return;

    print(' DashboardPage: 🔍 Checking user preferences'
        '\n└─ User: ${widget.user!.username}');

    // First check if user has set preferences
    final hasPreferences =
        await _preferencesService.hasPreferences(widget.user!.id);

    // If not, show preferences setup dialog
    if (!hasPreferences && mounted) {
      print(
          'DashboardPage: ⚠️ No preferences found, showing dialog'
          '\n└─ User: ${widget.user!.username}');

      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => PreferencesAlertDialog(user: widget.user!),
        );
      }
    } else {
      print('DashboardPage: ✅ User has preferences'
          '\n└─ User: ${widget.user!.username}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return BlocProvider.value(
      value: _investmentBloc,
      child: BasePage(
        title: 'Dashboard',
        currentRoute: '/dashboard',
        body: RefreshIndicator(
          onRefresh: () async {
            _investmentBloc.add(LoadEnhancedTokens());
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                _buildDashboardHeader(context, widget.user),
                const SizedBox(height: AppDimensions.paddingL),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile
                        ? AppDimensions.paddingL
                        : AppDimensions.paddingXXL,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const DashboardStats(),
                      const SizedBox(height: AppDimensions.paddingXL),

                      const SectionTitle(title: "Your Portfolio"),
                      const SizedBox(height: AppDimensions.paddingL),
                      const InvestmentPortfolio(),
                      const SizedBox(height: AppDimensions.paddingXL),

                      const SectionTitle(title: "Recent Activity"),
                      const SizedBox(height: AppDimensions.paddingL),
                      const RecentActivity(),
                      const SizedBox(height: AppDimensions.paddingXL),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SectionTitle(title: "Featured Properties"),
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
        ),
      ),
    );
  }

  void _navigateToInvest(BuildContext context) {
    try {
      print('DashboardPage: 🔄 Navigating to Invest page');

      Navigator.pushNamed(context, '/invest');
    } catch (e) {
      print('DashboardPage: ❌ Navigation error'
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
        horizontal:
            isMobile ? AppDimensions.paddingL : AppDimensions.paddingXXL,
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
