// lib/core/di/dependency_injection.dart
import 'package:get_it/get_it.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:the_boost/core/network/graphql_client.dart';
import 'package:the_boost/core/services/land_service.dart';
import 'package:the_boost/core/services/notification_service.dart';
import 'package:the_boost/core/services/preferences_service.dart';
import 'package:the_boost/core/services/secure_storage_service.dart';
import 'package:the_boost/core/services/session_service.dart';
import 'package:http/http.dart' as http;
import 'package:the_boost/features/auth/data/repositories/land_repository_impl.dart';
import 'package:the_boost/features/auth/data/repositories/preferences_repository.dart';
import 'package:the_boost/features/auth/domain/repositories/land_repository.dart';
import '../../features/chatbot/presentation/controllers/chat_controller.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/datasources/preferences_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/data/repositories/preferences_repository_impl.dart';
import '../../features/auth/data/repositories/property_repository_impl.dart';
import '../../features/auth/data/repositories/two_factor_auth_repository.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/repositories/property_repository.dart';
import '../../features/auth/domain/use_cases/investments/get_properties_usecase.dart';
import '../../features/auth/domain/use_cases/login_use_case.dart';
import '../../features/auth/domain/use_cases/preferences/get_land_types_usecase.dart';
import '../../features/auth/domain/use_cases/preferences/get_preferences_usecase.dart';
import '../../features/auth/domain/use_cases/preferences/save_preferences_usecase.dart';
import '../../features/auth/domain/use_cases/sign_up_use_case.dart';
import '../../features/auth/presentation/bloc/2FA/two_factor_auth_bloc.dart';
import '../../features/auth/presentation/bloc/login/login_bloc.dart';
import '../../features/auth/presentation/bloc/property/property_bloc.dart';
import '../../features/auth/presentation/bloc/preferences/preferences_bloc.dart';
import '../../features/auth/presentation/bloc/signup/sign_up_bloc.dart';
import '../services/gemini_service.dart';

final GetIt getIt = GetIt.instance;

/// Initialise toutes les dépendances de l'application
Future<void> initDependencies() async {
  print('DependencyInjection: 🚀 Initializing dependencies');

  //=== Core Services ===//
  _registerCoreServices(); // This must be called first.

  //=== Features ===//
  await _initAuthFeature();
  await _initPropertyFeature();
  await _initPreferencesFeature();

  print('DependencyInjection: ✅ Dependencies initialized');
}

void _registerCoreServices() {
  // Register HTTP client
  getIt.registerLazySingleton(() => http.Client());

  // Register SecureStorageService
  getIt.registerLazySingleton<SecureStorageService>(() => SecureStorageService());

  // Register GraphQLClient
  getIt.registerLazySingleton<GraphQLClient>(() => GraphQLService.client);

  // Register LandService
  getIt.registerLazySingleton<LandService>(() => LandService());

  // Register NotificationService
  getIt.registerLazySingleton<NotificationService>(
    () => NotificationService(
      landService: getIt<LandService>(),
      storageService: getIt<SecureStorageService>(),
    ),
  );

  // Register PreferencesService
  getIt.registerLazySingleton<PreferencesService>(
    () => PreferencesService(
      storageService: getIt<SecureStorageService>(),
      notificationService: getIt<NotificationService>(),
    ),
  );

  // Register LandRepository
  getIt.registerLazySingleton<LandRepository>(() => LandRepositoryImpl(getIt<LandService>()));

  // Register SessionService
  if (!getIt.isRegistered<SessionService>()) {
    getIt.registerLazySingleton<SessionService>(() => SessionService());
    print('DependencyInjection: ✅ SessionService registered');
  } else {
    print('DependencyInjection: ⚠️ SessionService already registered');
  }

  print('DependencyInjection: ✅ Core services registered');
}

/// Register Chatbot-related dependencies
Future<void> registerChatbotDependencies() async {
  print('[${DateTime.now()}] DependencyInjection: 🔄 Initializing chatbot feature');

  try {
    // Gemini API Key (use --dart-define or environment variable)
    final geminiApiKey = const String.fromEnvironment(
      'GEMINI_API_KEY',
      defaultValue: 'AIzaSyAvEtQjkAjwld1rTx4EtPXJ97iM1_5CqT8', // Replace with your actual API key
    );

    // Register Gemini Service
    getIt.registerLazySingleton<GeminiService>(
      () => GeminiService(apiKey: geminiApiKey, modelName: 'gemini-1.5-pro'),
    );
    print('[${DateTime.now()}] DependencyInjection: ✅ GeminiService registered');

    // Register Chat Controller
    getIt.registerLazySingleton<ChatController>(
      () => ChatController(geminiService: getIt<GeminiService>()),
    );
    print('[${DateTime.now()}] DependencyInjection: ✅ ChatController registered');

    print('[${DateTime.now()}] DependencyInjection: ✅ Chatbot feature initialized');
  } catch (e) {
    print('[${DateTime.now()}] DependencyInjection: ❌ Error initializing chatbot feature'
        '\n└─ Error: $e');
  }
}

