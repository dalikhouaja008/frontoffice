import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_boost/core/constants/colors.dart';
import 'package:the_boost/core/di/dependency_injection.dart';
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
  
  runApp(const TheBoostApp());
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
      child: MaterialApp(
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
        initialRoute: AppRoutes.home,
        onGenerateRoute: AppRoutes.generateRoute,
        builder: (context, child) {
          return BlocBuilder<LoginBloc, LoginState>(
            builder: (context, state) {
              // Redirect to dashboard if logged in and trying to access auth page
              if (child?.key == const ValueKey('AuthPage') && state is LoginSuccess) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
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