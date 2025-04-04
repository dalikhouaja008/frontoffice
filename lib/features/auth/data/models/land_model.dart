enum LandType {
  RESIDENTIAL,
  COMMERCIAL,
  INDUSTRIAL,
  AGRICULTURAL
}

enum LandStatus {
  AVAILABLE,
  SOLD,
  RESERVED
}

class Land {
  final String id;
  final String title;
  final String description;
  final String location;
  final String ownerId;
  final double latitude;
  final double longitude;
  final LandType type;
  final LandStatus status;
  final List<String> ipfsCIDs;
  final List<String> imageCIDs;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double price;
  final String imageUrl;

  const Land({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.ownerId,
    required this.latitude,
    required this.longitude,
    required this.type,
    required this.status,
    required this.ipfsCIDs,
    required this.imageCIDs,
    required this.createdAt,
    required this.updatedAt,
    required this.price,
    required this.imageUrl,
  });

static LandType _parseType(String? type) {
    switch (type?.toUpperCase()) {
      case 'RESIDENTIAL':
        return LandType.RESIDENTIAL;
      case 'COMMERCIAL':
        return LandType.COMMERCIAL;
      case 'INDUSTRIAL':
        return LandType.INDUSTRIAL;
      case 'AGRICULTURAL':
        return LandType.AGRICULTURAL;
      default:
        return LandType.RESIDENTIAL;
    }
  }

  static LandStatus _parseStatus(String? status) {
    switch (status?.toUpperCase()) {
      case 'SOLD':
        return LandStatus.SOLD;
      case 'RESERVED':
        return LandStatus.RESERVED;
      case 'AVAILABLE':
      default:
        return LandStatus.AVAILABLE;
    }
  }
  
  factory Land.fromJson(Map<String, dynamic> json) {
    return Land(
      id: json['_id'] ?? json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      location: json['location'],
      ownerId: json['ownerId'],
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      type: _parseType(json['type']),
      status: _parseStatus(json['status']),
      ipfsCIDs: List<String>.from(json['ipfsCIDs'] ?? []),
      imageCIDs: List<String>.from(json['imageCIDs'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
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