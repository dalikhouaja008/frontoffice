import 'package:get_it/get_it.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:dio/dio.dart';
import '../network/graphql_client.dart';
import '../services/secure_storage_service.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/data/repositories/two_factor_auth_repository.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/use_cases/login_use_case.dart';
import '../../features/auth/domain/use_cases/sign_up_use_case.dart';
import '../../features/auth/presentation/bloc/2FA/two_factor_auth_bloc.dart';
import '../../features/auth/presentation/bloc/login/login_bloc.dart';
import '../../features/auth/presentation/bloc/signup/sign_up_bloc.dart';
import '../../features/investment/data/repositories/land_repository.dart';
import '../../features/investment/presentation/bloc/land_bloc.dart';

final GetIt getIt = GetIt.instance;

/// Initialise toutes les dépendances de l'application
Future<void> initDependencies() async {
  print('DependencyInjection: 🚀 Initializing dependencies');

  //=== Core Services ===//
  await _initCoreServices();

  //=== Features ===//
  await _initAuthFeature();
  await _initInvestmentFeature();

  print('DependencyInjection: ✅ Dependencies initialized');
}

/// Initialise les services de base
Future<void> _initCoreServices() async {
  print('DependencyInjection: 🔄 Initializing core services');

  // Secure Storage
  if (!getIt.isRegistered<SecureStorageService>()) {
    getIt.registerLazySingleton<SecureStorageService>(
      () => SecureStorageService(),
    );
  }

  // GraphQL Client
  if (!getIt.isRegistered<GraphQLClient>()) {
    getIt.registerLazySingleton<GraphQLClient>(
      () => GraphQLService.client,
    );
  }

  // Dio Client
  if (!getIt.isRegistered<Dio>()) {
    getIt.registerLazySingleton<Dio>(() {
      final dio = Dio(BaseOptions(
        baseUrl: 'http://localhost:5000', // Ajustez selon votre configuration
        connectTimeout: 5000,
        receiveTimeout: 3000,
      ));
      return dio;
    });
  }

  print('DependencyInjection: ✅ Core services initialized');
}

/// Initialise les dépendances de la fonctionnalité d'authentification
Future<void> _initAuthFeature() async {
  print('DependencyInjection: 🔄 Initializing auth feature');

  // Data Sources
  if (!getIt.isRegistered<AuthRemoteDataSource>()) {
    getIt.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(
        client: getIt<GraphQLClient>(),
        secureStorage: getIt<SecureStorageService>(),
      ),
    );
  }

  // Repositories
  if (!getIt.isRegistered<AuthRepository>()) {
    getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(getIt<AuthRemoteDataSource>()),
    );
  }

  if (!getIt.isRegistered<TwoFactorAuthRepository>()) {
    getIt.registerLazySingleton<TwoFactorAuthRepository>(
      () => TwoFactorAuthRepositoryImpl(getIt<AuthRemoteDataSource>()),
    );
  }

  // Use Cases
  if (!getIt.isRegistered<LoginUseCase>()) {
    getIt.registerLazySingleton<LoginUseCase>(() => LoginUseCase(
          repository: getIt<AuthRepository>(),
        ));
  }

  if (!getIt.isRegistered<SignUpUseCase>()) {
    getIt.registerLazySingleton<SignUpUseCase>(() => SignUpUseCase(
          getIt<AuthRepository>(),
        ));
  }

  // BLoCs
  getIt.registerFactory<LoginBloc>(() => LoginBloc(
        loginUseCase: getIt<LoginUseCase>(),
        secureStorage: getIt<SecureStorageService>(),
      ));

  getIt.registerFactory<SignUpBloc>(() => SignUpBloc(
        getIt<SignUpUseCase>(),
      ));

  getIt.registerFactory<TwoFactorAuthBloc>(() => TwoFactorAuthBloc(
        repository: getIt<TwoFactorAuthRepository>(),
      ));

  print('DependencyInjection: ✅ Auth feature initialized');
}

/// Initialise les dépendances de la fonctionnalité d'investissement
Future<void> _initInvestmentFeature() async {
  print('DependencyInjection: 🔄 Initializing investment feature');

  try {
    // Repository
    if (!getIt.isRegistered<LandRepository>()) {
      getIt.registerLazySingleton<LandRepository>(
        () => LandRepository(),
      );
      print('DependencyInjection: ✅ LandRepository registered');
    }

    // Bloc
    getIt.registerFactory<LandBloc>(
      () => LandBloc(getIt<LandRepository>()),
    );
    print('DependencyInjection: ✅ LandBloc registered');

    print('DependencyInjection: ✅ Investment feature initialized');
  } catch (e) {
    print('DependencyInjection: ❌ Error initializing investment feature: $e');
  }
}