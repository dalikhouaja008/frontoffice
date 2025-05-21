import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:the_boost/core/error/exceptions.dart';
import 'package:the_boost/core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/land.dart';
import '../../domain/entities/document.dart';
import '../../domain/repositories/land_repository.dart';
import '../datasources/land_remote_data_source.dart';
import '../models/land_model.dart';
import '../models/document_model.dart';


class LandRepositoryImpl implements LandRepository {
  final LandRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  LandRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, String>> registerLand({
    required String title,
    String? description,
    required String location,
    required int surface,
    required int totalTokens,
    required double pricePerToken,
    required String status,
    required String landType,
    required List<LandDocument> documents,
    required List<LandDocument> images,
    required Map<String, bool> amenities,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(ConnectionFailure(message: 'No internet connection'));
    }

    try {
      // Convert documents and images to LandDocumentModel
      final documentModels = documents
          .map((doc) => doc as LandDocumentModel)
          .toList();
      
      final imageModels = images
          .map((img) => img as LandDocumentModel)
          .toList();

      final result = await remoteDataSource.registerLand(
        title: title,
        description: description,
        location: location,
        surface: surface,
        totalTokens: totalTokens,
        pricePerToken: pricePerToken.toString(),
        status: status,
        landType: landType,
        documents: documentModels,
        images: imageModels,
        amenities: amenities,
      );

      return Right(result['landId'] ?? 'Unknown');
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } on TimeoutException catch (e) {
      return Left(ServerFailure(message: 'Operation timed out: ${e.message}'));
    } on CorsException catch (e) {
      return Left(CorsFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Land>> getLandById(String id) async {
    if (!await networkInfo.isConnected) {
      return Left(ConnectionFailure(message: 'No internet connection'));
    }

    try {
      final result = await remoteDataSource.getLandById(id);
      final land = LandModel.fromJson(result);
      return Right(land);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Land>>> getUserLands() async {
    if (!await networkInfo.isConnected) {
      return Left(ConnectionFailure(message: 'No internet connection'));
    }

    try {
      final result = await remoteDataSource.getUserLands();
      final lands = result.map((landJson) => LandModel.fromJson(landJson)).toList();
      return Right(lands);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}