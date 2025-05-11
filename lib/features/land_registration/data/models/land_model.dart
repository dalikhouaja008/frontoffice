import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../domain/entities/land.dart';
import 'location_info_model.dart';
import 'amenity_model.dart';
import 'document_model.dart';

class LandModel extends Land {
  const LandModel({
    String? id,
    required String title,
    String? description,
    required LocationInfoModel location,
    required int surface,
    required int totalTokens,
    required double pricePerToken,
    required String status,
    required String landType,
    required List<AmenityModel> amenities,
    required List<LandDocumentModel> documents,
    required List<LandDocumentModel> images,
  }) : super(
          id: id,
          title: title,
          description: description,
          location: location,
          surface: surface,
          totalTokens: totalTokens,
          pricePerToken: pricePerToken,
          status: status,
          landType: landType,
          amenities: amenities,
          documents: documents,
          images: images,
        );

  factory LandModel.fromJson(Map<String, dynamic> json) {
    return LandModel(
      id: json['id'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      location: LocationInfoModel.fromJson(json['location'] as Map<String, dynamic>),
      surface: json['surface'] as int,
      totalTokens: json['totalTokens'] as int,
      pricePerToken: (json['pricePerToken'] as num).toDouble(),
      status: json['status'] as String,
      landType: json['landtype'] as String,
      amenities: (json['amenities'] as Map<String, dynamic>).entries
          .map((entry) => AmenityModel(
                name: entry.key,
                available: entry.value as bool,
              ))
          .toList(),
      documents: (json['documents'] as List<dynamic>)
          .map((document) => LandDocumentModel.fromJson(document as Map<String, dynamic>))
          .toList(),
      images: (json['images'] as List<dynamic>)
          .map((image) => LandDocumentModel.fromJson(image as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': (location as LocationInfoModel).toJson(),
      'surface': surface,
      'totalTokens': totalTokens,
      'pricePerToken': pricePerToken,
      'status': status,
      'landtype': landType,
      'amenities': {
        for (var amenity in amenities) (amenity as AmenityModel).name: amenity.available,
      },
      'documents': documents
          .map((document) => (document as LandDocumentModel).toJson())
          .toList(),
      'images':
          images.map((image) => (image as LandDocumentModel).toJson()).toList(),
    };
  }
}