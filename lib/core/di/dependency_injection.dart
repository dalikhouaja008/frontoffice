import 'package:get_it/get_it.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:the_boost/core/network/graphql_client.dart';
import 'package:the_boost/core/network/network_info.dart';
import 'package:the_boost/core/services/land_service.dart';
import 'package:the_boost/core/services/notification_service.dart';
import 'package:the_boost/core/services/preferences_service.dart';
import 'package:the_boost/core/services/prop_service.dart';
import 'package:the_boost/core/services/secure_storage_service.dart';
import 'package:the_boost/core/services/session_service.dart';
import 'package:the_boost/core/services/token_minting_service.dart';
import 'package:the_boost/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:the_boost/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:the_boost/features/auth/data/repositories/property_repository_impl.dart';
import 'package:the_boost/features/auth/data/repositories/two_factor_auth_repository.dart';
import 'package:the_boost/features/auth/domain/repositories/auth_repository.dart';
import 'package:the_boost/features/auth/domain/repositories/property_repository.dart';
import 'package:the_boost/features/auth/domain/use_cases/investments/get_enhanced_tokens_usecase.dart';
import 'package:the_boost/features/auth/domain/use_cases/investments/get_properties_usecase.dart';
import 'package:the_boost/features/auth/domain/use_cases/login_use_case.dart';
import 'package:the_boost/features/auth/domain/use_cases/sign_up_use_case.dart';
import 'package:the_boost/features/auth/presentation/bloc/2FA/two_factor_auth_bloc.dart';
import 'package:the_boost/features/auth/presentation/bloc/investment/investment_bloc.dart';
import 'package:the_boost/features/auth/presentation/bloc/lands/land_bloc.dart';
import 'package:the_boost/features/auth/presentation/bloc/login/login_bloc.dart';
import 'package:the_boost/features/auth/presentation/bloc/property/property_bloc.dart';
import 'package:the_boost/features/auth/presentation/bloc/signup/sign_up_bloc.dart';
import '../services/gemini_service.dart';
import '../../features/chatbot/presentation/controllers/chat_controller.dart';
import '../../features/auth/data/datasources/preferences_remote_data_source.dart';
import '../../features/auth/data/repositories/preferences_repository.dart';
import '../../features/auth/data/repositories/preferences_repository_impl.dart';
import '../../features/auth/domain/use_cases/preferences/get_land_types_usecase.dart';
import '../../features/auth/domain/use_cases/preferences/get_preferences_usecase.dart';
import '../../features/auth/domain/use_cases/preferences/save_preferences_usecase.dart';
import '../../features/auth/presentation/bloc/preferences/preferences_bloc.dart';

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

  // Network
  getIt.registerLazySingleton(() => InternetConnectionChecker.createInstance());
  getIt.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(getIt<InternetConnectionChecker>()),
  );

  // Register LandService as singleton
  getIt.registerLazySingleton<LandService>(() => LandService());
  getIt.registerLazySingleton<ApiService>(() => ApiService());

  // Register NotificationService (removed storageService parameter)
  getIt.registerLazySingleton<NotificationService>(
    () => NotificationService(
      landService: getIt<LandService>(),
    ),
  );

  getIt.registerLazySingleton<PreferencesService>(() => PreferencesService());

  // Register TokenMintingService
  getIt.registerLazySingleton(() => TokenMintingService());

  await _initAuthFeature();
  await _initPropertyFeature();
  await _initPreferencesFeature();
  await _initInvestmentFeature();

  print('DependencyInjection: ✅ Dependencies initialized');
}

Future<void> _initInvestmentFeature() async {
  print(
      '[${DateTime.now()}] DependencyInjection: 🔄 Initializing investment feature');

  try {
    // Use Cases
    getIt.registerLazySingleton<GetEnhancedTokensUseCase>(
      () => GetEnhancedTokensUseCase(),
    );

    // BLoCs
    getIt.registerFactory<InvestmentBloc>(
      () => InvestmentBloc(
        getEnhancedTokensUseCase: getIt<GetEnhancedTokensUseCase>(),
      ),
    );

    print(
        '[${DateTime.now()}] DependencyInjection: ✅ Investment feature initialized');
  } catch (e) {
    print(
        '[${DateTime.now()}] DependencyInjection: ❌ Error initializing investment feature'
        '\n└─ Error: $e');
  }
}

