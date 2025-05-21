import 'package:equatable/equatable.dart';
import 'location_info.dart';
import 'amenity.dart';
import 'document.dart';

class Land extends Equatable {
  final String? id;
  final String title;
  final String? description;
  final LocationInfo location;
  final int surface;
  final int totalTokens;
  final double pricePerToken;
  final String status;
  final String landType;
  final List<Amenity> amenities;
  final List<LandDocument> documents;
  final List<LandDocument> images;

  const Land({
    this.id,
    required this.title,
    this.description,
    required this.location,
    required this.surface,
    required this.totalTokens,
    required this.pricePerToken,
    required this.status,
    required this.landType,
    required this.amenities,
    required this.documents,
    required this.images,
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
        status,
        landType,
        amenities,
        documents,
        images,
      ];
}