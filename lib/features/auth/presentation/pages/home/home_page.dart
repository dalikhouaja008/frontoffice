// presentation/pages/home/home_page.dart
import 'package:flutter/material.dart';
import 'package:the_boost/core/constants/colors.dart';
import 'package:the_boost/core/utils/responsive_helper.dart';
import 'package:the_boost/features/auth/presentation/bloc/routes.dart';
import '../../widgets/hero_section.dart';
import '../../widgets/features_grid.dart';
import '../../widgets/steps_section.dart';
import '../base_page.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Home',
      currentRoute: '/',
      body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeroSection(context),
                  _buildFeaturesSection(context),
                  _buildHowItWorksSection(context),
                  _buildAdvantagesSection(context),
                  _buildTestimonialsSection(context),
                  _buildFaqSection(context),
                  _buildCallToActionSection(context),
                ],
              ),
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton.extended(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.investmentAssistant);
                },
                icon: const Icon(Icons.support_agent),
                label: const Text('Get Investment Help'),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
  }
  Widget _buildHeroSection(BuildContext context) {
    return HeroSection(
      title: 'Invest in Land\nThe Smart Way',
      subtitle: 'Buy, sell, and exchange tokenized land assets with full transparency and security through blockchain technology.',
      primaryButtonText: 'Start Investing',
      secondaryButtonText: 'How it works',
      onPrimaryButtonPressed: () {
        Navigator.of(context).pushNamed('/invest');
      },
      onSecondaryButtonPressed: () {
        Navigator.of(context).pushNamed('/how-it-works');
      },
      image: Container(
        height: 400,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Container(
              color: Colors.grey[300],
              child: Center(
                child: Icon(Icons.image, size: 64, color: Colors.grey[400]),
              ),
            ),
            Positioned.fill(
              child: Center(
                child: Text(
                  "Application Screenshot",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesSection(BuildContext context) {
    return FeaturesGrid(
      title: 'Key Features',
      subtitle: 'Everything you need to invest in land assets with confidence',
      features: [
        FeatureItem(
          icon: Icons.token,
          title: 'Asset Tokenization',
          description: 'Convert land ownership into digital tokens for fractional investing and easier transfers.'
        ),
        FeatureItem(
          icon: Icons.swap_horiz,
          title: 'Buy & Sell Tokens',
          description: 'Trade land tokens easily through our intuitive platform with minimal fees.'
        ),
        FeatureItem(
          icon: Icons.security,
          title: 'Blockchain Security',
          description: 'Secure all transactions and ownership records with immutable blockchain technology.'
        ),
        FeatureItem(
          icon: Icons.show_chart,
          title: 'Market Analytics',
          description: 'Access detailed market data and trends to make informed investment decisions.'
        ),
      ],
      crossAxisCount: 4,
      childAspectRatio: ResponsiveHelper.isMobile(context) ? 1.2 : 1.0,
    );
  }

  Widget _buildHowItWorksSection(BuildContext context) {
    return StepsSection(
      title: 'How It Works',
      subtitle: 'Simple steps to start your land investment journey',
      steps: [
        StepItem(
          number: '01',
          title: 'Create an Account',
          description: 'Sign up and complete verification to access investment opportunities.'
        ),
        StepItem(
          number: '02',
          title: 'Browse Properties',
          description: 'Explore available land offerings with detailed information and analytics.'
        ),
        StepItem(
          number: '03',
          title: 'Purchase Tokens',
          description: 'Buy tokens representing shares in land properties of your choice.'
        ),
        StepItem(
          number: '04',
          title: 'Manage Portfolio',
          description: 'Track performance, receive updates, and sell or trade tokens when ready.'
        ),
      ],
    );
  }

  Widget _buildAdvantagesSection(BuildContext context) {
    // More implementation here
    return Container(); // For now just a placeholder
  }

  Widget _buildTestimonialsSection(BuildContext context) {
    // More implementation here
    return Container(); // For now just a placeholder
  }

  Widget _buildFaqSection(BuildContext context) {
    // More implementation here
    return Container(); // For now just a placeholder
  }

  Widget _buildCallToActionSection(BuildContext context) {
    // More implementation here
    return Container(); // For now just a placeholder
  }
}