/// Initialize Preferences Feature
Future<void> _initPreferencesFeature() async {
  print('[${DateTime.now()}] DependencyInjection: 🔄 Initializing preferences feature');

  try {
    // Data Sources
    getIt.registerLazySingleton<PreferencesRemoteDataSource>(
      () => PreferencesRemoteDataSourceImpl(secureStorage: getIt<SecureStorageService>()),
    );
    print('[${DateTime.now()}] DependencyInjection: ✅ PreferencesRemoteDataSource registered');

    // Repositories
    getIt.registerLazySingleton<PreferencesRepository>(
      () => PreferencesRepositoryImpl(getIt<PreferencesRemoteDataSource>()),
    );
    print('[${DateTime.now()}] DependencyInjection: ✅ PreferencesRepository registered');

    // Use Cases
    getIt.registerLazySingleton<GetPreferencesUseCase>(
      () => GetPreferencesUseCase(getIt<PreferencesRepository>()),
    );
    print('[${DateTime.now()}] DependencyInjection: ✅ GetPreferencesUseCase registered');

    getIt.registerLazySingleton<SavePreferencesUseCase>(
      () => SavePreferencesUseCase(getIt<PreferencesRepository>()),
    );
    print('[${DateTime.now()}] DependencyInjection: ✅ SavePreferencesUseCase registered');

    getIt.registerLazySingleton<GetLandTypesUseCase>(
      () => GetLandTypesUseCase(getIt<PreferencesRepository>()),
    );
    print('[${DateTime.now()}] DependencyInjection: ✅ GetLandTypesUseCase registered');

    // BLoCs
    getIt.registerFactory<PreferencesBloc>(
      () => PreferencesBloc(
        getPreferencesUseCase: getIt<GetPreferencesUseCase>(),
        savePreferencesUseCase: getIt<SavePreferencesUseCase>(),
        getLandTypesUseCase: getIt<GetLandTypesUseCase>(),
      ),
    );
    print('[${DateTime.now()}] DependencyInjection: ✅ PreferencesBloc registered');

    print('[${DateTime.now()}] DependencyInjection: ✅ Preferences feature initialized');
  } catch (e) {
    print('[${DateTime.now()}] DependencyInjection: ❌ Error initializing preferences feature'
        '\n└─ Error: $e');
  }
}

/// Initialize Auth Feature
Future<void> _initAuthFeature() async {
  print('[${DateTime.now()}] DependencyInjection: 🔄 Initializing auth feature');

  try {
    // Data Sources
    getIt.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(
        client: getIt<GraphQLClient>(),
        secureStorage: getIt<SecureStorageService>(),
      ),
    );
    print('[${DateTime.now()}] DependencyInjection: ✅ AuthRemoteDataSource registered');

    // Repositories
    getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(getIt<AuthRemoteDataSource>()),
    );
    print('[${DateTime.now()}] DependencyInjection: ✅ AuthRepository registered');

    getIt.registerLazySingleton<TwoFactorAuthRepository>(
      () => TwoFactorAuthRepositoryImpl(getIt<AuthRemoteDataSource>()),
    );
    print('[${DateTime.now()}] DependencyInjection: ✅ TwoFactorAuthRepository registered');

    // Use Cases
    getIt.registerLazySingleton<LoginUseCase>(
      () => LoginUseCase(repository: getIt<AuthRepository>()),
    );
    print('[${DateTime.now()}] DependencyInjection: ✅ LoginUseCase registered');

    getIt.registerLazySingleton<SignUpUseCase>(
      () => SignUpUseCase(getIt<AuthRepository>()),
    );
    print('[${DateTime.now()}] DependencyInjection: ✅ SignUpUseCase registered');

    // BLoCs
    getIt.registerFactory<LoginBloc>(
      () => LoginBloc(
        loginUseCase: getIt<LoginUseCase>(),
        secureStorage: getIt<SecureStorageService>(),
        sessionService: getIt<SessionService>(),
      ),
    );
    print('[${DateTime.now()}] DependencyInjection: ✅ LoginBloc registered');

    getIt.registerFactory<SignUpBloc>(
      () => SignUpBloc(getIt<SignUpUseCase>()),
    );
    print('[${DateTime.now()}] DependencyInjection: ✅ SignUpBloc registered');

    getIt.registerFactory<TwoFactorAuthBloc>(
      () => TwoFactorAuthBloc(repository: getIt<TwoFactorAuthRepository>()),
    );
    print('[${DateTime.now()}] DependencyInjection: ✅ TwoFactorAuthBloc registered');

    print('[${DateTime.now()}] DependencyInjection: ✅ Auth feature initialized');
  } catch (e) {
    print('[${DateTime.now()}] DependencyInjection: ❌ Error initializing auth feature'
        '\n└─ Error: $e');
  }
}

/// Initialize Property Feature
Future<void> _initPropertyFeature() async {
  print('[${DateTime.now()}] DependencyInjection: 🔄 Initializing property feature');

  try {
    // Repositories
    if (!getIt.isRegistered<PropertyRepository>()) {
      getIt.registerLazySingleton<PropertyRepository>(() => PropertyRepositoryImpl());
      print('[${DateTime.now()}] DependencyInjection: ✅ PropertyRepository registered');
    }

    // Use Cases
    if (!getIt.isRegistered<GetPropertiesUseCase>()) {
      getIt.registerLazySingleton<GetPropertiesUseCase>(
        () => GetPropertiesUseCase(getIt<PropertyRepository>()),
      );
      print('[${DateTime.now()}] DependencyInjection: ✅ GetPropertiesUseCase registered');
    }

    // BLoCs
    getIt.registerFactory<PropertyBloc>(
      () => PropertyBloc(getPropertiesUseCase: getIt<GetPropertiesUseCase>()),
    );
    print('[${DateTime.now()}] DependencyInjection: ✅ PropertyBloc registered');

    print('[${DateTime.now()}] DependencyInjection: ✅ Property feature initialized');
  } catch (e) {
    print('[${DateTime.now()}] DependencyInjection: ❌ Error initializing property feature'
        '\n└─ Error: $e');
  }
}