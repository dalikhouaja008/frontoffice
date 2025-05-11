import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationInfo extends Equatable {
  final LatLng position;
  final String? address;

  const LocationInfo({
    required this.position,
    this.address,
  });

  @override
  List<Object?> get props => [position, address];
}