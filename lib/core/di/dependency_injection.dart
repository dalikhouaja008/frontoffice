import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:the_boost/core/constants/url.dart';
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
import 'package:the_boost/features/auth/data/repositories/Investment_repository_impl.dart';
import 'package:the_boost/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:the_boost/features/auth/data/repositories/property_repository_impl.dart';
import 'package:the_boost/features/auth/data/repositories/two_factor_auth_repository.dart';
import 'package:the_boost/features/auth/domain/repositories/auth_repository.dart';
import 'package:the_boost/features/auth/domain/repositories/investment_repository.dart';
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
import 'package:the_boost/features/land_registration/data/datasources/land_remote_data_source.dart';
import 'package:the_boost/features/land_registration/data/repositories/land_repository_impl.dart';
import 'package:the_boost/features/land_registration/domain/repositories/land_repository.dart';
import '../../features/geolocator_service.dart';
import '../../features/land_registration/data/datasources/valuation_remote_data_source.dart';
import '../../features/land_registration/data/repositories/valuation_repository_impl.dart';
import '../../features/land_registration/domain/repositories/valuation_repository.dart';
import '../../features/land_registration/domain/usecases/evaluate_land.dart';
import '../../features/land_registration/domain/usecases/get_eth_price.dart';
import '../../features/land_registration/domain/usecases/register_land.dart';
import '../../features/land_registration/presentation/bloc/register_land_bloc.dart';
import '../../features/land_registration/presentation/utils/form_validators.dart';
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
import '../network/auth_interceptor.dart';

import 'package:shared_preferences/shared_preferences.dart';

// Import with alias for the first MarketplaceRemoteDataSource
import 'package:the_boost/features/auth/data/datasources/marketplace_remote_data_source.dart'
    as auth;
import 'package:the_boost/features/auth/data/repositories/marketplace_repository_impl.dart'
    as auth;
import 'package:the_boost/features/auth/domain/repositories/marketplace_repository.dart'
    as auth;
import 'package:the_boost/features/auth/domain/use_cases/marketplace/cancel_listing_usecase.dart';
import 'package:the_boost/features/auth/domain/use_cases/marketplace/list_multiple_tokens_usecase.dart';
import 'package:the_boost/features/auth/domain/use_cases/marketplace/list_token_usecase.dart';
import 'package:the_boost/features/auth/presentation/bloc/marketplace/marketplace_bloc.dart'
    as auth_bloc;

// Import with alias for the second MarketplaceRemoteDataSource
import '../../features/marketplace/data/datasources/marketplace_remote_datasource.dart'
    as feature;
import '../../features/marketplace/data/datasources/marketplace_local_datasource.dart';
import '../../features/marketplace/data/repositories/marketplace_repository_impl.dart'
    as feature;
import '../../features/marketplace/domain/repositories/marketplace_repository.dart'
    as feature;
import '../../features/marketplace/domain/usecases/get_all_listings.dart';
import '../../features/marketplace/domain/usecases/get_filtered_listings.dart';
import '../../features/marketplace/domain/usecases/get_listing_details.dart';
import '../../features/marketplace/domain/usecases/purchase_token.dart';
import '../../features/marketplace/presentation/bloc/marketplace_bloc.dart' as feature_bloc;
import '../utils/file_helpers.dart';
import '../../features/marketplace/presentation/bloc/marketplace_bloc.dart'
    as feature_bloc;

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
    () => NetworkInfoImpl(
      getIt<Connectivity>(),
      getIt<InternetConnectionChecker>(),
    ),
  );
  getIt.registerLazySingleton<EvaluateLand>(() => EvaluateLand(getIt()));
  getIt.registerLazySingleton<GetEthPrice>(() => GetEthPrice(getIt()));
  getIt.registerLazySingleton<RegisterLand>(() => RegisterLand(getIt()));

  // Register Utility Classes
  getIt.registerLazySingleton<GeolocatorService>(() => GeolocatorService());
  getIt.registerLazySingleton<FileHelpers>(() => FileHelpers());
  getIt.registerLazySingleton<FormValidators>(() => FormValidators());

  // Register Bloc
  getIt.registerFactory<RegisterLandBloc>(() => RegisterLandBloc(
        evaluateLand: getIt<EvaluateLand>(),
        getEthPrice: getIt<GetEthPrice>(),
        registerLand: getIt<RegisterLand>(),
        geolocatorService: getIt<GeolocatorService>(),
        fileHelpers: getIt<FileHelpers>(),
        formValidators: getIt<FormValidators>(),
      ));

  // Register LandService as singleton
  getIt.registerLazySingleton<LandService>(() => LandService());
  getIt.registerLazySingleton<ApiService>(() => ApiService());
    getIt.registerLazySingleton<Connectivity>(() => Connectivity());


  // Register Remote Data Source
  getIt.registerLazySingleton<ValuationRemoteDataSource>(
    () => ValuationRemoteDataSourceImpl(
      client: getIt<http.Client>(),
      customBaseUrl: null, // Provide a custom base URL if needed
      customEthPriceApiUrl: null, // Provide a custom ETH price API URL if needed
    ),
  );

