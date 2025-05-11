import '../../domain/entities/amenity.dart';

class AmenityModel extends Amenity {
  const AmenityModel({
    required String name,
    required bool available,
  }) : super(
          name: name,
          available: available,
        );

  factory AmenityModel.fromJson(Map<String, dynamic> json) {
    return AmenityModel(
      name: json['name'],
      available: json['available'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'available': available,
    };
  }
}