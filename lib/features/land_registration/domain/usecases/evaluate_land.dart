import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:the_boost/features/land_registration/domain/usecases/usecase.dart';
import '../entities/valuation_result.dart';
import '../repositories/valuation_repository.dart';
import '../../../../core/error/failures.dart';

class EvaluateLand implements UseCase<ValuationResult, EvaluateLandParams> {
  final ValuationRepository repository;

  EvaluateLand(this.repository);

  @override
  Future<Either<Failure, ValuationResult>> call(EvaluateLandParams params) {
    return repository.estimateLandValue(
      position: params.position,
      area: params.area,
      zoning: params.zoning,
      nearWater: params.nearWater,
      roadAccess: params.roadAccess,
      utilities: params.utilities,
    );
  }
}

class EvaluateLandParams extends Equatable {
  final LatLng position;
  final double area;
  final String zoning;
  final bool nearWater;
  final bool roadAccess;
  final bool utilities;

  const EvaluateLandParams({
    required this.position,
    required this.area,
    required this.zoning,
    required this.nearWater,
    required this.roadAccess,
    required this.utilities,
  });

  @override
  List<Object?> get props => [
        position,
        area,
        zoning,
        nearWater,
        roadAccess,
        utilities,
      ];
}