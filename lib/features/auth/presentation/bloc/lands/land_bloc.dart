import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_boost/features/auth/data/models/land_model.dart';
import 'package:the_boost/features/auth/domain/repositories/land_repository.dart';

part 'land_event.dart';
part 'land_state.dart';

class LandBloc extends Bloc<LandEvent, LandState> {
  final LandRepository _landRepository;

  List<Land> _allLands = [];

  LandBloc(this._landRepository) : super(LandInitial()) {
    on<LoadLands>(_onLoadLands);
    on<LoadLandById>(_onLoadLandById);
    on<NavigateToLandDetails>(_onNavigateToLandDetails);
    on<ApplyFilters>(_onApplyFilters);
  }

  Future<void> _onLoadLands(LoadLands event, Emitter<LandState> emit) async {
    emit(LandLoading());
    try {
      print('[${DateTime.now()}] LandBloc: Loading lands...');
      final lands = await _landRepository.fetchLands();
      print('[${DateTime.now()}] LandBloc: ✅ Lands loaded successfully: $lands');
      emit(LandLoaded(lands));
    } catch (e) {
      print('[${DateTime.now()}] LandBloc: ❌ Error loading lands: $e');
      emit(LandError('Failed to load lands: $e'));
    }
  }

  Future<void> _onLoadLandById(LoadLandById event, Emitter<LandState> emit) async {
    emit(LandLoading());
    try {
      print('[${DateTime.now()}] LandBloc: Loading land by ID: ${event.landId}...');
      final land = await _landRepository.fetchLandById(event.landId);
      if (land != null) {
        print('[${DateTime.now()}] LandBloc: ✅ Land loaded successfully: $land');
        emit(LandDetailsLoaded(land));
      } else {
        print('[${DateTime.now()}] LandBloc: ⚠️ Land not found');
        emit(LandError('Land not found'));
      }
    } catch (e) {
      print('[${DateTime.now()}] LandBloc: ❌ Error loading land by ID: $e');
      emit(LandError('Failed to load land: $e'));
    }
  }

  void _onNavigateToLandDetails(
    NavigateToLandDetails event,
    Emitter<LandState> emit,
  ) {
    emit(NavigatingToLandDetails(event.land));
  }


  void _onFilterLands(FilterLands event, Emitter<LandState> emit) {
    try {
      final filteredLands = _allLands.where((land) {
        // Type filter
        if (event.filters['types'].isNotEmpty &&
            !event.filters['types'].contains(land.type)) {
          return false;
        }

        // Status filter
        if (event.filters['statuses'].isNotEmpty &&
            !event.filters['statuses'].contains(land.status)) {
          return false;
        }

        // Price filter
        if (land.price < event.filters['minPrice'] ||
            land.price > event.filters['maxPrice']) {
          return false;
        }

        // Search query
        if (event.filters['searchQuery'].isNotEmpty) {
          final query = event.filters['searchQuery'].toLowerCase();
          return land.title.toLowerCase().contains(query) ||
              land.location.toLowerCase().contains(query) ||
              (land.description?.toLowerCase().contains(query) ?? false);
        }

        return true;
      }).toList();

      // Sort lands
      switch (event.filters['sortBy']) {
        case 'price_asc':
          filteredLands.sort((a, b) => a.price.compareTo(b.price));
          break;
        case 'price_desc':
          filteredLands.sort((a, b) => b.price.compareTo(a.price));
          break;
        case 'newest':
        default:
          filteredLands.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          break;
      }

      emit(LandLoaded(filteredLands));
    } catch (e) {
      emit(LandError(e.toString()));
    }
  }

   void _onApplyFilters(ApplyFilters event, Emitter<LandState> emit) {
    try {
      print('[${DateTime.now()}] Applying filters in bloc');
      if (_allLands.isEmpty) {
        print('[${DateTime.now()}] No lands loaded yet, loading lands first');
        add(LoadLands());
        return;
      }

      final filteredLands = _allLands.where((land) {
        // Filter by type
        if (event.selectedTypes.isNotEmpty &&
            !event.selectedTypes.contains(land.type)) {
          return false;
        }

        // Filter by status
        if (event.selectedStatuses.isNotEmpty &&
            !event.selectedStatuses.contains(land.status)) {
          return false;
        }

        // Filter by price
        if (land.price < event.priceRange.start ||
            land.price > event.priceRange.end) {
          return false;
        }

        // Filter by search query
        if (event.searchQuery.isNotEmpty) {
          final query = event.searchQuery.toLowerCase();
          return land.title.toLowerCase().contains(query) ||
              land.location.toLowerCase().contains(query) ||
              (land.description?.toLowerCase().contains(query) ?? false);
        }

        return true;
      }).toList();

      // Sort the results
      switch (event.sortBy) {
        case 'price_asc':
          filteredLands.sort((a, b) => a.price.compareTo(b.price));
          break;
        case 'price_desc':
          filteredLands.sort((a, b) => b.price.compareTo(a.price));
          break;
        case 'newest':
        default:
          filteredLands.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          break;
      }

      print('[${DateTime.now()}] Filtered lands: ${filteredLands.length} lands');
      emit(LandLoaded(filteredLands));
    } catch (e) {
      print('[${DateTime.now()}] Error applying filters: $e');
      emit(LandError('Error applying filters: $e'));
    }
  }


}