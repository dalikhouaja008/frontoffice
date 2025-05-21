import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../domain/entities/valuation_result.dart';

abstract class RegisterLandEvent extends Equatable {
  const RegisterLandEvent();

  @override
  List<Object?> get props => [];
}

// Navigation events
class GoToNextStepEvent extends RegisterLandEvent {}

class GoToPreviousStepEvent extends RegisterLandEvent {}

class GoToSpecificStepEvent extends RegisterLandEvent {
  final int step;

  const GoToSpecificStepEvent(this.step);

  @override
  List<Object?> get props => [step];
}

// Form input events
class TitleChangedEvent extends RegisterLandEvent {
  final String title;

  const TitleChangedEvent(this.title);

  @override
  List<Object?> get props => [title];
}

class DescriptionChangedEvent extends RegisterLandEvent {
  final String description;

  const DescriptionChangedEvent(this.description);

  @override
  List<Object?> get props => [description];
}

class LandTypeChangedEvent extends RegisterLandEvent {
  final String landType;

  const LandTypeChangedEvent(this.landType);

  @override
  List<Object?> get props => [landType];
}

class SurfaceChangedEvent extends RegisterLandEvent {
  final String surface;

  const SurfaceChangedEvent(this.surface);

  @override
  List<Object?> get props => [surface];
}

class LocationChangedEvent extends RegisterLandEvent {
  final String location;

  const LocationChangedEvent(this.location);

  @override
  List<Object?> get props => [location];
}

class PositionChangedEvent extends RegisterLandEvent {
  final LatLng position;

  const PositionChangedEvent(this.position);

  @override
  List<Object?> get props => [position];
}

class TotalTokensChangedEvent extends RegisterLandEvent {
  final String totalTokens;

  const TotalTokensChangedEvent(this.totalTokens);

  @override
  List<Object?> get props => [totalTokens];
}

class AmenityChangedEvent extends RegisterLandEvent {
  final String amenityName;
  final bool value;

  const AmenityChangedEvent(this.amenityName, this.value);

  @override
  List<Object?> get props => [amenityName, value];
}

class DocumentsUploadedEvent extends RegisterLandEvent {
  final List<PlatformFile> files;

  const DocumentsUploadedEvent(this.files);

  @override
  List<Object?> get props => [files];
}

class RemoveDocumentEvent extends RegisterLandEvent {
  final PlatformFile document;
  final bool isImage;

  const RemoveDocumentEvent(this.document, {required this.isImage});

  @override
  List<Object?> get props => [document, isImage];
}

class FetchEthPriceEvent extends RegisterLandEvent {}

class RequestLandEvaluationEvent extends RegisterLandEvent {}

class AcceptPriceEvent extends RegisterLandEvent {
  final bool accept;

  const AcceptPriceEvent(this.accept);

  @override
  List<Object?> get props => [accept];
}

class SubmitRegistrationEvent extends RegisterLandEvent {}

class ResetFormEvent extends RegisterLandEvent {}