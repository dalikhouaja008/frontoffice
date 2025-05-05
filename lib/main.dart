import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:the_boost/core/constants/colors.dart';
import 'package:the_boost/core/di/dependency_injection.dart';
import 'package:the_boost/core/services/preferences_service.dart';
import 'package:the_boost/core/services/session_service.dart';
import 'package:the_boost/features/auth/presentation/bloc/lands/land_bloc.dart';
import 'package:the_boost/features/auth/presentation/bloc/login/login_bloc.dart';
import 'package:the_boost/features/auth/presentation/bloc/login/login_state.dart';
import 'package:the_boost/features/auth/presentation/bloc/property/property_bloc.dart';
import 'package:the_boost/features/auth/presentation/bloc/routes.dart';
import 'package:the_boost/features/auth/presentation/bloc/signup/sign_up_bloc.dart';
import 'package:the_boost/features/auth/presentation/bloc/preferences/preferences_bloc.dart';
import 'package:the_boost/features/metamask/data/models/metamask_provider.dart';
import 'dart:developer' as developer;
// Add marketplace bloc import
import 'package:the_boost/features/marketplace/presentation/bloc/marketplace_bloc.dart';
import 'package:the_boost/features/marketplace/presentation/bloc/marketplace_event.dart';


class SimpleBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    print('${bloc.runtimeType} State Change: ${change.currentState.runtimeType} -> ${change.nextState.runtimeType}');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print('${bloc.runtimeType} Transition: ${transition.event.runtimeType} -> ${transition.nextState.runtimeType}');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    print('${bloc.runtimeType} Error: $error');
    super.onError(bloc, error, stackTrace);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ FIRST Load .env file before anything else
  await dotenv.load(fileName: "assets/.env"); // ✅ Notice the assets/ prefix

  Bloc.observer = SimpleBlocObserver();

  await initDependencies();
  await registerChatbotDependencies();
  
  // Register MetamaskProvider in the dependency injection
  getIt.registerSingleton<MetamaskProvider>(MetamaskProvider());
  developer.log('[2025-05-05 00:05:53] Main: 🔄 Registered MetamaskProvider in dependency injection');

  await _checkExistingSession();

  runApp(const TheBoostApp());
}

Future<void> _checkExistingSession() async {
  print('[2025-05-05 00:05:53] Main: 🔄 Checking for existing session');
  try {
    final sessionService = getIt<SessionService>();
    final sessionData = await sessionService.getSession();
    if (sessionData != null) {
      print('[2025-05-05 00:05:53] Main: ✅ Found existing session'
          '\n└─ User: ${sessionData.user.username} (${sessionData.user.id})'
          '\n└─ Email: ${sessionData.user.email}');
      getIt<LoginBloc>().add(CheckSession());
      await Future.delayed(const Duration(milliseconds: 100));
    } else {
      print('[2025-05-05 00:05:53] Main: ℹ️ No existing session found');
    }
  } catch (e) {
    print('[2025-05-05 00:05:53] Main: ❌ Error checking session'
          '\n└─ Error: $e');
  }
}

class TheBoostApp extends StatelessWidget {
  const TheBoostApp({super.key});

  @override
  Widget build(BuildContext context) {
    developer.log('[2025-05-05 00:05:53] TheBoostApp: 🔄 Building app with user: raednas');
    
    return MultiProvider(
      providers: [
          ChangeNotifierProvider<MetamaskProvider>.value(value: getIt<MetamaskProvider>()),
        BlocProvider<LoginBloc>.value(value: getIt<LoginBloc>()),
        BlocProvider<SignUpBloc>(create: (_) => getIt<SignUpBloc>()),
        BlocProvider<PropertyBloc>(create: (_) => getIt<PropertyBloc>()),
        BlocProvider<PreferencesBloc>(create: (_) => getIt<PreferencesBloc>()),
        BlocProvider<LandBloc>(create: (_) => getIt<LandBloc>()),
        // Add MarketplaceBloc provider
        BlocProvider<MarketplaceBloc>(create: (_) => getIt<MarketplaceBloc>()),
      ],
      child: BlocConsumer<LoginBloc, LoginState>(
        listener: (context, state) {
          final preferencesService = getIt<PreferencesService>();
          if (state is LoginSuccess) {
            print('[2025-05-05 03:35:15] TheBoostApp: 👤 User authenticated'
                '\n└─ User: ${state.user.username}'
                '\n└─ Email: ${state.user.email}');
            preferencesService.startPeriodicMatching(state.user.id);
            BlocProvider.of<MarketplaceBloc>(context).add(GetAllListingsEvent());
          } else if (state is LoginInitial) {
            print('[2025-05-05 03:35:15] TheBoostApp: 🔒 No active session');
            preferencesService.stopPeriodicMatching();
          }
        },
        builder: (context, state) {
          final isAuthenticated = state is LoginSuccess;
          return MaterialApp(
            title: 'TheBoost - Land Investment via Tokenization',
            theme: ThemeData(
              primaryColor: AppColors.primary,
              colorScheme: const ColorScheme.light(
                primary: AppColors.primary,
                secondary: AppColors.primaryLight,
                surface: Colors.white,
                background: Colors.white,
              ),
              textTheme: GoogleFonts.poppinsTextTheme(),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            debugShowCheckedModeBanner: false,
            initialRoute: isAuthenticated ? AppRoutes.dashboard : AppRoutes.home,
            onGenerateRoute: AppRoutes.generateRoute,
            builder: (context, child) {
              final currentState = context.watch<LoginBloc>().state;
              final isCurrentlyAuthenticated = currentState is LoginSuccess;
              if (child?.key == const ValueKey('AuthPage') && isCurrentlyAuthenticated) {
                print('[2025-05-05 03:35:15] TheBoostApp: 🔄 Redirecting from auth to dashboard');
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
                });
              }
              if ((child?.key == const ValueKey('DashboardPage') ||
                      child?.key == const ValueKey('InvestPage') ||
                      child?.key == const ValueKey('PropertyDetailsPage')) &&
                  !isCurrentlyAuthenticated) {
                print('[2025-05-05 03:35:15] TheBoostApp: 🔄 Redirecting to auth');
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.of(context).pushReplacementNamed(AppRoutes.auth);
                });
              }
              return child!;
            },
          );
        },
      ),
    );
  }
}