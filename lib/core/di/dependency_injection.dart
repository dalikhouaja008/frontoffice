import 'package:get_it/get_it.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:the_boost/core/network/auth_interceptor.dart';
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
import 'package:the_boost/features/auth/data/datasources/investment_remote_data_source.dart';
import 'package:the_boost/features/auth/data/datasources/marketplace_remote_data_source.dart';
import 'package:the_boost/features/auth/data/repositories/Investment_repository_impl.dart';
import 'package:the_boost/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:the_boost/features/auth/data/repositories/marketplace_repository_impl.dart';
import 'package:the_boost/features/auth/data/repositories/property_repository_impl.dart';
import 'package:the_boost/features/auth/data/repositories/two_factor_auth_repository.dart';
import 'package:the_boost/features/auth/domain/repositories/auth_repository.dart';
import 'package:the_boost/features/auth/domain/repositories/investment_repository.dart';
import 'package:the_boost/features/auth/domain/repositories/marketplace_repository.dart';
import 'package:the_boost/features/auth/domain/repositories/property_repository.dart';
import 'package:the_boost/features/auth/domain/use_cases/investments/get_enhanced_tokens_usecase.dart';
import 'package:the_boost/features/auth/domain/use_cases/investments/get_properties_usecase.dart';
import 'package:the_boost/features/auth/domain/use_cases/login_use_case.dart';
import 'package:the_boost/features/auth/domain/use_cases/marketplace/cancel_listing_usecase.dart';
import 'package:the_boost/features/auth/domain/use_cases/marketplace/list_multiple_tokens_usecase.dart';
import 'package:the_boost/features/auth/domain/use_cases/marketplace/list_token_usecase.dart';
import 'package:the_boost/features/auth/domain/use_cases/sign_up_use_case.dart';
import 'package:the_boost/features/auth/presentation/bloc/2FA/two_factor_auth_bloc.dart';
import 'package:the_boost/features/auth/presentation/bloc/investment/investment_bloc.dart';
import 'package:the_boost/features/auth/presentation/bloc/lands/land_bloc.dart';
import 'package:the_boost/features/auth/presentation/bloc/login/login_bloc.dart';
import 'package:the_boost/features/auth/presentation/bloc/marketplace/marketplace_bloc.dart';
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
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';

// Marketplace imports
import '../../features/marketplace/data/datasources/marketplace_remote_datasource.dart';
import '../../features/marketplace/data/datasources/marketplace_local_datasource.dart';
import '../../features/marketplace/data/repositories/marketplace_repository_impl.dart';
import '../../features/marketplace/domain/repositories/marketplace_repository.dart';
import '../../features/marketplace/domain/usecases/get_all_listings.dart';
import '../../features/marketplace/domain/usecases/get_filtered_listings.dart';
import '../../features/marketplace/domain/usecases/get_listing_details.dart';
import '../../features/marketplace/domain/usecases/purchase_token.dart';
import '../../features/marketplace/presentation/bloc/marketplace_bloc.dart';

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

  // Register HTTP Client
  getIt.registerLazySingleton<http.Client>(() => http.Client());

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

  await _initMarketplaceFeature();
  await _initListingFeature();

  print(
      '[2025-05-05 03:35:15] DependencyInjection: ✅ Dependencies initialized');
}

