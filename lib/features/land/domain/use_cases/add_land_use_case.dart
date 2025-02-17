import 'package:dio/dio.dart';

import '../../domain/repositories/land_repository.dart';
import '../../domain/entities/land.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class AddLandUseCase {
  final LandRepository repository;

  AddLandUseCase(this.repository);

  Future<Land> call({
    required String name,
    required String location,
    required int size,
    required List<MultipartFile> photos,
    required List<MultipartFile> documents,
  }) async {
    return await repository.addLandWithFiles(
      name: name,
      location: location,
      size: size,
      photos: photos,
      documents: documents,
    );
  }
}
