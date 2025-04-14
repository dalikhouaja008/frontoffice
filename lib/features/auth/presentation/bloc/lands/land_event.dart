// lib/features/auth/presentation/bloc/lands/land_event.dart
part of 'land_bloc.dart';

@immutable
abstract class LandEvent {}

class LoadLands extends LandEvent {}

class LoadLandsForUser extends LandEvent {
  final String userId;
  final String accessToken;

  LoadLandsForUser(this.userId, this.accessToken);
}

class LoadLandTypes extends LandEvent {}

class NavigateToLandDetails extends LandEvent {
  final Land land;

  NavigateToLandDetails({required this.land});
}

class ApplyFilters extends LandEvent {
  final RangeValues priceRange;
  final String searchQuery;
  final String sortBy;
  final LandType? landType;
  final LandValidationStatus? validationStatus;
  final Map<String, bool> amenities;

  ApplyFilters({
    required this.priceRange,
    required this.searchQuery,
    required this.sortBy,
    this.landType,
    this.validationStatus,
    required this.amenities,
  });
}