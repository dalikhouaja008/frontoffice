import 'package:dartz/dartz.dart';
import '../entities/land.dart';
import '../entities/document.dart';
import '../../../../core/error/failures.dart';

abstract class LandRepository {
  /// Registers a new land property for tokenization
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
  });
  
  /// Gets the details of a registered land by ID
  Future<Either<Failure, Land>> getLandById(String id);
  
  /// Gets all lands registered by the current user
  Future<Either<Failure, List<Land>>> getUserLands();
}