import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_boost/core/constants/colors.dart';
import 'package:the_boost/core/di/dependency_injection.dart';
import 'package:the_boost/core/services/preferences_service.dart';
import 'package:the_boost/features/auth/presentation/bloc/lands/land_bloc.dart';
import 'package:the_boost/features/auth/presentation/bloc/login/login_bloc.dart';
import 'package:the_boost/features/auth/presentation/bloc/login/login_state.dart';
import 'package:the_boost/features/auth/presentation/bloc/property/property_bloc.dart';
import 'package:the_boost/features/auth/presentation/bloc/routes.dart';
import 'package:the_boost/features/auth/presentation/bloc/signup/sign_up_bloc.dart';
import 'package:the_boost/features/auth/presentation/bloc/preferences/preferences_bloc.dart';
import 'package:provider/provider.dart';
import 'features/metamask/data/models/metamask_provider.dart';

class SimpleBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    print(
        '${bloc.runtimeType} State Change: ${change.currentState.runtimeType} -> ${change.nextState.runtimeType}');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print(
        '${bloc.runtimeType} Transition: ${transition.event.runtimeType} -> ${transition.nextState.runtimeType}');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    print('${bloc.runtimeType} Error: $error');
    super.onError(bloc, error, stackTrace);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = SimpleBlocObserver();

  // Initialiser les dépendances
  await initDependencies();
  await registerChatbotDependencies();

  // Ne vérifiez pas la session ici, laissez le bloc le faire

  // Préparez le provider MetaMask
  final metamaskProvider = MetamaskProvider();

  // Run the app
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<MetamaskProvider>.value(
          value: metamaskProvider,
        ),
      ],
      child: const TheBoostApp(),
    ),
  );
}

class TheBoostApp extends StatelessWidget {
  const TheBoostApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Créez le bloc et vérifiez la session immédiatement
        BlocProvider<LoginBloc>(
          create: (context) {
            final bloc = getIt<LoginBloc>();

            // Vérifiez la session mais avec un petit délai pour permettre à l'UI de s'initialiser
            Future.delayed(Duration(milliseconds: 100), () {
              print(
                  '[2025-05-03 20:01:48] TheBoostApp: 🔍 Checking session after initialization');
              bloc.add(CheckSession());
            });

            return bloc;
          },
        ),
        BlocProvider<SignUpBloc>(create: (_) => getIt<SignUpBloc>()),
        BlocProvider<PropertyBloc>(create: (_) => getIt<PropertyBloc>()),
        BlocProvider<PreferencesBloc>(create: (_) => getIt<PreferencesBloc>()),
        BlocProvider<LandBloc>(create: (_) => getIt<LandBloc>()),
      ],
      child: BlocConsumer<LoginBloc, LoginState>(
        listenWhen: (previous, current) {
          // Important: loggez chaque changement d'état pour débogage
          print(
              '[2025-05-03 19:31:16] TheBoostApp: 🔍 Auth state changed: ${previous.runtimeType} -> ${current.runtimeType}');
          return previous.runtimeType != current.runtimeType;
        },
        listener: (context, state) {
          final preferencesService = getIt<PreferencesService>();
          if (state is LoginSuccess) {
            print('[2025-05-03 19:31:16] TheBoostApp: 👤 User authenticated'
                '\n└─ User: ${state.user.username}'
                '\n└─ Email: ${state.user.email}');
            preferencesService.startPeriodicMatching(state.user.id);
          } else if (state is LoginInitial) {
            print('[2025-05-03 19:31:16] TheBoostApp: 🔒 No active session');
            preferencesService.stopPeriodicMatching();
          }
        },
        builder: (context, state) {
          // Utilisez l'état passé par le BlocConsumer
          final isAuthenticated = state is LoginSuccess;

          print(
              '[2025-05-03 19:31:16] TheBoostApp: 🏗️ Building app with auth state: ${state.runtimeType}');
          print(
              '[2025-05-03 19:31:16] TheBoostApp: 🔑 IsAuthenticated: $isAuthenticated');

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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            debugShowCheckedModeBanner: false,
            initialRoute:
                isAuthenticated ? AppRoutes.dashboard : AppRoutes.home,
            onGenerateRoute: AppRoutes.generateRoute,
            builder: (context, child) {
              // Utilisez l'état déjà disponible via closure
              if (child?.key == const ValueKey('AuthPage') && isAuthenticated) {
                print(
                    '[2025-05-03 19:31:16] TheBoostApp: 🔄 Redirecting from auth to dashboard');
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.of(context)
                      .pushReplacementNamed(AppRoutes.dashboard);
                });
              }
              if ((child?.key == const ValueKey('DashboardPage') ||
                      child?.key == const ValueKey('InvestPage') ||
                      child?.key == const ValueKey('PropertyDetailsPage')) &&
                  !isAuthenticated) {
                print(
                    '[2025-05-03 19:31:16] TheBoostApp: 🔄 Redirecting to auth');
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
