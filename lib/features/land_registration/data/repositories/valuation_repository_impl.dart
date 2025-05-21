import 'package:dartz/dartz.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:the_boost/core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/valuation_result.dart';
import '../../domain/repositories/valuation_repository.dart';
import '../datasources/valuation_remote_data_source.dart';
import '../models/valuation_result_model.dart';


class ValuationRepositoryImpl implements ValuationRepository {
  final ValuationRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ValuationRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, ValuationResult>> estimateLandValue({
    required LatLng position,
    required double area,
    required String zoning,
    required bool nearWater,
    required bool roadAccess,
    required bool utilities,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(ConnectionFailure(message: 'No internet connection'));
    }

    try {
      final result = await remoteDataSource.estimateLandValue(
        position: position,
        area: area,
        zoning: zoning,
        nearWater: nearWater,
        roadAccess: roadAccess,
        utilities: utilities,
      );

      final valuationResult = ValuationResultModel.fromJson(result);
      return Right(valuationResult);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getEthPrice() async {
    if (!await networkInfo.isConnected) {
      return Left(ConnectionFailure(message: 'No internet connection'));
    }

    try {
      final result = await remoteDataSource.getEthPrice();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}