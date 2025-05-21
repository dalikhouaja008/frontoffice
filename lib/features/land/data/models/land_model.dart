import 'package:equatable/equatable.dart';
import 'package:the_boost/features/land/domain/entities/land.dart';

class LandModel extends Land {
  const LandModel({
    required String id,
    required String title,
    required String description,
    required String location,
    required double surface,
    required int totalTokens,
    required double pricePerToken,
    required String ownerId,
    required String ownerAddress,
    required String status,
    required String landtype,
    required List<String> ipfsCIDs,
    required List<String> imageCIDs,
    String? blockchainTxHash,
    String? blockchainLandId,
    required int validations,
    required List<String> amenities,
    required bool isTokenized,
    required int availableTokens,
    required List<String> tokenIds,
    required int tokenizationAttempts,
    required DateTime createdAt,
    required DateTime updatedAt,
    BlockchainDetails? blockchainDetails,
    ValidationProgress? validationProgress,
  }) : super(
          id: id,
          title: title,
          description: description,
          location: location,
          surface: surface,
          totalTokens: totalTokens,
          pricePerToken: pricePerToken,
          ownerId: ownerId,
          ownerAddress: ownerAddress,
          status: status,
          landtype: landtype,
          ipfsCIDs: ipfsCIDs,
          imageCIDs: imageCIDs,
          blockchainTxHash: blockchainTxHash,
          blockchainLandId: blockchainLandId,
          validations: validations,
          amenities: amenities,
          isTokenized: isTokenized,
          availableTokens: availableTokens,
          tokenIds: tokenIds,
          tokenizationAttempts: tokenizationAttempts,
          createdAt: createdAt,
          updatedAt: updatedAt,
          blockchainDetails: blockchainDetails,
          validationProgress: validationProgress,
        );

  factory LandModel.fromJson(Map<String, dynamic> json) {
    return LandModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      location: json['location'] as String,
      surface: (json['surface'] as num).toDouble(),
      totalTokens: json['totalTokens'] as int,
      pricePerToken: (json['pricePerToken'] as num).toDouble(),
      ownerId: json['ownerId'] as String,
      ownerAddress: json['ownerAddress'] as String,
      status: json['status'] as String,
      landtype: json['landtype'] as String,
      ipfsCIDs: List<String>.from(json['ipfsCIDs'] as List),
      imageCIDs: List<String>.from(json['imageCIDs'] as List),
      blockchainTxHash: json['blockchainTxHash'] as String?,
      blockchainLandId: json['blockchainLandId'] as String?,
      validations: json['validations'] as int,
      amenities: List<String>.from(json['amenities'] as List),
      isTokenized: json['isTokenized'] as bool,
      availableTokens: json['availableTokens'] as int,
      tokenIds: List<String>.from(json['tokenIds'] as List),
      tokenizationAttempts: json['tokenizationAttempts'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      blockchainDetails: json['blockchainDetails'] != null
          ? BlockchainDetails(
              isTokenized: json['blockchainDetails']['isTokenized'] as bool,
              status: json['blockchainDetails']['status'] as String,
              availableTokens:
                  json['blockchainDetails']['availableTokens'] as int,
              pricePerToken: (json['blockchainDetails']['pricePerToken'] as num)
                  .toDouble(),
              cid: json['blockchainDetails']['cid'] as String,
            )
          : null,
      validationProgress: json['validationProgress'] != null
          ? ValidationProgress(
              totalValidations:
                  json['validationProgress']['totalValidations'] as int,
              completedValidations:
                  json['validationProgress']['completedValidations'] as int,
              percentage:
                  (json['validationProgress']['percentage'] as num).toDouble(),
              validationStatuses:
                  (json['validationProgress']['validationStatuses'] as List)
                      .map((status) => ValidationStatus(
                            role: status['role'] as String,
                            validated: status['validated'] as bool,
                          ))
                      .toList(),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location,
      'surface': surface,
      'totalTokens': totalTokens,
      'pricePerToken': pricePerToken,
      'ownerId': ownerId,
      'ownerAddress': ownerAddress,
      'status': status,
      'landtype': landtype,
      'ipfsCIDs': ipfsCIDs,
      'imageCIDs': imageCIDs,
      'blockchainTxHash': blockchainTxHash,
      'blockchainLandId': blockchainLandId,
      'validations': validations,
      'amenities': amenities,
      'isTokenized': isTokenized,
      'availableTokens': availableTokens,
      'tokenIds': tokenIds,
      'tokenizationAttempts': tokenizationAttempts,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'blockchainDetails': blockchainDetails != null
          ? {
              'isTokenized': blockchainDetails!.isTokenized,
              'status': blockchainDetails!.status,
              'availableTokens': blockchainDetails!.availableTokens,
              'pricePerToken': blockchainDetails!.pricePerToken,
              'cid': blockchainDetails!.cid,
            }
          : null,
      'validationProgress': validationProgress != null
          ? {
              'totalValidations': validationProgress!.totalValidations,
              'completedValidations': validationProgress!.completedValidations,
              'percentage': validationProgress!.percentage,
              'validationStatuses': validationProgress!.validationStatuses
                  .map((status) => {
                        'role': status.role,
                        'validated': status.validated,
                      })
                  .toList(),
            }
          : null,
    };
  }
}
