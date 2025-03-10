import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart'; //est une interface que tous les types de providers (Provider, BlocProvider, etc.) implémentent, ce qui nous permet de les utiliser ensemble dans la même liste.
import 'package:the_boost/core/network/graphql_client.dart';
import 'package:the_boost/core/services/secure_storage_service.dart';
import 'package:the_boost/core/services/session_service.dart';
import 'package:the_boost/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:the_boost/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:the_boost/features/auth/data/repositories/two_factor_auth_repository.dart';
import 'package:the_boost/features/auth/domain/repositories/auth_repository.dart';
import 'package:the_boost/features/auth/domain/use_cases/login_use_case.dart';
import 'package:the_boost/features/auth/domain/use_cases/sign_up_use_case.dart';
import 'package:the_boost/features/auth/presentation/bloc/2FA/two_factor_auth_bloc.dart';
import 'package:the_boost/features/auth/presentation/bloc/login/login_bloc.dart';
import 'package:the_boost/features/auth/presentation/bloc/signup/sign_up_bloc.dart';

class InjectionContainer {
  static late final SecureStorageService _secureStorage;
  static late final GraphQLClient _graphQLClient;
  static late final SessionService _sessionService;

  static void init() {
    print('injection DI: 🚀 Initializing dependency injection');

    _secureStorage = SecureStorageService();
    _graphQLClient = GraphQLService.client;
    _sessionService = SessionService();
  }

  static List<SingleChildWidget> get providers => [
        // Services Core
        _provideCoreServices(),

        // Data Sources
        _provideDataSources(),

        // Repositories
        _provideRepositories(),

        // Use Cases
        _provideUseCases(),

        // Blocs
        _provideBlocs(),
      ].expand((x) => x).toList();

  static List<SingleChildWidget> _provideBlocs() {
    print('injection: DI: 🧩 Setting up blocs');

    return [
      BlocProvider<LoginBloc>(
        create: (context) => LoginBloc(
          loginUseCase: context.read<LoginUseCase>(),
          secureStorage: context.read<SecureStorageService>(),
          sessionService: context.read<SessionService>(),
        ),
      ),
      BlocProvider<SignUpBloc>(
        create: (context) => SignUpBloc(
          context.read<SignUpUseCase>(),
        ),
      ),
      BlocProvider<TwoFactorAuthBloc>(
          create: (context) => TwoFactorAuthBloc(
                repository: context.read<TwoFactorAuthRepository>(),
              )),
    ];
  }

  static List<SingleChildWidget> _provideCoreServices() {
    print('injection DI: 🔧 Setting up core services');

    return [
      Provider<SecureStorageService>.value(value: _secureStorage),
      Provider<GraphQLClient>.value(value: _graphQLClient),
      Provider<SessionService>.value(value: _sessionService),
    ];
  }

  static List<SingleChildWidget> _provideDataSources() {
    print('injection: DI: 📡 Setting up data sources');

    return [
      Provider<AuthRemoteDataSource>(
        create: (context) => AuthRemoteDataSourceImpl(
          client: context.read<GraphQLClient>(),
          secureStorage: context.read<SecureStorageService>(),
        ),
      ),
    ];
  }

  static List<SingleChildWidget> _provideRepositories() {
    print('injection DI: 📚 Setting up repositories');

    return [
      Provider<AuthRepository>(
        create: (context) => AuthRepositoryImpl(
          context.read<AuthRemoteDataSource>(),
        ),
      ),
      Provider<TwoFactorAuthRepository>(
        create: (context) => TwoFactorAuthRepositoryImpl(
          context.read<AuthRemoteDataSource>(),
        ),
      ),
    ];
  }

  static List<SingleChildWidget> _provideUseCases() {
    print('injection: DI: 🔄 Setting up use cases');

    return [
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
    ];
  }
}