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
      blockchainTxHash: json['blockchainTxHash'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      surface: (json['surface'] as num?)?.toDouble(),
      priceland: json['priceland'] as String?,
      totalTokens: (json['totalTokens'] as num?)?.toInt(),
      pricePerToken: json['pricePerToken'] as String?,
      ownerAddress: json['ownerAddress'] as String?,
      blockchainLandId: json['blockchainLandId'] as String?,
      landtype: $enumDecodeNullable(_$LandTypeEnumMap, json['landtype']),
      documentUrls: (json['documentUrls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      imageUrls: (json['imageUrls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      coverImageUrl: json['coverImageUrl'] as String?,
      amenities: Land._amenitiesFromJson(json['amenities']),
      availability: json['availability'] as String? ?? 'AVAILABLE',
      validations: (json['validations'] as List<dynamic>?)
          ?.map((e) => ValidationEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
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
      'blockchainTxHash': instance.blockchainTxHash,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'surface': instance.surface,
      'priceland': instance.priceland,
      'totalTokens': instance.totalTokens,
      'pricePerToken': instance.pricePerToken,
      'ownerAddress': instance.ownerAddress,
      'blockchainLandId': instance.blockchainLandId,
      'landtype': _$LandTypeEnumMap[instance.landtype],
      'documentUrls': instance.documentUrls,
      'imageUrls': instance.imageUrls,
      'coverImageUrl': instance.coverImageUrl,
      'amenities': Land._amenitiesToJson(instance.amenities),
      'availability': instance.availability,
      'validations': instance.validations,
    };

const _$LandTypeEnumMap = {
  LandType.residential: 'residential',
  LandType.commercial: 'commercial',
  LandType.agricultural: 'agricultural',
  LandType.industrial: 'industrial',
};

ValidationEntry _$ValidationEntryFromJson(Map<String, dynamic> json) =>
    ValidationEntry(
      validator: json['validator'] as String?,
      validatorType: (json['validatorType'] as num?)?.toInt(),
      timestamp: (json['timestamp'] as num?)?.toInt(),
      isValidated: json['isValidated'] as bool?,
      cidComments: json['cidComments'] as String?,
      txHash: json['txHash'] as String?,
      signature: json['signature'] as String?,
      signatureType: json['signatureType'] as String?,
      signedMessage: json['signedMessage'] as String?,
    );

Map<String, dynamic> _$ValidationEntryToJson(ValidationEntry instance) =>
    <String, dynamic>{
      'validator': instance.validator,
      'validatorType': instance.validatorType,
      'timestamp': instance.timestamp,
      'isValidated': instance.isValidated,
      'cidComments': instance.cidComments,
      'txHash': instance.txHash,
      'signature': instance.signature,
      'signatureType': instance.signatureType,
      'signedMessage': instance.signedMessage,
    };