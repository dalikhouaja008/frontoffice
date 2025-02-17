import 'package:equatable/equatable.dart';

class Land extends Equatable {
  final String id;
  final String name;
  final String location;
  final List<String>? photos;
  final List<String>? documents;
  final int size;
  final String owner;

  const Land({
    required this.id,
    required this.name,
    required this.location,
    this.photos,
    this.documents,
    required this.size,
    required this.owner,
  });

  factory Land.fromJson(Map<String, dynamic> json) {
    return Land(
      id: json['id'] as String,
      name: json['name'] as String,
      location: json['location'] as String,
      size: json['size'] as int,
      photos: List<String>.from(json['photos']),
      documents: List<String>.from(json['documents']),
      owner: json['owner'] as String, // Fixed
    );
  }

  @override
  List<Object?> get props => [id, name, location, photos, documents, size, owner];
}
