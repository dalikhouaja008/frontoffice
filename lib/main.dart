// lib/main.dart
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
import 'features/auth/presentation/bloc/preferences/preferences_bloc.dart';
import 'package:provider/provider.dart';
import 'data/auth_service.dart';
import 'features/metamask/data/models/metamask_provider.dart';


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

  //metamask provider instance 
    final metamaskProvider = MetamaskProvider();
  
  // Run the app
  runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider<MetamaskProvider>.value(
          value: metamaskProvider,
        ),
      ],
      child: const TheBoostApp(),
    ),);
}

/// Checks for existing session and initializes the LoginBloc accordingly
Future<void> _checkExistingSession() async {
  print('[2025-03-08 10:15:23] Main: 🔄 Checking for existing session');
  
  try {
    final sessionService = getIt<SessionService>();
    final sessionData = await sessionService.getSession();
    
    if (sessionData != null) {
      print('[2025-03-08 10:15:23] Main: ✅ Found existing session'
            '\n└─ User: ${sessionData.user.username}'
            '\n└─ Email: ${sessionData.user.email}');
      
      // Directly trigger CheckSession in the LoginBloc to restore the session
      getIt<LoginBloc>().add(CheckSession());
      
      // Add a small delay to allow the event to be processed
      await Future.delayed(Duration(milliseconds: 100));
    } else {
      print('[2025-03-08 10:15:23] Main: ℹ️ No existing session found');
    }
  } catch (e) {
    print('[2025-03-08 10:15:23] Main: ❌ Error checking session'
          '\n└─ Error: $e');
  }
}

class TheBoostApp extends StatelessWidget {
  const TheBoostApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Important: Get the current state of the LoginBloc to determine initial route
    final loginState = getIt<LoginBloc>().state;
    final isAuthenticated = loginState is LoginSuccess;
    
    print('[2025-03-08 10:15:23] TheBoostApp: 🔄 Building app'
          '\n└─ Current auth state: ${loginState.runtimeType}'
          '\n└─ Is authenticated: $isAuthenticated');
    
    return MultiBlocProvider(
      providers: [
        // Use BlocProvider.value to maintain the same instance of LoginBloc throughout the app
        BlocProvider<LoginBloc>.value(
          value: getIt<LoginBloc>(),
        ),
        BlocProvider<SignUpBloc>(
          create: (_) => getIt<SignUpBloc>(),
        ),
        BlocProvider<PropertyBloc>(
          create: (_) => getIt<PropertyBloc>(),
        ),
         BlocProvider<PreferencesBloc>(
      create: (_) => getIt<PreferencesBloc>(),
    ),
      ],
      child: BlocConsumer<LoginBloc, LoginState>(
        listener: (context, state) {
          // Listen for session state changes
          if (state is LoginSuccess) {
            print('[2025-03-08 10:15:23] TheBoostApp: 👤 User authenticated'
                  '\n└─ User: ${state.user.username}'
                  '\n└─ Email: ${state.user.email}');
          } else if (state is LoginInitial) {
            print('[2025-03-08 10:15:23] TheBoostApp: 🔒 No active session');
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
              if (child?.key == const ValueKey('AuthPage') && isCurrentlyAuthenticated) {
                print('[2025-03-08 10:15:23] TheBoostApp: 🔄 Redirecting from auth to dashboard (already logged in)');
                
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
                });
              }

              // Redirect to home/auth if not logged in and trying to access protected pages
              if ((child?.key == const ValueKey('DashboardPage') || 
                   child?.key == const ValueKey('InvestPage') ||
                   child?.key == const ValueKey('PropertyDetailsPage')) && 
                  !isCurrentlyAuthenticated) {
                print('[2025-03-08 10:15:23] TheBoostApp: 🔄 Redirecting to auth (protected page, not logged in)');
                
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