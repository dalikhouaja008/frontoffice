import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/land.dart';
import '../../domain/repositories/land_repository.dart';
import '../datasources/land_remote_data_source.dart';

class LandRepositoryImpl implements LandRepository {
  final LandRemoteDataSource remoteDataSource;

  LandRepositoryImpl(this.remoteDataSource);

 @override
Future<Land> addLandWithFiles({
  required String name,
  required String location,
  required int size,
  required List<MultipartFile> photos,
  required List<MultipartFile> documents,
}) async {
  final land = await remoteDataSource.addLandWithFiles(
    name: name,
    location: location,
    size: size,
    photos: photos,
    documents: documents,
  );
  return land;  // Return the created Land object
}

  @override
  Future<Either<Failure, List<Land>>> getAllLands() async {
    try {
      final result = await remoteDataSource.getAllLands();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
