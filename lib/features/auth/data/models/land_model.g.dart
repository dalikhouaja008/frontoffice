// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'land_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Land _$LandFromJson(Map<String, dynamic> json) => Land(
      id: json['_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      location: json['location'] as String,
      ownerId: json['ownerId'] as String,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      status: json['status'] as String,
      ipfsCIDs: (json['ipfsCIDs'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      imageCIDs: (json['imageCIDs'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      surface: (json['surface'] as num?)?.toDouble(),
      totalPrice: (json['totalPrice'] as num?)?.toDouble(),
      totalTokens: (json['totalTokens'] as num?)?.toInt(),
      pricePerToken: (json['pricePerToken'] as num?)?.toDouble(),
      ownerAddress: json['ownerAddress'] as String?,
      blockchainLandId: json['blockchainLandId'] as String?,
      landtype: $enumDecodeNullable(_$LandTypeEnumMap, json['landtype']),
      documentCIDs: (json['documentCIDs'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      amenities: (json['amenities'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as bool),
      ),
      availability: json['availability'] as String,
    );

Map<String, dynamic> _$LandToJson(Land instance) => <String, dynamic>{
      '_id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'location': instance.location,
      'ownerId': instance.ownerId,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'status': instance.status,
      'ipfsCIDs': instance.ipfsCIDs,
      'imageCIDs': instance.imageCIDs,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'surface': instance.surface,
      'totalPrice': instance.totalPrice,
      'totalTokens': instance.totalTokens,
      'pricePerToken': instance.pricePerToken,
      'ownerAddress': instance.ownerAddress,
      'blockchainLandId': instance.blockchainLandId,
      'landtype': _$LandTypeEnumMap[instance.landtype],
      'documentCIDs': instance.documentCIDs,
      'amenities': instance.amenities,
      'availability': instance.availability,
    };

const _$LandTypeEnumMap = {
  LandType.RESIDENTIAL: 'RESIDENTIAL',
  LandType.COMMERCIAL: 'COMMERCIAL',
  LandType.AGRICULTURAL: 'AGRICULTURAL',
  LandType.INDUSTRIAL: 'INDUSTRIAL',
};
