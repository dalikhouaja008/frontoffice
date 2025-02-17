import '../../domain/entities/land.dart';

class LandModel extends Land {
  LandModel({
    required String id,
    required String name,
    required String location,
    List<String>? photos,
    List<String>? documents,
    required int size,
    required String owner,
  }) : super(
          id: id,
          name: name,
          location: location,
          photos: photos ?? [],
          documents: documents ?? [],
          size: size,
          owner: owner,
        );

  factory LandModel.fromJson(Map<String, dynamic> json) {
    return LandModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      photos: List<String>.from(json['photos'] ?? []),
      documents: List<String>.from(json['documents'] ?? []),
      size: json['size'] ?? 0,
      owner: json['owner'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'location': location,
      'photos': photos,
      'documents': documents,
      'size': size,
    };
  }
}
