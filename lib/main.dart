import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:the_boost/core/network/graphql_client.dart';
import 'package:the_boost/core/services/secure_storage_service.dart';
import 'features/auth/domain/use_cases/login_use_case.dart';
import 'features/auth/domain/use_cases/sign_up_use_case.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/login/login_bloc.dart';
import 'features/auth/presentation/bloc/signup/sign_up_bloc.dart';
import 'features/auth/presentation/pages/login_screen.dart';

void main() {
  // Assurez-vous que les liaisons Flutter sont initialisées
  WidgetsFlutterBinding.ensureInitialized();

  // Créez une instance unique de SecureStorageService
  final secureStorage = SecureStorageService();
   // Créez une instance du client GraphQL
  final graphQLClient = GraphQLService.client;


  runApp(
    MultiProvider(
      providers: [
        // Ajout du provider pour SecureStorageService
        // Provider pour SecureStorageService
        Provider<SecureStorageService>.value(
          value: secureStorage,
        ),
        // Provider pour GraphQLClient
        Provider<GraphQLClient>.value(
          value: graphQLClient,
        ),
         Provider<AuthRemoteDataSource>(
          create: (context) => AuthRemoteDataSourceImpl(
            client: context.read<GraphQLClient>(),
            secureStorage: context.read<SecureStorageService>(),
          ),
        ),
        Provider<AuthRepository>(
          create: (context) => AuthRepositoryImpl(
            context.read<AuthRemoteDataSource>(),
          ),
        ),
        Provider<LoginUseCase>(
          create: (context) => LoginUseCase(
            repository: context.read<AuthRepository>(),
          ),
        ),
        Provider<SignUpUseCase>(
          create: (context) => SignUpUseCase(
            context.read<AuthRepository>(),
          ),
        ),
        BlocProvider<LoginBloc>(
          create: (context) => LoginBloc(
            loginUseCase: context.read<LoginUseCase>(),
            secureStorage: context.read<SecureStorageService>(),
          ),
        ),
        BlocProvider<SignUpBloc>(
          create: (context) => SignUpBloc(
            context.read<SignUpUseCase>(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TheBoost',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // Ajoutez d'autres configurations de thème si nécessaire
      ),
      home: const LoginScreen(),
    );
  }
}