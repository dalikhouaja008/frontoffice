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
  REJECTED,
  PARTIALLY_VALIDATED,
  EN_ATTENTE,
  VALIDE,
  REJETE
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
  final String? blockchainTxHash;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? surface;
  final String? priceland; 
  final int? totalTokens;
  final String? pricePerToken; 
  final String? ownerAddress;
  final String? blockchainLandId;
  final LandType? landtype;
  final List<String>? documentUrls;
  final List<String>? imageUrls; 
  final String? coverImageUrl;
  
  // Custom converter for MongoDB Map to Dart Map
  @JsonKey(fromJson: _amenitiesFromJson, toJson: _amenitiesToJson)
  final Map<String, bool>? amenities;
  
  // Handle the fact that backend might not have this field yet
  @JsonKey(defaultValue: 'AVAILABLE')
  final String availability;
  
  // Add validations field if you need to access it from the frontend
  final List<ValidationEntry>? validations;
  
  // New fields for tokenization
  @JsonKey(defaultValue: false)
  final bool isTokenized;
  
  final String? tokenizationTxHash;
  
  final DateTime? tokenizationTimestamp;
  
  final String? tokenizationError;
  
  @JsonKey(defaultValue: 0)
  final int availableTokens;
  
  final List<int>? tokenIds;

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
    this.blockchainTxHash, 
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
    this.isTokenized = false,
    this.tokenizationTxHash,
    this.tokenizationTimestamp,
    this.tokenizationError,
    this.availableTokens = 0,
    this.tokenIds,
  });

  factory Land.fromJson(Map<String, dynamic> json) => _$LandFromJson(json);

  Map<String, dynamic> toJson() => _$LandToJson(this);
  
  // Custom converter for amenities
  static Map<String, bool>? _amenitiesFromJson(dynamic json) {
    if (json == null) return null;
    
    // Pour le débogage
    print('Amenities JSON type: ${json.runtimeType}');
    print('Amenities JSON value: $json');
    
    // Cas 1: Si le backend envoie comme Map
    if (json is Map) {
      return Map<String, bool>.from(json.map((key, value) => 
        MapEntry(key.toString(), value is bool ? value : value == true || value == 'true')));
    }
    
    // Cas 2: Si le backend envoie comme liste de listes [[key, value], [key, value], ...]
    if (json is List) {
      final Map<String, bool> result = {};
      for (var item in json) {
        if (item is List && item.length >= 2) {
          final key = item[0].toString();
          final value = item[1] is bool ? item[1] : (item[1].toString().toLowerCase() == 'true');
          result[key] = value;
        }
      }
      print('Converted amenities from list to map: $result'); // Log pour vérification
      return result;
    }
    
    // Si format inconnu, retourner une map vide
    print('Unknown amenities format, returning empty map');
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