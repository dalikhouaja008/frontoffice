enum LandType { AGRICULTURAL, RESIDENTIAL, INDUSTRIAL, COMMERCIAL }
enum LandStatus { AVAILABLE, PENDING, SOLD }

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
  final double price;
  final double surface;
  final List<String> imageCIDs;
  final DateTime createdAt;
  final DateTime updatedAt;

  Land({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.ownerId,
    required this.latitude,
    required this.longitude,
    required this.type,
    required this.status,
    required this.price,
    required this.surface,
    required this.imageCIDs,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Land.fromJson(Map<String, dynamic> json) {
    return Land(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      ownerId: json['ownerId'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      type: _parseType(json['type']),
      status: _parseStatus(json['status']),
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      surface: (json['surface'] as num?)?.toDouble() ?? 0.0,
      imageCIDs: List<String>.from(json['imageCIDs'] ?? []),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  static LandType _parseType(dynamic type) {
    if (type == null) return LandType.RESIDENTIAL;
    
    switch (type.toString().toUpperCase()) {
      case 'AGRICULTURAL':
        return LandType.AGRICULTURAL;
      case 'RESIDENTIAL':
        return LandType.RESIDENTIAL;
      case 'INDUSTRIAL':
        return LandType.INDUSTRIAL;
      case 'COMMERCIAL':
        return LandType.COMMERCIAL;
      default:
        return LandType.RESIDENTIAL;
    }
  }

  static LandStatus _parseStatus(dynamic status) {
    if (status == null) return LandStatus.AVAILABLE;
    
    switch (status.toString().toUpperCase()) {
      case 'AVAILABLE':
        return LandStatus.AVAILABLE;
      case 'PENDING':
        return LandStatus.PENDING;
      case 'SOLD':
        return LandStatus.SOLD;
      default:
        return LandStatus.AVAILABLE;
    }
  }
}