// New marketplace feature initialization
Future<void> _initMarketplaceFeature() async {
  print(
      '[2025-05-05 03:35:15] DependencyInjection: 🔄 Initializing marketplace feature');

  try {
    // Register SharedPreferences instance
    final sharedPreferences = await SharedPreferences.getInstance();
    if (!getIt.isRegistered<SharedPreferences>()) {
      getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
    }
    // Data Sources
    getIt.registerLazySingleton<MarketplaceRemoteDataSource>(
      () => MarketplaceRemoteDataSourceImpl(
        client: getIt<http.Client>(),
        baseUrl: 'http://localhost:5000', // Use your actual API URL
        secureStorage: getIt<SecureStorageService>(), // Added this
      ),
    );
    // Register auth interceptor
    getIt.registerLazySingleton<AuthInterceptor>(
      () => AuthInterceptor(
        secureStorage: getIt<SecureStorageService>(),
        baseUrl: 'http://localhost:5000', // Use your actual API URL
      ),
    );

    getIt.registerLazySingleton<MarketplaceLocalDataSource>(
      () => MarketplaceLocalDataSourceImpl(
        sharedPreferences: getIt<SharedPreferences>(),
      ),
    );

    // Repository
    getIt.registerLazySingleton<MarketplaceRepository>(
      () => MarketplaceRepositoryImpl(
        remoteDataSource: getIt<MarketplaceRemoteDataSource>(),
        localDataSource: getIt<MarketplaceLocalDataSource>(),
        networkInfo: getIt<NetworkInfo>(),
      ),
    );

    // Use Cases
    getIt.registerLazySingleton<GetAllListings>(
      () => GetAllListings(getIt<MarketplaceRepository>()),
    );

    getIt.registerLazySingleton<GetFilteredListings>(
      () => GetFilteredListings(getIt<MarketplaceRepository>()),
    );

    getIt.registerLazySingleton<GetListingDetails>(
      () => GetListingDetails(getIt<MarketplaceRepository>()),
    );

    getIt.registerLazySingleton<PurchaseToken>(
      () => PurchaseToken(getIt<MarketplaceRepository>()),
    );

    // Bloc
    getIt.registerFactory<MarketplaceBloc>(
      () => MarketplaceBloc(
        getAllListings: getIt<GetAllListings>(),
        getFilteredListings: getIt<GetFilteredListings>(),
        getListingDetails: getIt<GetListingDetails>(),
        purchaseToken: getIt<PurchaseToken>(),
      ),
    );

    print(
        '[2025-05-05 03:35:15] DependencyInjection: ✅ Marketplace feature initialized');
  } catch (e) {
    print(
        '[2025-05-05 03:35:15] DependencyInjection: ❌ Error initializing marketplace feature'
        '\n└─ Error: $e');
  }
}

Future<void> _initInvestmentFeature() async {
  print(
      '[${DateTime.now()}] DependencyInjection: 🔄 Initializing investment feature');

  try {
    // Data Sources
    getIt.registerLazySingleton<InvestmentRemoteDataSource>(
      () => InvestmentRemoteDataSourceImpl(
        client: getIt<http.Client>(),
        secureStorage: getIt<SecureStorageService>(),
        baseUrl: 'http://localhost:5000/marketplace',
      ),
    );

    // Repositories
    getIt.registerLazySingleton<InvestmentRepository>(
      () => InvestmentRepositoryImpl(
        remoteDataSource: getIt<InvestmentRemoteDataSource>(),
        networkInfo: getIt<NetworkInfo>(),
      ),
    );

    // Use Cases
    getIt.registerLazySingleton<GetEnhancedTokensUseCase>(
      () => GetEnhancedTokensUseCase(getIt<InvestmentRepository>()),
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

Future<void> _initListingFeature() async {
  print(
      '[2025-05-04 20:29:04] DependencyInjection: 🔄 Initializing marketplace feature');

  try {
    // Data Sources
    getIt.registerLazySingleton<MarketplaceRemoteDataSource>(
      () => MarketplaceRemoteDataSourceImpl(
        client: getIt<http.Client>(),
        secureStorage: getIt<SecureStorageService>(),
        baseUrl: 'http://localhost:5000',
      ),
    );

    // Repositories
    getIt.registerLazySingleton<MarketplaceRepository>(
      () => MarketplaceRepositoryImpl(
        remoteDataSource: getIt<MarketplaceRemoteDataSource>(),
        networkInfo: getIt<NetworkInfo>(),
      ),
    );

    // Use Cases
    getIt.registerLazySingleton<ListTokenUseCase>(
      () => ListTokenUseCase(getIt<MarketplaceRepository>()),
    );

    getIt.registerLazySingleton<ListMultipleTokensUseCase>(
      () => ListMultipleTokensUseCase(getIt<MarketplaceRepository>()),
    );

    getIt.registerLazySingleton<CancelListingUseCase>(
      () => CancelListingUseCase(getIt<MarketplaceRepository>()),
    );

    // BLoCs
    getIt.registerFactory<MarketplaceBloc>(
      () => MarketplaceBloc(
        listTokenUseCase: getIt<ListTokenUseCase>(),
        listMultipleTokensUseCase: getIt<ListMultipleTokensUseCase>(),
        cancelListingUseCase: getIt<CancelListingUseCase>(),
      ),
    );

    print(
        '[2025-05-04 20:29:04] DependencyInjection: ✅ Marketplace feature initialized');
  } catch (e) {
    print(
        '[2025-05-04 20:29:04] DependencyInjection: ❌ Error initializing marketplace feature'
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
  print(
      '[2025-05-05 03:35:15] DependencyInjection: 🔄 Initializing auth feature');

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
      '[2025-05-05 03:35:15] DependencyInjection: ✅ Auth feature initialized');
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
