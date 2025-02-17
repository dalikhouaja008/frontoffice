import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:the_boost/core/network/graphql_client.dart';
import 'package:the_boost/core/services/secure_storage_service.dart';
import 'package:the_boost/features/land/presentation/pages/add_land_page.dart';

// Import Land feature dependencies
import 'features/auth/presentation/pages/login_screen.dart';
import 'features/land/data/datasources/land_remote_data_source.dart';
import 'features/land/data/repositories/land_repository_impl.dart';
import 'features/land/domain/repositories/land_repository.dart';
import 'features/land/domain/use_cases/add_land_use_case.dart';
import 'features/land/domain/use_cases/get_all_lands_use_case.dart';
import 'features/land/presentation/bloc/land_bloc.dart';

import 'features/auth/domain/use_cases/login_use_case.dart';
import 'features/auth/domain/use_cases/sign_up_use_case.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/login/login_bloc.dart';
import 'features/auth/presentation/bloc/signup/sign_up_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final secureStorage = SecureStorageService();
  final graphQLClient = GraphQLService.client;

  runApp(
    GraphQLProvider(
      client: ValueNotifier(graphQLClient),
      child: MultiProvider(
        providers: [
          Provider<SecureStorageService>.value(value: secureStorage),
          Provider<GraphQLClient>.value(value: graphQLClient),

          // Auth Providers
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

          // Land Providers
          Provider<LandRemoteDataSource>(
            create: (context) => LandRemoteDataSource(context.read<GraphQLClient>()),
          ),
          Provider<LandRepository>(
            create: (context) => LandRepositoryImpl(context.read<LandRemoteDataSource>()),
          ),
          Provider<AddLandUseCase>(
            create: (context) => AddLandUseCase(context.read<LandRepository>()),
          ),
          Provider<GetAllLandsUseCase>(
            create: (context) => GetAllLandsUseCase(context.read<LandRepository>()),
          ),
          BlocProvider<LandBloc>(
            create: (context) => LandBloc(
              context.read<AddLandUseCase>(),
              context.read<GetAllLandsUseCase>(),
            ),
          ),
        ],
        child: const MyApp(),
      ),
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
      ),
      home:  LoginScreen(),
    );
  }
}
