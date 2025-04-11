// lib/features/auth/presentation/bloc/routes.dart
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:the_boost/core/di/dependency_injection.dart';
import 'package:the_boost/features/auth/presentation/features_pages.dart';
import '../../../chatbot/presentation/controllers/chat_controller.dart';

import 'package:the_boost/features/auth/domain/entities/user.dart';
import 'package:the_boost/features/auth/presentation/features_pages.dart';
import 'package:the_boost/features/auth/presentation/pages/preferences/user_preferences_screen.dart';

import '../../../investment/presentation/pages/investment_map_screen.dart';
import '../pages/auth/auth_page.dart';
import '../pages/auth/forgot_password_page.dart';
import '../pages/dashboard/dashboard_page.dart';
import '../pages/home/home_page.dart';
import '../pages/investments/invest_page.dart';
import '../pages/property_details/property_details_page.dart';
import '../widgets/howitworks_page.dart';
import '../widgets/learn_more_page.dart';
import '../../../chatbot/presentation/pages/chat_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String auth = '/auth';
  static const String dashboard = '/dashboard';
  static const String features = '/features';
  static const String howItWorks = '/how-it-works';
  static const String invest = '/invest';
  static const String learnMore = '/learn-more';
  static const String propertyDetails = '/property-details';
  static const String forgotPassword = '/forgot-password';
  static const String investmentAssistant = '/investment-assistant';
  static const String investmentMap = '/investment-map';

  static const String preferences = '/preferences';


  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => HomePage());
      case auth:
        return MaterialPageRoute(builder: (_) => AuthPage());
      case dashboard:
        return MaterialPageRoute(builder: (_) => DashboardPage());
      case features:
        return MaterialPageRoute(builder: (_) => FeaturesPage());
      case howItWorks:
        return MaterialPageRoute(builder: (_) => HowItWorksPage());
      case invest:
        return MaterialPageRoute(builder: (_) => InvestPage());
      case learnMore:
        return MaterialPageRoute(builder: (_) => LearnMorePage());
        case investmentMap:
        return MaterialPageRoute(builder: (_) => InvestmentMapScreen());
      case propertyDetails:
        final String propertyId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => PropertyDetailsPage(propertyId: propertyId),
        );
        case investmentAssistant:
        return MaterialPageRoute(
    builder: (_) => ChangeNotifierProvider<ChatController>.value(
      value: getIt<ChatController>(),
      child: const InvestmentAssistantScreen(),
    ),  
  );
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => ForgotPasswordPage());
      case preferences:
        final User user = settings.arguments as User;
        return MaterialPageRoute(
          builder: (_) => UserPreferencesScreen(user: user),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
      
    }
  }
}