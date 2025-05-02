// lib/features/auth/presentation/bloc/lands/land_event.dart
part of 'land_bloc.dart';

abstract class LandEvent {}

class LoadLands extends LandEvent {}
class LoadLandTypes extends LandEvent {} // ✅ ADD THIS


class NavigateToLandDetails extends LandEvent {
  final Land land;
  NavigateToLandDetails({required this.land});
}

class ApplyFilters extends LandEvent {
  final RangeValues priceRange;
  final String searchQuery;
  final String? sortBy;
  final String? landType;
  final String? validationStatus;
  final String? availability;
  final Map<String, bool>? amenities;

  ApplyFilters({
    required this.priceRange,
    required this.searchQuery,
    this.sortBy,
    this.landType,
    this.validationStatus,
    this.availability,
    this.amenities,
  });
}