getIt.registerLazySingleton<ValuationRepository>(
  () => ValuationRepositoryImpl(
    remoteDataSource: getIt<ValuationRemoteDataSource>(),
    networkInfo: getIt<NetworkInfo>(),
  ),
);


 getIt.registerLazySingleton<LandRemoteDataSource>(
  () => LandRemoteDataSourceImpl(
    client: getIt<http.Client>(),
    sessionService: getIt<SessionService>(),
    customBaseUrl: 'http://localhost:5000', // Replace with your API base URL
  ),
);

  // Register Land Repository
 getIt.registerLazySingleton<LandRepository>(
  () => LandRepositoryImpl(
    remoteDataSource: getIt<LandRemoteDataSource>(),
    networkInfo: getIt<NetworkInfo>(),
  ),
);


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

Future<void> _initMarketplaceFeature() async {
  print(
      '[${DateTime.now()}] DependencyInjection: 🔄 Initializing marketplace feature');

  try {
    // Register SharedPreferences instance
    final sharedPreferences = await SharedPreferences.getInstance();
    if (!getIt.isRegistered<SharedPreferences>()) {
      getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
    }

    // Ensure URLs are available
    const landServiceBaseUrl = Url.landServiceBaseUrl;
    
    // AJOUT: D'abord vérifier si AuthInterceptor est déjà enregistré, sinon l'enregistrer
    if (!getIt.isRegistered<AuthInterceptor>()) {
      getIt.registerLazySingleton<AuthInterceptor>(
        () => AuthInterceptor(
          secureStorage: getIt<SecureStorageService>(),
          baseUrl: landServiceBaseUrl,
        ),
      );
      print('[${DateTime.now()}] DependencyInjection: ✅ AuthInterceptor registered');
    }

    // Data Sources
    getIt.registerLazySingleton<feature.MarketplaceRemoteDataSource>(
      () => feature.MarketplaceRemoteDataSourceImpl(
        client: getIt<http.Client>(),
        baseUrl: landServiceBaseUrl,
        secureStorage: getIt<SecureStorageService>(),
        authInterceptor: getIt<AuthInterceptor>(),  // Maintenant on peut l'utiliser
      ),
    );

    getIt.registerLazySingleton<MarketplaceLocalDataSource>(
      () => MarketplaceLocalDataSourceImpl(
        sharedPreferences: getIt<SharedPreferences>(),
      ),
    );

    // Repository
    getIt.registerLazySingleton<feature.MarketplaceRepository>(
      () => feature.MarketplaceRepositoryImpl(
        remoteDataSource: getIt<feature.MarketplaceRemoteDataSource>(),
        localDataSource: getIt<MarketplaceLocalDataSource>(),
        networkInfo: getIt<NetworkInfo>(),
      ),
    );

    // Use Cases
    getIt.registerLazySingleton<GetAllListings>(
      () => GetAllListings(getIt<feature.MarketplaceRepository>()),
    );

    getIt.registerLazySingleton<GetFilteredListings>(
      () => GetFilteredListings(getIt<feature.MarketplaceRepository>()),
    );

    getIt.registerLazySingleton<GetListingDetails>(
      () => GetListingDetails(getIt<feature.MarketplaceRepository>()),
    );

    getIt.registerLazySingleton<PurchaseToken>(
      () => PurchaseToken(getIt<feature.MarketplaceRepository>()),
    );

    // Bloc
    getIt.registerFactory<feature_bloc.MarketplaceBloc>(
      () => feature_bloc.MarketplaceBloc(
        getAllListings: getIt<GetAllListings>(),
        getFilteredListings: getIt<GetFilteredListings>(),
        getListingDetails: getIt<GetListingDetails>(),
        purchaseToken: getIt<PurchaseToken>(),
      ),
    );

    print(
        '[${DateTime.now()}] DependencyInjection: ✅ Marketplace feature initialized');
  } catch (e) {
    print(
        '[${DateTime.now()}] DependencyInjection: ❌ Error initializing marketplace feature'
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
    getIt.registerLazySingleton<auth.MarketplaceRemoteDataSource>(
      () => auth.MarketplaceRemoteDataSourceImpl(
        client: getIt<http.Client>(),
        secureStorage: getIt<SecureStorageService>(),
        baseUrl: 'http://localhost:5000',
      ),
    );

    // Repositories
    getIt.registerLazySingleton<auth.MarketplaceRepository>(
      () => auth.MarketplaceRepositoryImpl(
        remoteDataSource: getIt<auth.MarketplaceRemoteDataSource>(),
        networkInfo: getIt<NetworkInfo>(),
      ),
    );

    // Use Cases
    getIt.registerLazySingleton<ListTokenUseCase>(
      () => ListTokenUseCase(getIt<auth.MarketplaceRepository>()),
    );

    getIt.registerLazySingleton<ListMultipleTokensUseCase>(
      () => ListMultipleTokensUseCase(getIt<auth.MarketplaceRepository>()),
    );

    getIt.registerLazySingleton<CancelListingUseCase>(
      () => CancelListingUseCase(getIt<auth.MarketplaceRepository>()),
    );

    // BLoCs
    getIt.registerFactory<auth_bloc.MarketplaceBloc>(
      () => auth_bloc.MarketplaceBloc(
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
