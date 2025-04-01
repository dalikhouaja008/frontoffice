import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_boost/core/constants/colors.dart';
import 'package:the_boost/core/di/dependency_injection.dart';
import 'package:the_boost/core/services/session_service.dart';
import 'package:the_boost/features/auth/presentation/bloc/login/login_bloc.dart';
import 'package:the_boost/features/auth/presentation/bloc/login/login_state.dart';
import 'package:the_boost/features/auth/presentation/bloc/property/property_bloc.dart';
import 'package:the_boost/features/auth/presentation/bloc/routes.dart';
import 'package:the_boost/features/auth/presentation/bloc/signup/sign_up_bloc.dart';
import 'package:the_boost/features/auth/presentation/bloc/preferences/preferences_bloc.dart';

// Custom BlocObserver for debugging state changes
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
  // Make sure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set up Bloc observer for easier debugging
  Bloc.observer = SimpleBlocObserver();

  // Initialize all dependencies
  await initDependencies();
  await registerChatbotDependencies();

  // Initialize session by checking for existing login
  await _checkExistingSession();

  // Run the app
  runApp(const TheBoostApp());
}

/// Checks for existing session and initializes the LoginBloc accordingly
Future<void> _checkExistingSession() async {
  print('[${DateTime.now()}] Main: 🔄 Checking for existing session');

  try {
    final sessionService = getIt<SessionService>();
    final sessionData = await sessionService.getSession();

    if (sessionData != null) {
      print('[${DateTime.now()}] Main: ✅ Found existing session'
          '\n└─ User: ${sessionData.user.username}'
          '\n└─ Email: ${sessionData.user.email}');

      // Directly trigger CheckSession in the LoginBloc to restore the session
      getIt<LoginBloc>().add(CheckSession());

      // Add a small delay to allow the event to be processed
      await Future.delayed(const Duration(milliseconds: 100));
    } else {
      print('[${DateTime.now()}] Main: ℹ️ No existing session found');
    }
  } catch (e) {
    print('[${DateTime.now()}] Main: ❌ Error checking session'
        '\n└─ Error: $e');
  }
}

class TheBoostApp extends StatelessWidget {
  const TheBoostApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Use BlocProvider.value to maintain the same instance of LoginBloc throughout the app
        BlocProvider<LoginBloc>.value(value: getIt<LoginBloc>()),
        BlocProvider<SignUpBloc>(create: (_) => getIt<SignUpBloc>()),
        BlocProvider<PropertyBloc>(create: (_) => getIt<PropertyBloc>()),
        BlocProvider<PreferencesBloc>(create: (_) => getIt<PreferencesBloc>()),
      ],
      child: BlocConsumer<LoginBloc, LoginState>(
        listener: (context, state) {
          // Listen for session state changes
          if (state is LoginSuccess) {
            print('[${DateTime.now()}] TheBoostApp: 👤 User authenticated'
                '\n└─ User: ${state.user.username}'
                '\n└─ Email: ${state.user.email}');
          } else if (state is LoginInitial) {
            print('[${DateTime.now()}] TheBoostApp: 🔒 No active session');
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
              // Access the current auth state again to ensure it's up to date
              final currentState = context.watch<LoginBloc>().state;
              final isCurrentlyAuthenticated = currentState is LoginSuccess;

              // Redirect to dashboard if logged in and trying to access auth page
              if (ModalRoute.of(context)?.settings.name == AppRoutes.auth &&
                  isCurrentlyAuthenticated) {
                print('[${DateTime.now()}] TheBoostApp: 🔄 Redirecting from auth to dashboard (already logged in)');

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
                });
              }

              // Redirect to home/auth if not logged in and trying to access protected pages
              if ((ModalRoute.of(context)?.settings.name == AppRoutes.dashboard ||
                      ModalRoute.of(context)?.settings.name == AppRoutes.invest ||
                      ModalRoute.of(context)?.settings.name == AppRoutes.propertyDetails) &&
                  !isCurrentlyAuthenticated) {
                print('[${DateTime.now()}] TheBoostApp: 🔄 Redirecting to auth (protected page, not logged in)');

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