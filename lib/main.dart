import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
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
import 'features/auth/domain/entities/user.dart'; // Import User entity

void main() {
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
    // Create a dummy user for demonstration purposes
    User dummyUser = User(
      username: 'demo_user',
      email: 'demo_user@example.com',
      role: 'investor', id: '',
    );

    return MaterialApp(
      title: 'TheBoost',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomeScreen(user: dummyUser), // Pass the dummy user to HomeScreen
    );
  }
}