// lib/features/land_registration/di/injection_container.dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import '../data/datasources/land_remote_data_source.dart';
import '../data/datasources/valuation_remote_data_source.dart';
import '../data/repositories/land_repository_impl.dart';
import '../data/repositories/valuation_repository_impl.dart';
import '../domain/repositories/land_repository.dart';
import '../domain/repositories/valuation_repository.dart';
import '../domain/usecases/evaluate_land.dart';
import '../domain/usecases/get_eth_price.dart';
import '../domain/usecases/register_land.dart';
import '../presentation/bloc/register_land_bloc.dart';
import '../../geolocator_service.dart';
import '../../../core/network/network_info.dart';
import '../../../core/services/session_service.dart';
import '../../../core/utils/file_helpers.dart';
import '../presentation/utils/form_validators.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Land Registration
  // Bloc
  sl.registerFactory(
    () => RegisterLandBloc(
      evaluateLand: sl(),
      getEthPrice: sl(),
      registerLand: sl(),
      geolocatorService: sl(),
      fileHelpers: sl(),
      formValidators: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => EvaluateLand(sl()));
  sl.registerLazySingleton(() => GetEthPrice(sl()));
  sl.registerLazySingleton(() => RegisterLand(sl()));

  // Repository
  sl.registerLazySingleton<LandRepository>(
    () => LandRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton<ValuationRepository>(
    () => ValuationRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<LandRemoteDataSource>(
    () => LandRemoteDataSourceImpl(
      client: sl(),
      sessionService: sl(),
      customBaseUrl: null, // Set your backend URL here if needed
    ),
  );
  sl.registerLazySingleton<ValuationRemoteDataSource>(
    () => ValuationRemoteDataSourceImpl(
      client: sl(),
      customBaseUrl: null, // Set your valuation API URL here if needed
      customEthPriceApiUrl: null, // Set your ETH price API URL here if needed
    ),
  );

  //! Core
   sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(
      sl<Connectivity>(),
      sl<InternetConnectionChecker>(),
    ),
  );
  sl.registerLazySingleton(() => SessionService());
  sl.registerLazySingleton(() => GeolocatorService());
  sl.registerLazySingleton(() => FileHelpers());
  sl.registerLazySingleton(() => FormValidators());

  //! External
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => Connectivity());
}