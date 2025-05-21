import 'package:equatable/equatable.dart';

class LandDocument extends Equatable {
  final String name;
  final int size;
  final List<int>? bytes;
  final String? path;
  final String contentType;
  
  const LandDocument({
    required this.name,
    required this.size,
    this.bytes,
    this.path,
    required this.contentType,
  });

  @override
  List<Object?> get props => [name, size, bytes, path, contentType];
}