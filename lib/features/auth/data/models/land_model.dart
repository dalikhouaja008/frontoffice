enum LandType { AGRICULTURAL, RESIDENTIAL, INDUSTRIAL, COMMERCIAL }
enum LandStatus { AVAILABLE, PENDING, SOLD }

class Land {
  final String id;
  final String title;
  final String? description;
  final String location;
  final LandType type;
  final LandStatus status;
  final String ownerId;
  final double? latitude;
  final double? longitude;
  final List<String> ipfsCIDs;
  final List<String> imageCIDs;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double price;
  final String imageUrl;

  const Land({
    required this.id,
    required this.title,
    this.description,
    required this.location,
    required this.type,
    required this.status,
    required this.ownerId,
    this.latitude,
    this.longitude,
    this.ipfsCIDs = const [],
    this.imageCIDs = const [],
    required this.createdAt,
    required this.updatedAt,
    required this.price,
    required this.imageUrl,
  });

  factory Land.fromJson(Map<String, dynamic> json) {
    return Land(
      id: json['_id'] as String, // Corrected to map `_id` to `id`
      title: json['title'] as String,
      description: json['description'] as String?,
      location: json['location'] as String,
      type: LandType.values.firstWhere(
        (e) => e.toString() == 'LandType.${json['type']}',
        orElse: () => LandType.RESIDENTIAL,
      ),
      status: LandStatus.values.firstWhere(
        (e) => e.toString() == 'LandStatus.${json['status']}',
        orElse: () => LandStatus.AVAILABLE,
      ),
      ownerId: json['ownerId'] as String,
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      ipfsCIDs: List<String>.from(json['ipfsCIDs'] ?? []),
      imageCIDs: List<String>.from(json['imageCIDs'] ?? []),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      price: json['price'] != null ? (json['price'] as num).toDouble() : 0.0,
      imageUrl: json['imageUrl'] ?? 'https://via.placeholder.com/150', // URL par défaut
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'ownerId': ownerId,
      'latitude': latitude,
      'longitude': longitude,
      'ipfsCIDs': ipfsCIDs,
      'imageCIDs': imageCIDs,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'price': price,
      'imageUrl': imageUrl,
    };
  }

  Land copyWith({
    String? id,
    String? title,
    String? description,
    String? location,
    LandType? type,
    LandStatus? status,
    String? ownerId,
    double? latitude,
    double? longitude,
    List<String>? ipfsCIDs,
    List<String>? imageCIDs,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? price,
    String? imageUrl,
  }) {
    return Land(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      type: type ?? this.type,
      status: status ?? this.status,
      ownerId: ownerId ?? this.ownerId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      ipfsCIDs: ipfsCIDs ?? this.ipfsCIDs,
      imageCIDs: imageCIDs ?? this.imageCIDs,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}