part of 'land_bloc.dart';

abstract class LandEvent {}

class LoadLands extends LandEvent {}

class LoadLandById extends LandEvent {
  final String landId;

  LoadLandById(this.landId);
}

class NavigateToLandDetails extends LandEvent {
  final Land land;
  NavigateToLandDetails(this.land);
}

class FilterLands extends LandEvent {
  final Map<String, dynamic> filters;
  
  FilterLands(this.filters);
}

class ApplyFilters extends LandEvent {
  final Set<LandType> selectedTypes;
  final Set<LandStatus> selectedStatuses;
  final RangeValues priceRange;
  final String searchQuery;
  final String sortBy;

  ApplyFilters({
    required this.selectedTypes,
    required this.selectedStatuses,
    required this.priceRange,
    required this.searchQuery,
    required this.sortBy,
  });

}