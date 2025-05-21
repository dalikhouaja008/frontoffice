import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../domain/entities/valuation_result.dart';

enum RegistrationStatus {
  initial,
  loading,
  success,
  failure,
}

enum EvaluationStatus {
  initial,
  loading,
  success,
  failure,
  simulated,
}

class RegisterLandState extends Equatable {
  final int currentStep;
  final String title;
  final String description;
  final String? landType;
  final String surface;
  final String location;
  final LatLng? position;
  final String totalTokens;
  final Map<String, bool> amenities;
  final List<PlatformFile> documents;
  final List<PlatformFile> images;
  final Map<String, dynamic>? ethPriceData;
  final ValuationResult? evaluationResult;
  final EvaluationStatus evaluationStatus;
  final bool isAcceptingPrice;
  final RegistrationStatus registrationStatus;
  final String? errorMessage;
  final String? successLandId;

  const RegisterLandState({
    this.currentStep = 0,
    this.title = '',
    this.description = '',
    this.landType,
    this.surface = '',
    this.location = '',
    this.position,
    this.totalTokens = '100',
    this.amenities = const {},
    this.documents = const [],
    this.images = const [],
    this.ethPriceData,
    this.evaluationResult,
    this.evaluationStatus = EvaluationStatus.initial,
    this.isAcceptingPrice = false,
    this.registrationStatus = RegistrationStatus.initial,
    this.errorMessage,
    this.successLandId,
  });

  RegisterLandState copyWith({
    int? currentStep,
    String? title,
    String? description,
    String? landType,
    String? surface,
    String? location,
    LatLng? position,
    String? totalTokens,
    Map<String, bool>? amenities,
    List<PlatformFile>? documents,
    List<PlatformFile>? images,
    Map<String, dynamic>? ethPriceData,
    ValuationResult? evaluationResult,
    EvaluationStatus? evaluationStatus,
    bool? isAcceptingPrice,
    RegistrationStatus? registrationStatus,
    String? errorMessage,
    String? successLandId,
  }) {
    return RegisterLandState(
      currentStep: currentStep ?? this.currentStep,
      title: title ?? this.title,
      description: description ?? this.description,
      landType: landType ?? this.landType,
      surface: surface ?? this.surface,
      location: location ?? this.location,
      position: position ?? this.position,
      totalTokens: totalTokens ?? this.totalTokens,
      amenities: amenities ?? this.amenities,
      documents: documents ?? this.documents,
      images: images ?? this.images,
      ethPriceData: ethPriceData ?? this.ethPriceData,
      evaluationResult: evaluationResult ?? this.evaluationResult,
      evaluationStatus: evaluationStatus ?? this.evaluationStatus,
      isAcceptingPrice: isAcceptingPrice ?? this.isAcceptingPrice,
      registrationStatus: registrationStatus ?? this.registrationStatus,
      errorMessage: errorMessage,
      successLandId: successLandId ?? this.successLandId,
    );
  }

  bool get isStepValid {
    switch (currentStep) {
      case 0: // Basic info
        return title.isNotEmpty && 
               landType != null && 
               surface.isNotEmpty && 
               double.tryParse(surface) != null && 
               double.parse(surface) > 0;
      case 1: // Location
        return location.isNotEmpty && position != null;
      case 2: // Amenities
        return true; // No validation required for amenities
      case 3: // Documentation
        return documents.isNotEmpty;
      case 4: // Evaluation
        return evaluationStatus == EvaluationStatus.success || 
               evaluationStatus == EvaluationStatus.simulated;
      case 5: // Review
        return evaluationResult != null && isAcceptingPrice;
      default:
        return false;
    }
  }

  bool get canSubmit {
    return currentStep == 5 && 
           isStepValid && 
           evaluationResult != null && 
           isAcceptingPrice && 
           registrationStatus != RegistrationStatus.loading;
  }

  @override
  List<Object?> get props => [
        currentStep,
        title,
        description,
        landType,
        surface,
        location,
        position,
        totalTokens,
        amenities,
        documents,
        images,
        ethPriceData,
        evaluationResult,
        evaluationStatus,
        isAcceptingPrice,
        registrationStatus,
        errorMessage,
        successLandId,
      ];
}