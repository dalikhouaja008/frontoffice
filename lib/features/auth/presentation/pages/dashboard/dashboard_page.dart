// presentation/pages/dashboard/dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:the_boost/core/constants/colors.dart';
import 'package:the_boost/core/constants/dimensions.dart';
import 'package:the_boost/core/constants/text_styles.dart';
import 'package:the_boost/core/utils/responsive_helper.dart';
import 'package:the_boost/features/auth/presentation/bloc/login/login_bloc.dart';
import 'package:the_boost/features/auth/presentation/bloc/login/login_state.dart';
import 'package:the_boost/features/auth/presentation/bloc/property_controller.dart';
import 'package:the_boost/features/auth/presentation/widgets/buttons/app_button.dart';
import '../base_page.dart';
import 'widgets/dashboard_stats.dart';
import 'widgets/investment_portfolio.dart';
import 'widgets/recent_activity.dart';
import 'widgets/featured_properties.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    // Load data when the page is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PropertyController>().loadProperties();
    });
  }

  @override
  Widget build(BuildContext context) {
    final propertyController = Provider.of<PropertyController>(context);
    final isMobile = ResponsiveHelper.isMobile(context);
    
    // Utiliser BlocBuilder pour surveiller l'état d'authentification
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        // Redirect to login if not authenticated
        if (state is! LoginSuccess) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, '/auth');
          });
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // Récupérer l'utilisateur depuis l'état LoginSuccess
        final user = (state).user;

        return BasePage(
          title: 'Dashboard',
          currentRoute: '/dashboard',
          body: Column(
            children: [
              _buildDashboardHeader(context, user),
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
                    
                    const SectionTitle(title: "Recent Activity"),
                    const SizedBox(height: AppDimensions.paddingL),
                    RecentActivity(),
                    const SizedBox(height: AppDimensions.paddingXL),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SectionTitle(title: "Featured Properties"),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/invest');
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
                    FeaturedProperties(
                      properties: propertyController.properties
                          .where((property) => property.isFeatured)
                          .take(3)
                          .toList(),
                    ),
                    const SizedBox(height: AppDimensions.paddingXXL),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDashboardHeader(BuildContext context, user) {
    final isMobile = ResponsiveHelper.isMobile(context);
    
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
            "Welcome back, ${user.name.split(' ')[0] ?? 'Investor'}!",
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
              AppButton(
                text: "Discover Properties",
                onPressed: () {
                  Navigator.pushNamed(context, '/invest');
                },
                type: ButtonType.primary,
                icon: Icons.search,
              ),
            ],
          ),
        ],
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