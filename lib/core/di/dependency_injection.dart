// lib/core/di/dependency_injection.dart
import 'package:get_it/get_it.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:the_boost/core/network/graphql_client.dart';
import 'package:the_boost/core/services/notification_service.dart';
import 'package:the_boost/core/services/preferences_service.dart';
import 'package:the_boost/core/services/secure_storage_service.dart';
import 'package:the_boost/core/services/session_service.dart';
import 'package:the_boost/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:the_boost/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:the_boost/features/auth/data/repositories/property_repository_impl.dart';
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
  print('DependencyInjection: 🚀 Initializing dependencies');

  //=== Core ===//

  // Services
  getIt.registerLazySingleton<SecureStorageService>(
      () => SecureStorageService());
  getIt.registerLazySingleton<GraphQLClient>(() => GraphQLService.client);
  getIt.registerLazySingleton<SessionService>(() => SessionService());
  getIt.registerLazySingleton<NotificationService>(() => NotificationService());
  getIt.registerLazySingleton<PreferencesService>(() => PreferencesService());

  //=== Features ===//
  await _initAuthFeature();
  await _initPropertyFeature();

  print('DependencyInjection: ✅ Dependencies initialized');
}

/// Initialise les dépendances de la fonctionnalité d'authentification
Future<void> _initAuthFeature() async {
  print(' DependencyInjection: 🔄 Initializing auth feature');

  // Data Sources
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      client: getIt<GraphQLClient>(),
      secureStorage: getIt<SecureStorageService>(),
    ),
  );

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
        sessionService: getIt<SessionService>(),
      ));

  getIt.registerFactory<SignUpBloc>(() => SignUpBloc(
        getIt<SignUpUseCase>(),
      ));

  print(
      '[2025-03-02 17:01:24] DependencyInjection: ✅ Auth feature initialized');
}

/// Initialise les dépendances de la fonctionnalité de gestion des propriétés
Future<void> _initPropertyFeature() async {
  print(
      '[2025-03-02 17:01:24] DependencyInjection: 🔄 Initializing property feature');

  try {
    // Repositories avec implémentation simplifiée (sans dépendances)
    if (!getIt.isRegistered<PropertyRepository>()) {
      getIt.registerLazySingleton<PropertyRepository>(
        () => PropertyRepositoryImpl(),
      );
      print(
          '[2025-03-02 17:01:24] DependencyInjection: ✅ PropertyRepository registered');
    }

    // Use Cases
    if (!getIt.isRegistered<GetPropertiesUseCase>()) {
      getIt.registerLazySingleton<GetPropertiesUseCase>(
          () => GetPropertiesUseCase(
                getIt<PropertyRepository>(),
              ));
      print(
          '[2025-03-02 17:01:24] DependencyInjection: ✅ GetPropertiesUseCase registered');
    }
    // BLoCs
    getIt.registerFactory<PropertyBloc>(() => PropertyBloc(
          getPropertiesUseCase: getIt<GetPropertiesUseCase>(),
        ));
    print('DependencyInjection: ✅ PropertyBloc registered');

    print('DependencyInjection: ✅ Property feature initialized');
  } catch (e) {
    print('DependencyInjection: ❌ Error initializing property feature'
        '\n└─ Error: $e');
  }
}