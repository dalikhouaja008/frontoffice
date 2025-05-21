import 'package:equatable/equatable.dart';
import 'location_info.dart';

class ValuationResult extends Equatable {
  final LocationInfo location;
  final ValuationInfo valuation;
  final List<ComparableProperty> comparables;

  const ValuationResult({
    required this.location,
    required this.valuation,
    required this.comparables,
  });

  @override
  List<Object?> get props => [location, valuation, comparables];
}

class ValuationInfo extends Equatable {
  final int estimatedValue;
  final double? estimatedValueETH;
  final double areaInSqFt;
  final double avgPricePerSqFt;
  final double avgPricePerSqFtETH;
  final String zoning;
  final List<ValuationFactor> valuationFactors;
  final double? currentEthPriceTND;

  const ValuationInfo({
    required this.estimatedValue,
    this.estimatedValueETH,
    required this.areaInSqFt,
    required this.avgPricePerSqFt,
    required this.avgPricePerSqFtETH,
    required this.zoning,
    required this.valuationFactors,
    this.currentEthPriceTND,
  });

  @override
  List<Object?> get props => [
        estimatedValue,
        estimatedValueETH,
        areaInSqFt,
        avgPricePerSqFt,
        avgPricePerSqFtETH,
        zoning,
        valuationFactors,
        currentEthPriceTND,
      ];
}

class ValuationFactor extends Equatable {
  final String factor;
  final String adjustment;

  const ValuationFactor({
    required this.factor,
    required this.adjustment,
  });

  @override
  List<Object?> get props => [factor, adjustment];
}

class ComparableProperty extends Equatable {
  final String id;
  final String address;
  final double price;
  final double priceInETH;
  final double area;
  final double pricePerSqFt;
  final double pricePerSqFtETH;
  final PropertyFeatures features;

  const ComparableProperty({
    required this.id,
    required this.address,
    required this.price,
    required this.priceInETH,
    required this.area,
    required this.pricePerSqFt,
    required this.pricePerSqFtETH,
    required this.features,
  });

  @override
  List<Object?> get props => [
        id,
        address,
        price,
        priceInETH,
        area,
        pricePerSqFt,
        pricePerSqFtETH,
        features,
      ];
}

class PropertyFeatures extends Equatable {
  final bool nearWater;
  final bool roadAccess;
  final bool utilities;

  const PropertyFeatures({
    required this.nearWater,
    required this.roadAccess,
    required this.utilities,
  });

  @override
  List<Object?> get props => [nearWater, roadAccess, utilities];
}