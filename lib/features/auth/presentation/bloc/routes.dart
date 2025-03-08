import 'package:flutter/material.dart';
import 'package:the_boost/core/widgets/error_page.dart';
import 'package:the_boost/features/auth/presentation/features_pages.dart';
import 'package:the_boost/features/auth/presentation/pages/auth/auth_page.dart';
import 'package:the_boost/features/auth/presentation/pages/auth/forgot_password_page.dart';
import 'package:the_boost/features/auth/presentation/pages/dashboard/dashboard_page.dart';
import 'package:the_boost/features/auth/presentation/pages/home/home_page.dart';
import 'package:the_boost/features/auth/presentation/pages/investments/investment_page.dart';
import 'package:the_boost/features/auth/presentation/pages/property_details/property_details_page.dart';
import 'package:the_boost/features/auth/presentation/widgets/howitworks_page.dart';
import 'package:the_boost/features/auth/presentation/widgets/learn_more_page.dart';

class AppRoutes {
  // Routes principales
  static const String home = '/';
  static const String auth = '/auth';
  static const String dashboard = '/dashboard';
  
  // Routes d'information
  static const String features = '/features';
  static const String howItWorks = '/how-it-works';
  static const String learnMore = '/learn-more';
  
  // Routes d'investissement
  static const String investment = '/invest';
  static const String propertyDetails = '/property-details';
  
  // Routes d'authentification
  static const String forgotPassword = '/forgot-password';
  
  static Route<dynamic> generateRoute(RouteSettings settings) {
    print('🧭 Navigating to: ${settings.name}');
    
    try {
      switch (settings.name) {
        // Routes principales
        case home:
          return _buildRoute(
            settings,
            HomePage(),
            fullscreenDialog: true,
          );
          
        case auth:
          return _buildRoute(
            settings,
            const AuthPage(),
          );
          
        case dashboard:
          return _buildRoute(
            settings,
            const DashboardPage(),
          );
          
        // Routes d'information
        case features:
          return _buildRoute(
            settings,
            FeaturesPage(),
          );
          
        case howItWorks:
          return _buildRoute(
            settings,
             HowItWorksPage(),
          );
          
        case learnMore:
          return _buildRoute(
            settings,
             LearnMorePage(),
          );
          
        // Routes d'investissement
        case investment:
          return _buildRoute(
            settings,
            const InvestmentPage(),
          );
          
        case propertyDetails:
          final args = settings.arguments;
          if (args is String) {
            return _buildRoute(
              settings,
              PropertyDetailsPage(propertyId: args),
            );
          }
          throw ArgumentError('Identifiant de propriété requis');
          
        // Routes d'authentification
        case forgotPassword:
          return _buildRoute(
            settings,
            ForgotPasswordPage(),
          );
          
        default:
          throw RouteException('Route non trouvée: ${settings.name}');
      }
    } catch (e) {
      print('❌ Erreur de navigation: $e');
      return MaterialPageRoute(
        builder: (_) => ErrorPage(
          error: e.toString(),
          onRetry: () => Navigator.of(_).pushNamed(home),
        ),
      );
    }
  }

  static Route<dynamic> _buildRoute(
    RouteSettings settings,
    Widget page, {
    bool fullscreenDialog = false,
  }) {
    return MaterialPageRoute(
      settings: settings,
      fullscreenDialog: fullscreenDialog,
      builder: (_) => page,
    );
  }
}

class RouteException implements Exception {
  final String message;
  
  const RouteException(this.message);
  
  @override
  String toString() => message;
}