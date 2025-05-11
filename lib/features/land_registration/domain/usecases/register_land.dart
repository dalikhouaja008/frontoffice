import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:the_boost/features/land_registration/domain/usecases/usecase.dart';
import '../entities/document.dart';
import '../repositories/land_repository.dart';
import '../../../../core/error/failures.dart';

class RegisterLand implements UseCase<String, RegisterLandParams> {
  final LandRepository repository;

  RegisterLand(this.repository);

  @override
  Future<Either<Failure, String>> call(RegisterLandParams params) {
    return repository.registerLand(
      title: params.title,
      description: params.description,
      location: params.location,
      surface: params.surface,
      totalTokens: params.totalTokens,
      pricePerToken: params.pricePerToken,
      status: params.status,
      landType: params.landType,
      documents: params.documents,
      images: params.images,
      amenities: params.amenities,
    );
  }
}

class RegisterLandParams extends Equatable {
  final String title;
  final String? description;
  final String location;
  final int surface;
  final int totalTokens;
  final double pricePerToken;
  final String status;
  final String landType;
  final List<LandDocument> documents;
  final List<LandDocument> images;
  final Map<String, bool> amenities;

  const RegisterLandParams({
    required this.title,
    this.description,
    required this.location,
    required this.surface,
    required this.totalTokens,
    required this.pricePerToken,
    required this.status,
    required this.landType,
    required this.documents,
    required this.images,
    required this.amenities,
  });

  @override
  List<Object?> get props => [
        title,
        description,
        location,
        surface,
        totalTokens,
        pricePerToken,
        status,
        landType,
        documents,
        images,
        amenities,
      ];
}