import 'package:json_annotation/json_annotation.dart';

part 'land_model.g.dart';

enum LandType {
  residential,
  commercial,
  agricultural,
  industrial,
}

extension LandTypeExtension on LandType {
  String get displayName {
    return toString().split('.').last[0].toUpperCase() +
        toString().split('.').last.substring(1).toLowerCase();
  }

  String get name => toString().split('.').last;
}

enum LandValidationStatus {
  PENDING_VALIDATION,
  VALIDATED,
  REJECTED
}

@JsonSerializable()
class Land {
  @JsonKey(name: '_id')
  final String id;
  final String title;
  final String? description;
  final String location;
  final String ownerId;
  final double? latitude;
  final double? longitude;
  final String status; 
  final List<String>? ipfsCIDs;
  final List<String>? imageCIDs;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? surface;
  final String? priceland; 
  final int? totalTokens;
  final String? pricePerToken; 
  final String? ownerAddress;
  final String? blockchainLandId;
  final LandType? landtype;
  final List<String>? documentUrls; // Added property from backend
  final List<String>? imageUrls; // Added property from backend
  final String? coverImageUrl; // Added property from backend
  
  // Custom converter for MongoDB Map to Dart Map
  @JsonKey(fromJson: _amenitiesFromJson, toJson: _amenitiesToJson)
  final Map<String, bool>? amenities;
  
  // Handle the fact that backend might not have this field yet
  @JsonKey(defaultValue: 'AVAILABLE')
  final String availability;
  
  // Add validations field if you need to access it from the frontend
  final List<ValidationEntry>? validations;

  Land({
    required this.id,
    required this.title,
    this.description,
    required this.location,
    required this.ownerId,
    this.latitude,
    this.longitude,
    required this.status,
    this.ipfsCIDs,
    this.imageCIDs,
    required this.createdAt,
    required this.updatedAt,
    this.surface,
    this.priceland,
    this.totalTokens,
    this.pricePerToken,
    this.ownerAddress,
    this.blockchainLandId,
    this.landtype,
    this.documentUrls,
    this.imageUrls,
    this.coverImageUrl,
    this.amenities,
    required this.availability,
    this.validations,
  });

  factory Land.fromJson(Map<String, dynamic> json) => _$LandFromJson(json);

  Map<String, dynamic> toJson() => _$LandToJson(this);
  
  // Custom converter for amenities
  static Map<String, bool>? _amenitiesFromJson(dynamic json) {
    if (json == null) return null;
    
    // Handle if backend sends as Map
    if (json is Map) {
      return Map<String, bool>.from(json.map((key, value) => 
        MapEntry(key.toString(), value is bool ? value : value == true || value == 'true')));
    }
    
    // Return empty map as fallback
    return {};
  }
  
  static dynamic _amenitiesToJson(Map<String, bool>? amenities) {
    return amenities;
  }
}

@JsonSerializable()
class ValidationEntry {
  final String? validator;
  final int? validatorType;
  final int? timestamp;
  final bool? isValidated;
  final String? cidComments;
  final String? txHash;
  final String? signature;
  final String? signatureType;
  final String? signedMessage;

  ValidationEntry({
    this.validator,
    this.validatorType,
    this.timestamp,
    this.isValidated,
    this.cidComments,
    this.txHash,
    this.signature,
    this.signatureType,
    this.signedMessage,
  });

  factory ValidationEntry.fromJson(Map<String, dynamic> json) => _$ValidationEntryFromJson(json);
  Map<String, dynamic> toJson() => _$ValidationEntryToJson(this);
}