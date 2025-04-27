// lib/features/auth/data/models/land_model.dart
import 'package:json_annotation/json_annotation.dart';

part 'land_model.g.dart';

enum LandType {
  RESIDENTIAL,
  COMMERCIAL,
  AGRICULTURAL,
  INDUSTRIAL,
}

extension LandTypeExtension on LandType {
  String get displayName {
    return toString().split('.').last[0].toUpperCase() +
        toString().split('.').last.substring(1).toLowerCase();
  }

  String get name => toString().split('.').last;
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
  final String status; // Represents LandValidationStatus (e.g., PENDING_VALIDATION)
  final List<String>? ipfsCIDs; // Made nullable
  final List<String>? imageCIDs; // Made nullable
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? surface;
  final double? totalPrice;
  final int? totalTokens;
  final double? pricePerToken;
  final String? ownerAddress;
  final String? blockchainLandId;
  final LandType? landtype;
  final List<String>? documentCIDs;
  final Map<String, bool>? amenities; // Updated to Map<String, bool>
  final String availability;

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
    this.totalPrice,
    this.totalTokens,
    this.pricePerToken,
    this.ownerAddress,
    this.blockchainLandId,
    this.landtype,
    this.documentCIDs,
    this.amenities,
    required this.availability,
  });

  factory Land.fromJson(Map<String, dynamic> json) => _$LandFromJson(json);

  Map<String, dynamic> toJson() => _$LandToJson(this);
}