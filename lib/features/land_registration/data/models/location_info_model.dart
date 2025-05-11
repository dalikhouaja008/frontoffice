import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../domain/entities/location_info.dart';

class LocationInfoModel extends LocationInfo {
  const LocationInfoModel({
    required LatLng position,
    String? address,
  }) : super(
          position: position,
          address: address,
        );

  factory LocationInfoModel.fromJson(Map<String, dynamic> json) {
    return LocationInfoModel(
      position: LatLng(
        json['position']['latitude'],
        json['position']['longitude'],
      ),
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'position': {
        'latitude': position.latitude,
        'longitude': position.longitude,
      },
      'address': address,
    };
  }
}