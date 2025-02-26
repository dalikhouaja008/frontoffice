// models/land_model.dart

enum LandType { AGRICULTURAL, RESIDENTIAL, INDUSTRIAL, COMMERCIAL }
enum LandStatus { AVAILABLE, PENDING, SOLD }

class Land {
  final String id;
  final String name;
  final String description;
  final String location;
  final LandType type;
  final LandStatus status;
  final double price;
  final double surface;
  final String imageUrl;
  final DateTime createdAt;
  final String? title;  // Made optional with ?

  const Land({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.type,
    required this.status,
    required this.price,
    required this.surface,
    required this.imageUrl,
    required this.createdAt,
    this.title,  // Optional parameter
  });

  // Add fromJson constructor
  factory Land.fromJson(Map<String, dynamic> json) {
    return Land(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      location: json['location'] as String,
      type: LandType.values.firstWhere(
        (e) => e.toString() == 'LandType.${json['type']}',
        orElse: () => LandType.RESIDENTIAL,
      ),
      status: LandStatus.values.firstWhere(
        (e) => e.toString() == 'LandStatus.${json['status']}',
        orElse: () => LandStatus.AVAILABLE,
      ),
      price: (json['price'] as num).toDouble(),
      surface: (json['surface'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      title: json['title'] as String?,
    );
  }

  // Add toJson method
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'location': location,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'price': price,
      'surface': surface,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'title': title,
    };
  }

  // Add copyWith method
  Land copyWith({
    String? id,
    String? name,
    String? description,
    String? location,
    LandType? type,
    LandStatus? status,
    double? price,
    double? surface,
    String? imageUrl,
    DateTime? createdAt,
    String? title,
  }) {
    return Land(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      location: location ?? this.location,
      type: type ?? this.type,
      status: status ?? this.status,
      price: price ?? this.price,
      surface: surface ?? this.surface,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      title: title ?? this.title,
    );
  }
}