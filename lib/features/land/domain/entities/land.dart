import 'package:equatable/equatable.dart';

class Land extends Equatable {
  final String id;
  final String title;
  final String description;
  final String location;
  final double surface;
  final int totalTokens;
  final double pricePerToken;
  final String ownerId;
  final String ownerAddress;
  final String status;
  final String landtype;
  final List<String> ipfsCIDs;
  final List<String> imageCIDs;
  final String? blockchainTxHash;
  final String? blockchainLandId;
  final int validations;
  final List<String> amenities;
  final bool isTokenized;
  final int availableTokens;
  final List<String> tokenIds;
  final int tokenizationAttempts;
  final DateTime createdAt;
  final DateTime updatedAt;
  final BlockchainDetails? blockchainDetails;
  final ValidationProgress? validationProgress;

  const Land({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.surface,
    required this.totalTokens,
    required this.pricePerToken,
    required this.ownerId,
    required this.ownerAddress,
    required this.status,
    required this.landtype,
    required this.ipfsCIDs,
    required this.imageCIDs,
    this.blockchainTxHash,
    this.blockchainLandId,
    required this.validations,
    required this.amenities,
    required this.isTokenized,
    required this.availableTokens,
    required this.tokenIds,
    required this.tokenizationAttempts,
    required this.createdAt,
    required this.updatedAt,
    this.blockchainDetails,
    this.validationProgress,
  });

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
        status,
        landtype,
        ipfsCIDs,
        imageCIDs,
        blockchainTxHash,
        blockchainLandId,
        validations,
        amenities,
        isTokenized,
        availableTokens,
        tokenIds,
        tokenizationAttempts,
        createdAt,
        updatedAt,
        blockchainDetails,
        validationProgress,
      ];
}

class BlockchainDetails extends Equatable {
  final bool isTokenized;
  final String status;
  final int availableTokens;
  final double pricePerToken;
  final String cid;

  const BlockchainDetails({
    required this.isTokenized,
    required this.status,
    required this.availableTokens,
    required this.pricePerToken,
    required this.cid,
  });

  @override
  List<Object> get props => [
        isTokenized,
        status,
        availableTokens,
        pricePerToken,
        cid,
      ];
}

class ValidationProgress extends Equatable {
  final int totalValidations;
  final int completedValidations;
  final double percentage;
  final List<ValidationStatus> validationStatuses;

  const ValidationProgress({
    required this.totalValidations,
    required this.completedValidations,
    required this.percentage,
    required this.validationStatuses,
  });

  @override
  List<Object> get props => [
        totalValidations,
        completedValidations,
        percentage,
        validationStatuses,
      ];
}

class ValidationStatus extends Equatable {
  final String role;
  final bool validated;

  const ValidationStatus({
    required this.role,
    required this.validated,
  });

  @override
  List<Object> get props => [role, validated];
}