Future<void> registerChatbotDependencies() async {
  // Register Gemini service with API key
  const geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue:
        'AIzaSyAvEtQjkAjwld1rTx4EtPXJ97iM1_5CqT8', // Replace with your actual API key when not using --dart-define
  );

  getIt.registerLazySingleton<GeminiService>(
    () => GeminiService(
      apiKey: geminiApiKey,
      modelName: 'gemini-1.5-pro',
    ),
  );

  // Register chat controller
  getIt.registerLazySingleton<ChatController>(
    () => ChatController(geminiService: getIt<GeminiService>()),
  );
}

Future<void> _initPreferencesFeature() async {
  print(
      '[${DateTime.now()}] DependencyInjection: 🔄 Initializing preferences feature');

  try {
    // Data Sources
    getIt.registerLazySingleton<PreferencesRemoteDataSource>(
      () => PreferencesRemoteDataSourceImpl(
        secureStorage: getIt<SecureStorageService>(),
      ),
    );
    print(
        '[${DateTime.now()}] DependencyInjection: ✅ PreferencesRemoteDataSource registered');

    // Repositories
    getIt.registerLazySingleton<PreferencesRepository>(
      () => PreferencesRepositoryImpl(
        getIt<PreferencesRemoteDataSource>(),
      ),
    );
    print(
        '[${DateTime.now()}] DependencyInjection: ✅ PreferencesRepository registered');

    // Use Cases
    getIt.registerLazySingleton<GetPreferencesUseCase>(
      () => GetPreferencesUseCase(
        getIt<PreferencesRepository>(),
      ),
    );
    print(
        '[${DateTime.now()}] DependencyInjection: ✅ GetPreferencesUseCase registered');

    getIt.registerLazySingleton<SavePreferencesUseCase>(
      () => SavePreferencesUseCase(
        getIt<PreferencesRepository>(),
      ),
    );
    print(
        '[${DateTime.now()}] DependencyInjection: ✅ SavePreferencesUseCase registered');

    getIt.registerLazySingleton<GetLandTypesUseCase>(
      () => GetLandTypesUseCase(
        getIt<PreferencesRepository>(),
      ),
    );
    print(
        '[${DateTime.now()}] DependencyInjection: ✅ GetLandTypesUseCase registered');

    // BLoCs
    getIt.registerFactory<PreferencesBloc>(
      () => PreferencesBloc(
        getPreferencesUseCase: getIt<GetPreferencesUseCase>(),
        savePreferencesUseCase: getIt<SavePreferencesUseCase>(),
        getLandTypesUseCase: getIt<GetLandTypesUseCase>(),
      ),
    );
    print(
        '[${DateTime.now()}] DependencyInjection: ✅ PreferencesBloc registered');

    print(
        '[${DateTime.now()}] DependencyInjection: ✅ Preferences feature initialized');
  } catch (e) {
    print(
        '[${DateTime.now()}] DependencyInjection: ❌ Error initializing preferences feature'
        '\n└─ Error: $e');
  }
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
      '[${DateTime.now()}] DependencyInjection: 🔄 Initializing property feature');

  try {
    // Repositories
    if (!getIt.isRegistered<PropertyRepository>()) {
      getIt.registerLazySingleton<PropertyRepository>(
        () => PropertyRepositoryImpl(),
      );
    }

    // Use Cases
    if (!getIt.isRegistered<GetPropertiesUseCase>()) {
      getIt.registerLazySingleton<GetPropertiesUseCase>(
        () => GetPropertiesUseCase(getIt<PropertyRepository>()),
      );
    }

    // Register LandService as singleton if not already registered
    if (!getIt.isRegistered<LandService>()) {
      getIt.registerLazySingleton<LandService>(() => LandService());
    }
    // Register LandBloc
    getIt.registerFactory<LandBloc>(
      () => LandBloc(),
    );

    // Register PropertyBloc
    getIt.registerFactory<PropertyBloc>(
      () => PropertyBloc(
        getPropertiesUseCase: getIt<GetPropertiesUseCase>(),
      ),
    );

    print(
        '[${DateTime.now()}] DependencyInjection: ✅ Property feature initialized');
  } catch (e) {
    print(
        '[${DateTime.now()}] DependencyInjection: ❌ Error initializing property feature: $e');
  }
}
