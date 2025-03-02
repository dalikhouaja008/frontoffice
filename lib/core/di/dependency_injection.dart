import 'package:get_it/get_it.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:the_boost/core/network/graphql_client.dart';
import 'package:the_boost/core/services/secure_storage_service.dart';
import 'package:the_boost/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:the_boost/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:the_boost/features/auth/data/repositories/two_factor_auth_repository.dart';
import 'package:the_boost/features/auth/domain/repositories/auth_repository.dart';
import 'package:the_boost/features/auth/domain/repositories/property_repository.dart';
import 'package:the_boost/features/auth/domain/use_cases/investments/get_properties_usecase.dart';
import 'package:the_boost/features/auth/domain/use_cases/login_use_case.dart';
import 'package:the_boost/features/auth/domain/use_cases/sign_up_use_case.dart';
import 'package:the_boost/features/auth/presentation/bloc/2FA/two_factor_auth_bloc.dart';
import 'package:the_boost/features/auth/presentation/bloc/login/login_bloc.dart';
import 'package:the_boost/features/auth/presentation/bloc/property/property_bloc.dart';
import 'package:the_boost/features/auth/presentation/bloc/signup/sign_up_bloc.dart';

final GetIt getIt = GetIt.instance;

/// Initialise toutes les dépendances de l'application
Future<void> initDependencies() async {
  //=== Core ===//
  
  // Services
  getIt.registerLazySingleton<SecureStorageService>(() => SecureStorageService());
  getIt.registerLazySingleton<GraphQLClient>(() => GraphQLService.client);
  
  //=== Features ===//
  await _initAuthFeature();
  await _initPropertyFeature();
}

/// Initialise les dépendances de la fonctionnalité d'authentification
Future<void> _initAuthFeature() async {
  // Data Sources
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      client: getIt<GraphQLClient>(),
      secureStorage: getIt<SecureStorageService>(),
    ),
  );
  // Ajoutez ceci à votre méthode d'initialisation des dépendances pour l'authentification
  
  // Two Factor Authentication
  getIt.registerFactory<TwoFactorAuthBloc>(() => TwoFactorAuthBloc(
    repository: getIt<TwoFactorAuthRepository>(),
  ));
  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt<AuthRemoteDataSource>()),
  );
  
  getIt.registerLazySingleton<TwoFactorAuthRepository>(
    () => TwoFactorAuthRepositoryImpl(getIt<AuthRemoteDataSource>()),
  );
  
  // Use Cases
  getIt.registerLazySingleton<LoginUseCase>(() => LoginUseCase(
    repository: getIt<AuthRepository>(),
  ));
  
  getIt.registerLazySingleton<SignUpUseCase>(() => SignUpUseCase(
    getIt<AuthRepository>(),
  ));
  
  // BLoCs
  getIt.registerFactory<LoginBloc>(() => LoginBloc(
    loginUseCase: getIt<LoginUseCase>(),
    secureStorage: getIt<SecureStorageService>(),
  ));
  
  getIt.registerFactory<SignUpBloc>(() => SignUpBloc(
    getIt<SignUpUseCase>(),
  ));
}

/// Initialise les dépendances de la fonctionnalité de gestion des propriétés
Future<void> _initPropertyFeature() async {
  // Use Cases
  getIt.registerLazySingleton<GetPropertiesUseCase>(() => GetPropertiesUseCase(
    getIt<PropertyRepository>()
  ));
  
  // BLoCs
  getIt.registerFactory<PropertyBloc>(() => PropertyBloc(
    getPropertiesUseCase: getIt<GetPropertiesUseCase>(),
  ));
  
  // Vous pouvez ajouter d'autres repositories, data sources, etc. liés aux propriétés ici
}