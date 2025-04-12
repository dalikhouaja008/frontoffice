// lib/features/auth/data/models/land_model.dart
import 'package:equatable/equatable.dart';

enum LandValidationStatus {
  PENDING_VALIDATION('Pending Validation'),
  VALIDATED('Validated'),
  REJECTED('Rejected'),
  PARTIALLY_VALIDATED('Partially Validated');

  const LandValidationStatus(this.displayName);
  final String displayName;

  @override
  String toString() => displayName;
}

enum ValidatorType {
  NOTAIRE('Notaire'),
  GEOMETRE('Geometre'),
  EXPERT_JURIDIQUE('Expert Juridique');

  const ValidatorType(this.displayName);
  final String displayName;

  @override
  String toString() => displayName;
}

enum LandType {
  AGRICULTURAL('Agricultural'),
  RESIDENTIAL('Residential'),
  COMMERCIAL('Commercial'),
  INDUSTRIAL('Industrial');

  const LandType(this.displayName);
  final String displayName;

  @override
  String toString() => displayName;
}

class ValidationEntry extends Equatable {
  final String validator;
  final ValidatorType validatorType;
  final int timestamp;
  final bool isValidated;
  final String cidComments;

  const ValidationEntry({
    required this.validator,
    required this.validatorType,
    required this.timestamp,
    required this.isValidated,
    required this.cidComments,
  });

  factory ValidationEntry.fromJson(Map<String, dynamic> json) {
    return ValidationEntry(
      validator: json['validator'] as String? ?? '',
      validatorType: ValidatorType.values.firstWhere(
        (e) => e.name == (json['validatorType'] as String? ?? 'NOTAIRE'),
        orElse: () => ValidatorType.NOTAIRE,
      ),
      timestamp: json['timestamp'] as int? ?? 0,
      isValidated: json['isValidated'] as bool? ?? false,
      cidComments: json['cidComments'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'validator': validator,
        'validatorType': validatorType.name,
        'timestamp': timestamp,
        'isValidated': isValidated,
        'cidComments': cidComments,
      };

  @override
  List<Object?> get props => [
        validator,
        validatorType,
        timestamp,
        isValidated,
        cidComments,
      ];
}

class Land extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String location;
  final double surface;
  final int? totalTokens;
  final String? pricePerToken;
  final String? priceland;
  final String ownerId;
  final String ownerAddress;
  final double? latitude;
  final double? longitude;
  final LandValidationStatus status;
  final LandType landtype;
  final List<String> ipfsCIDs;
  final List<String> imageCIDs;
  final String? blockchainTxHash;
  final String blockchainLandId;
  final List<ValidationEntry> validations;
  final Map<String, bool> amenities;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Land({
    required this.id,
    required this.title,
    this.description,
    required this.location,
    required this.surface,
    this.totalTokens,
    this.pricePerToken,
    this.priceland,
    required this.ownerId,
    required this.ownerAddress,
    this.latitude,
    this.longitude,
    required this.status,
    required this.landtype,
    required this.ipfsCIDs,
    required this.imageCIDs,
    this.blockchainTxHash,
    required this.blockchainLandId,
    required this.validations,
    required this.amenities,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Land.fromJson(Map<String, dynamic> json) {
    return Land(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      location: json['location'] as String? ?? '',
      surface: (json['surface'] as num?)?.toDouble() ?? 1000.0,
      totalTokens: json['totalTokens'] as int?,
      pricePerToken: json['pricePerToken'] as String?,
      priceland: json['priceland'] as String?,
      ownerId: json['ownerId'] as String? ?? '',
      ownerAddress: json['ownerAddress'] as String? ?? '0x0000000000000000000000000000000000000000',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      status: _parseStatus(json['status']),
      landtype: _parseLandType(json['landtype']),
      ipfsCIDs: (json['ipfsCIDs'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      imageCIDs: (json['imageCIDs'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      blockchainTxHash: json['blockchainTxHash'] as String?,
      blockchainLandId: json['blockchainLandId'] as String? ?? json['_id'] as String? ?? '',
      validations: (json['validations'] as List<dynamic>?)
              ?.map((v) => ValidationEntry.fromJson(v as Map<String, dynamic>))
              .toList() ??
          [],
      amenities: (json['amenities'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, value as bool),
          ) ??
          {
            'electricity': false,
            'gas': false,
            'water': false,
            'sewer': false,
            'internet': false,
            'roadAccess': false,
            'publicTransport': false,
            'pavedRoad': false,
            'buildingPermit': false,
            'boundaryMarkers': false,
            'drainage': false,
            'floodRisk': false,
            'rainwaterCollection': false,
            'fenced': false,
            'trees': false,
            'wellWater': false,
            'flatTerrain': false,
          },
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'title': title,
        'description': description,
        'location': location,
        'surface': surface,
        'totalTokens': totalTokens,
        'pricePerToken': pricePerToken,
        'priceland': priceland,
        'ownerId': ownerId,
        'ownerAddress': ownerAddress,
        'latitude': latitude,
        'longitude': longitude,
        'status': status.name,
        'landtype': landtype.name,
        'ipfsCIDs': ipfsCIDs,
        'imageCIDs': imageCIDs,
        'blockchainTxHash': blockchainTxHash,
        'blockchainLandId': blockchainLandId,
        'validations': validations.map((v) => v.toJson()).toList(),
        'amenities': amenities,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  static LandValidationStatus _parseStatus(dynamic status) {
    if (status is String) {
      return LandValidationStatus.values.firstWhere(
        (e) => e.name.toUpperCase() == status.toUpperCase(),
        orElse: () => LandValidationStatus.PENDING_VALIDATION,
      );
    }
    return LandValidationStatus.PENDING_VALIDATION;
  }

  static LandType _parseLandType(dynamic landtype) {
    if (landtype is String) {
      return LandType.values.firstWhere(
        (e) => e.name.toUpperCase() == landtype.toUpperCase(),
        orElse: () => LandType.AGRICULTURAL,
      );
    }
    return LandType.AGRICULTURAL;
  }

  double get totalPrice {
    if (pricePerToken == null || totalTokens == null) return 0.0;
    return (double.tryParse(pricePerToken!) ?? 0) * totalTokens!.toDouble();
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        location,
        surface,
        totalTokens,
        pricePerToken,
        priceland,
        ownerId,
        ownerAddress,
        latitude,
        longitude,
        status,
        landtype,
        ipfsCIDs,
        imageCIDs,
        blockchainTxHash,
        blockchainLandId,
        validations,
        amenities,
        createdAt,
        updatedAt,
      ];
}