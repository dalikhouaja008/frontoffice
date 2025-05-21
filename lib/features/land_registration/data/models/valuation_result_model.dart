import '../../domain/entities/valuation_result.dart';
import 'location_info_model.dart';

class ValuationResultModel extends ValuationResult {
  const ValuationResultModel({
    required LocationInfoModel location,
    required ValuationInfoModel valuation,
    required List<ComparablePropertyModel> comparables,
  }) : super(
          location: location,
          valuation: valuation,
          comparables: comparables,
        );

  factory ValuationResultModel.fromJson(Map<String, dynamic> json) {
    return ValuationResultModel(
      location: LocationInfoModel.fromJson(json['location']),
      valuation: ValuationInfoModel.fromJson(json['valuation']),
      comparables: (json['comparables'] as List)
          .map((comparable) => ComparablePropertyModel.fromJson(comparable))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location': (location as LocationInfoModel).toJson(),
      'valuation': (valuation as ValuationInfoModel).toJson(),
      'comparables': comparables
          .map((comparable) => (comparable as ComparablePropertyModel).toJson())
          .toList(),
    };
  }
}

class ValuationInfoModel extends ValuationInfo {
  const ValuationInfoModel({
    required int estimatedValue,
    double? estimatedValueETH,
    required double areaInSqFt,
    required double avgPricePerSqFt,
    required double avgPricePerSqFtETH,
    required String zoning,
    required List<ValuationFactorModel> valuationFactors,
    double? currentEthPriceTND,
  }) : super(
          estimatedValue: estimatedValue,
          estimatedValueETH: estimatedValueETH,
          areaInSqFt: areaInSqFt,
          avgPricePerSqFt: avgPricePerSqFt,
          avgPricePerSqFtETH: avgPricePerSqFtETH,
          zoning: zoning,
          valuationFactors: valuationFactors,
          currentEthPriceTND: currentEthPriceTND,
        );

  factory ValuationInfoModel.fromJson(Map<String, dynamic> json) {
    return ValuationInfoModel(
      estimatedValue: json['estimatedValue'],
      estimatedValueETH: json['estimatedValueETH']?.toDouble(),
      areaInSqFt: json['areaInSqFt'].toDouble(),
      avgPricePerSqFt: json['avgPricePerSqFt'].toDouble(),
      avgPricePerSqFtETH: json['avgPricePerSqFtETH'].toDouble(),
      zoning: json['zoning'],
      valuationFactors: (json['valuationFactors'] as List)
          .map((factor) => ValuationFactorModel.fromJson(factor))
          .toList(),
      currentEthPriceTND: json['currentEthPriceTND']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'estimatedValue': estimatedValue,
      'estimatedValueETH': estimatedValueETH,
      'areaInSqFt': areaInSqFt,
      'avgPricePerSqFt': avgPricePerSqFt,
      'avgPricePerSqFtETH': avgPricePerSqFtETH,
      'zoning': zoning,
      'valuationFactors': valuationFactors
          .map((factor) => (factor as ValuationFactorModel).toJson())
          .toList(),
      'currentEthPriceTND': currentEthPriceTND,
    };
  }
}

class ValuationFactorModel extends ValuationFactor {
  const ValuationFactorModel({
    required String factor,
    required String adjustment,
  }) : super(
          factor: factor,
          adjustment: adjustment,
        );

  factory ValuationFactorModel.fromJson(Map<String, dynamic> json) {
    return ValuationFactorModel(
      factor: json['factor'],
      adjustment: json['adjustment'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'factor': factor,
      'adjustment': adjustment,
    };
  }
}

class ComparablePropertyModel extends ComparableProperty {
  const ComparablePropertyModel({
    required String id,
    required String address,
    required double price,
    required double priceInETH,
    required double area,
    required double pricePerSqFt,
    required double pricePerSqFtETH,
    required PropertyFeaturesModel features,
  }) : super(
          id: id,
          address: address,
          price: price,
          priceInETH: priceInETH,
          area: area,
          pricePerSqFt: pricePerSqFt,
          pricePerSqFtETH: pricePerSqFtETH,
          features: features,
        );

  factory ComparablePropertyModel.fromJson(Map<String, dynamic> json) {
    return ComparablePropertyModel(
      id: json['id'],
      address: json['address'],
      price: json['price'].toDouble(),
      priceInETH: json['priceInETH'].toDouble(),
      area: json['area'].toDouble(),
      pricePerSqFt: json['pricePerSqFt'].toDouble(),
      pricePerSqFtETH: json['pricePerSqFtETH'].toDouble(),
      features: PropertyFeaturesModel.fromJson(json['features']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'address': address,
      'price': price,
      'priceInETH': priceInETH,
      'area': area,
      'pricePerSqFt': pricePerSqFt,
      'pricePerSqFtETH': pricePerSqFtETH,
      'features': (features as PropertyFeaturesModel).toJson(),
    };
  }
}

class PropertyFeaturesModel extends PropertyFeatures {
  const PropertyFeaturesModel({
    required bool nearWater,
    required bool roadAccess,
    required bool utilities,
  }) : super(
          nearWater: nearWater,
          roadAccess: roadAccess,
          utilities: utilities,
        );

  factory PropertyFeaturesModel.fromJson(Map<String, dynamic> json) {
    return PropertyFeaturesModel(
      nearWater: json['nearWater'],
      roadAccess: json['roadAccess'],
      utilities: json['utilities'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nearWater': nearWater,
      'roadAccess': roadAccess,
      'utilities': utilities,
    };
  }
}