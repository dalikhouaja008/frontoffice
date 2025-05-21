import 'package:equatable/equatable.dart';

class BlockchainDetails extends Equatable {
  final bool isTokenized;
  final String status;
  final int availableTokens;
  final String pricePerToken;
  final String cid;

  const BlockchainDetails({
    required this.isTokenized,
    required this.status,
    required this.availableTokens,
    required this.pricePerToken,
    required this.cid,
  });

  factory BlockchainDetails.fromJson(Map<String, dynamic> json) {
    return BlockchainDetails(
      isTokenized: json['isTokenized'] ?? false,
      status: json['status'] ?? '',
      availableTokens: json['availableTokens'] ?? 0,
      pricePerToken: json['pricePerToken']?.toString() ?? '0',
      cid: json['cid'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isTokenized': isTokenized,
      'status': status,
      'availableTokens': availableTokens,
      'pricePerToken': pricePerToken,
      'cid': cid,
    };
  }

  @override
  List<Object?> get props =>
      [isTokenized, status, availableTokens, pricePerToken, cid];
}

class ValidationProgress extends Equatable {
  final int total;
  final int completed;
  final double percentage;
  final List<ValidationStatus> validations;

  const ValidationProgress({
    required this.total,
    required this.completed,
    required this.percentage,
    required this.validations,
  });

  factory ValidationProgress.fromJson(Map<String, dynamic> json) {
    return ValidationProgress(
      total: json['total'] ?? 0,
      completed: json['completed'] ?? 0,
      percentage: (json['percentage'] ?? 0).toDouble(),
      validations: (json['validations'] as List<dynamic>?)
              ?.map((v) => ValidationStatus.fromJson(v))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'completed': completed,
      'percentage': percentage,
      'validations': validations.map((v) => v.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [total, completed, percentage, validations];
}

class ValidationStatus extends Equatable {
  final String role;
  final bool validated;

  const ValidationStatus({
    required this.role,
    required this.validated,
  });

  factory ValidationStatus.fromJson(Map<String, dynamic> json) {
    return ValidationStatus(
      role: json['role'] ?? '',
      validated: json['validated'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'validated': validated,
    };
  }

  @override
  List<Object?> get props => [role, validated];
}

class Land extends Equatable {
  final String id;
  final String title;
  final String description;
  final String location;
  final double surface;
  final int totalTokens;
  final String pricePerToken;
  final String ownerId;
  final String ownerAddress;
  final String status;
  final String landtype;
  final List<String> ipfsCIDs;
  final List<String> imageCIDs;
  final String blockchainTxHash;
  final String blockchainLandId;
  final List<dynamic> validations;
  final List<List<dynamic>> amenities;
  final bool isTokenized;
  final int availableTokens;
  final List<String> tokenIds;
  final List<dynamic> tokenizationAttempts;
  final DateTime createdAt;
  final DateTime updatedAt;
  final BlockchainDetails blockchainDetails;
  final ValidationProgress validationProgress;

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
    required this.blockchainTxHash,
    required this.blockchainLandId,
    required this.validations,
    required this.amenities,
    required this.isTokenized,
    required this.availableTokens,
    required this.tokenIds,
    required this.tokenizationAttempts,
    required this.createdAt,
    required this.updatedAt,
    required this.blockchainDetails,
    required this.validationProgress,
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
