import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/auth/domain/use_cases/login_use_case.dart';
import 'features/auth/domain/use_cases/sign_up_use_case.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/login_bloc.dart';
import 'features/auth/presentation/bloc/sign_up_bloc.dart';
import 'features/auth/presentation/pages/login_screen.dart';
import 'features/auth/presentation/pages/sign_up_screen.dart';
import 'features/auth/presentation/pages/home_screen.dart';
import 'features/auth/domain/entities/user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthRemoteDataSource>(
          create: (_) => AuthRemoteDataSourceImpl(),
        ),
        Provider<AuthRepository>(
          create: (context) => AuthRepositoryImpl(
            context.read<AuthRemoteDataSource>(),
          ),
        ),
        Provider<LoginUseCase>(
          create: (context) => LoginUseCase(
            context.read<AuthRepository>(),
          ),
        ),
        Provider<SignUpUseCase>(
          create: (context) => SignUpUseCase(
            context.read<AuthRepository>(),
          ),
        ),
      
        BlocProvider<LoginBloc>(
          create: (context) => LoginBloc(
            context.read<LoginUseCase>(),
          ),
        ),
        
        BlocProvider<SignUpBloc>(
          create: (context) => SignUpBloc(
            context.read<SignUpUseCase>(),
          ),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TheBoost',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: BlocBuilder<LoginBloc, LoginState>(
        builder: (context, state) {
          // Si l'utilisateur est déjà connecté, aller à HomeScreen
          if (state is LoginSuccess) {
            return HomeScreen(user: state.user);
          }
          // Sinon, afficher LoginScreen
          return LoginScreen();
        },
      ),
      routes: {
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignUpScreen(),
        '/home': (context) => BlocBuilder<LoginBloc, LoginState>(
          builder: (context, state) {
            if (state is LoginSuccess) {
              return HomeScreen(user: state.user);
            }
            // Rediriger vers login si non authentifié
            return LoginScreen();
          },
        ),
      },
      // Gestion de la navigation non authentifiée
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) {
            final state = context.read<LoginBloc>().state;
            if (state is! LoginSuccess) {
              return LoginScreen();
            }
            // Route par défaut si authentifié
            return HomeScreen(user: state.user);
          },
        );
      },
    );
  }
}

// Ajoutez cette extension pour faciliter l'accès à l'utilisateur connecté
extension AuthContextExtension on BuildContext {
  User? get currentUser {
    final state = read<LoginBloc>().state;
    if (state is LoginSuccess) {
      return state.user;
    }
    return null;
  }

  bool get isAuthenticated => currentUser != null;
}