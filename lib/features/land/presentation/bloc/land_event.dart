import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

abstract class LandEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AddLandEvent extends LandEvent {
  final String name;
  final String location;
  final int size;
  final List<MultipartFile> photos;
  final List<MultipartFile> documents;

  AddLandEvent({
    required this.name,
    required this.location,
    required this.size,
    required this.photos,
    required this.documents,
  });

  @override
  List<Object?> get props => [name, location, size, photos, documents];
}

class GetAllLandsEvent extends LandEvent {}
