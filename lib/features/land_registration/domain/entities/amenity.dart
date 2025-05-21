import 'package:equatable/equatable.dart';

class Amenity extends Equatable {
  final String name;
  final bool available;

  const Amenity({
    required this.name,
    required this.available,
  });

  @override
  List<Object?> get props => [name, available];
}