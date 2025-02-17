import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../../../core/error/failures.dart';
import '../entities/land.dart';

abstract class LandRepository {
  Future<Land> addLandWithFiles({
    required String name,
    required String location,
    required int size,
    required List<MultipartFile> photos,
    required List<MultipartFile> documents,
  });

  Future<Either<Failure, List<Land>>> getAllLands();
}
