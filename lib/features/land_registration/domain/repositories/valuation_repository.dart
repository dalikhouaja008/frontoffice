import 'package:dartz/dartz.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../entities/valuation_result.dart';
import '../../../../core/error/failures.dart';

abstract class ValuationRepository {
  /// Estimates the value of a land based on its properties
  Future<Either<Failure, ValuationResult>> estimateLandValue({
    required LatLng position,
    required double area,
    required String zoning,
    required bool nearWater,
    required bool roadAccess,
    required bool utilities,
  });
  
  /// Gets the current ETH price in TND
  Future<Either<Failure, Map<String, dynamic>>> getEthPrice();
}