// lib/features/auth/presentation/bloc/routes.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:the_boost/core/di/dependency_injection.dart';
import 'package:the_boost/core/services/prop_service.dart';
import 'package:the_boost/features/auth/presentation/bloc/investment/investment_bloc.dart';
import 'package:the_boost/features/auth/presentation/features_pages.dart';
import 'package:the_boost/features/auth/presentation/pages/investments/lands_screen.dart';
import 'package:the_boost/features/auth/presentation/pages/investments/profile_page.dart';
import 'package:the_boost/features/auth/presentation/pages/selling/token_selling_page.dart';
import 'package:the_boost/features/auth/presentation/pages/valuation/land_valuation_screen_with_nav.dart';
import 'package:the_boost/features/chatbot/presentation/controllers/chat_controller.dart';
import 'package:the_boost/features/chatbot/presentation/pages/chat_screen.dart';
import 'package:the_boost/features/land/presentation/bloc/my_lands/my_lands_bloc.dart';
import 'package:the_boost/features/land/presentation/pages/my_lands_page.dart';

import 'package:the_boost/features/auth/domain/entities/user.dart';
import 'package:the_boost/features/auth/presentation/features_pages.dart';
import 'package:the_boost/features/auth/presentation/pages/preferences/user_preferences_screen.dart';

import '../pages/auth/auth_page.dart';
import '../pages/auth/forgot_password_page.dart';
import '../pages/dashboard/dashboard_page.dart';
import '../pages/home/home_page.dart';
import '../pages/investments/invest_page.dart';
import '../pages/property_details/property_details_page.dart';
import '../widgets/howitworks_page.dart';
import '../widgets/learn_more_page.dart';

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
  static const String landValuation = '/land-valuation';
  static const String preferences = '/preferences';
  static const String profile = '/profile';
  static const String tokenSelling = '/token-selling';
  static const String myLands = '/my-lands';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => HomePage());
      case auth:
        return MaterialPageRoute(builder: (_) => const AuthPage());
      case dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardPage());
      case features:
        return MaterialPageRoute(builder: (_) => FeaturesPage());
      case howItWorks:
        return MaterialPageRoute(builder: (_) => HowItWorksPage());
      case invest:
        return MaterialPageRoute(builder: (_) => const InvestPage());
      case '/lands':
        return MaterialPageRoute(builder: (_) => const LandsScreen());
      case learnMore:
        return MaterialPageRoute(builder: (_) => LearnMorePage());
      case landValuation:
        return MaterialPageRoute(
          builder: (_) => LandValuationScreenWithNav(
            apiService: getIt<ApiService>(),
          ),
        );
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());
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
      case tokenSelling:
        // Récupérer les arguments si disponibles
        final Map<String, dynamic> args =
            settings.arguments as Map<String, dynamic>? ?? {};

        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: getIt<InvestmentBloc>(),
            child: TokenSellingPage(
              preselectedTokens: args['tokens'],
              initialSelectedIndex: args['selectedTokenIndex'] ?? 0,
              landName: args['landName'] ?? '',
            ),
          ),
        );
      case myLands:
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: getIt<MyLandsBloc>(),
            child: const MyLandsPage(),
          ),
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
