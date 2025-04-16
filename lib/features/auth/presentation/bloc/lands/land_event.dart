// lib/features/auth/presentation/bloc/lands/land_event.dart
part of 'land_bloc.dart';

abstract class LandEvent {}

class LoadLands extends LandEvent {}

class NavigateToLandDetails extends LandEvent {
  final Land land;
  NavigateToLandDetails({required this.land});
}

class ApplyFilters extends LandEvent {
  final RangeValues priceRange;
  final String searchQuery;
  final String sortBy;
  final String? landType;
  final String? validationStatus; // Now a String
  final Map<String, bool>? amenities;

  ApplyFilters({
    required this.priceRange,
    required this.searchQuery,
    required this.sortBy,
    this.landType,
    this.validationStatus,
    this.amenities,
  });
}