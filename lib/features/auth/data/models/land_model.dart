// lib/features/auth/data/models/land_model.dart
import 'package:equatable/equatable.dart';

enum LandValidationStatus {
  PENDING_VALIDATION('Pending Validation'),
  VALIDATED('Validated'),
  REJECTED('Rejected');

  const LandValidationStatus(this.displayName);
  final String displayName;

  @override
  String toString() => displayName;
}

enum ValidatorType {
  GOVERNMENT('Government'),
  NOTARY('Notary'),
  SURVEYOR('Surveyor');

  const ValidatorType(this.displayName);
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
      validatorType: ValidatorType.values[json['validatorType'] as int? ?? 0],
      timestamp: json['timestamp'] as int? ?? 0,
      isValidated: json['isValidated'] as bool? ?? false,
      cidComments: json['cidComments'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'validator': validator,
        'validatorType': validatorType.index,
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
  final int totalTokens;
  final String pricePerToken;
  final String ownerId;
  final String ownerAddress;
  final double? latitude;
  final double? longitude;
  final LandValidationStatus status;
  final List<String> ipfsCIDs;
  final List<String> imageCIDs;
  final String? metadataCID;
  final String? blockchainTxHash;
  final String blockchainLandId;
  final List<ValidationEntry> validations;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Land({
    required this.id,
    required this.title,
    this.description,
    required this.location,
    required this.surface,
    required this.totalTokens,
    required this.pricePerToken,
    required this.ownerId,
    required this.ownerAddress,
    this.latitude,
    this.longitude,
    required this.status,
    required this.ipfsCIDs,
    required this.imageCIDs,
    this.metadataCID,
    this.blockchainTxHash,
    required this.blockchainLandId,
    required this.validations,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Land.fromJson(Map<String, dynamic> json) {
    return Land(
      id: json['_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      location: json['location'] as String? ?? '',
      surface: (json['surface'] as num?)?.toDouble() ?? 0.0,
      totalTokens: json['totalTokens'] as int? ?? 0,
      pricePerToken: json['pricePerToken'] as String? ?? '0',
      ownerId: json['ownerId'] as String? ?? '',
      ownerAddress: json['ownerAddress'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      status: _parseStatus(json['status']),
      ipfsCIDs: (json['ipfsCIDs'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      imageCIDs: (json['imageCIDs'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      metadataCID: json['metadataCID'] as String?,
      blockchainTxHash: json['blockchainTxHash'] as String?,
      blockchainLandId: json['blockchainLandId'] as String? ?? '',
      validations: (json['validations'] as List<dynamic>?)
              ?.map((v) => ValidationEntry.fromJson(v as Map<String, dynamic>))
              .toList() ??
          [],
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
        'ownerId': ownerId,
        'ownerAddress': ownerAddress,
        'latitude': latitude,
        'longitude': longitude,
        'status': status.name,
        'ipfsCIDs': ipfsCIDs,
        'imageCIDs': imageCIDs,
        'metadataCID': metadataCID,
        'blockchainTxHash': blockchainTxHash,
        'blockchainLandId': blockchainLandId,
        'validations': validations.map((v) => v.toJson()).toList(),
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

  double get totalPrice => (double.tryParse(pricePerToken) ?? 0) * totalTokens.toDouble();

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        location,
        surface,
        totalTokens,
        pricePerToken,
        ownerId,
        ownerAddress,
        latitude,
        longitude,
        status,
        ipfsCIDs,
        imageCIDs,
        metadataCID,
        blockchainTxHash,
        blockchainLandId,
        validations,
        createdAt,
        updatedAt,
      ];
}