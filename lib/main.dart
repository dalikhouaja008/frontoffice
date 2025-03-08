import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_boost/features/auth/presentation/bloc/login/login_state.dart';
import 'package:the_boost/features/auth/presentation/pages/auth/auth_page.dart';
import 'package:the_boost/features/auth/presentation/pages/dashboard/dashboard_page.dart';
import 'package:the_boost/features/auth/presentation/pages/investments/investment_page.dart';
import 'core/constants/colors.dart';
import 'core/di/dependency_injection.dart';
import 'features/auth/presentation/bloc/login/login_bloc.dart';
import 'features/auth/presentation/bloc/signup/sign_up_bloc.dart';
import 'features/auth/presentation/bloc/property/property_bloc.dart';
import 'features/investment/presentation/bloc/land_bloc.dart';
import 'features/investment/data/repositories/land_repository.dart';
import 'features/auth/presentation/bloc/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
        BlocProvider<LandBloc>(
          create: (_) => LandBloc(LandRepository())..add(LoadLandsEvent()),
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
        routes: {
          AppRoutes.home: (context) => const AuthPage(),
          AppRoutes.dashboard: (context) => const DashboardPage(),
          AppRoutes.investment: (context) => const InvestmentPage(),
        },
        onGenerateRoute: AppRoutes.generateRoute,
        builder: (context, child) {
          return BlocBuilder<LoginBloc, LoginState>(
            builder: (context, state) {
              if (state is LoginSuccess && child?.key == const ValueKey('AuthPage')) {
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