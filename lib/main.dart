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

void main() async {
  // Assurez-vous que les liaisons Flutter sont initialisées
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialiser toutes les dépendances
  await initDependencies();
  
  // Initialize session by checking for existing login
  await _checkExistingSession();
  
  // Run the app
  runApp(const TheBoostApp());
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
      
      // Trigger check session in the LoginBloc to restore the session
      getIt<LoginBloc>().add(CheckSession());
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
    return MultiBlocProvider(
      providers: [
        BlocProvider<LoginBloc>(
          create: (_) => getIt<LoginBloc>(),
        ),
        BlocProvider<SignUpBloc>(
          create: (_) => getIt<SignUpBloc>(),
        ),
        BlocProvider<PropertyBloc>(
          create: (_) => getIt<PropertyBloc>(),
        ),
      ],
      child: BlocConsumer<LoginBloc, LoginState>(
        listener: (context, state) {
          // Listen for session state changes if needed for global app reactions
          if (state is LoginSuccess) {
            print('[2025-03-08 10:15:23] TheBoostApp: 👤 User authenticated'
                  '\n└─ User: ${state.user.username}'
                  '\n└─ Email: ${state.user.email}');
          } else if (state is LoginInitial) {
            print('[2025-03-08 10:15:23] TheBoostApp: 🔒 No active session');
          }
        },
        builder: (context, state) {
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
            initialRoute: state is LoginSuccess ? AppRoutes.dashboard : AppRoutes.home,
            onGenerateRoute: AppRoutes.generateRoute,
            builder: (context, child) {
              // Redirect to dashboard if logged in and trying to access auth page
              if (child?.key == const ValueKey('AuthPage') && state is LoginSuccess) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
                });
              }

              // Redirect to home/auth if not logged in and trying to access protected pages
              if ((child?.key == const ValueKey('DashboardPage') || 
                   child?.key == const ValueKey('InvestPage') ||
                   child?.key == const ValueKey('PropertyDetailsPage')) && 
                  !(state is LoginSuccess)) {
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