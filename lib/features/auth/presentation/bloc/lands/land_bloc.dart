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
    print('[${DateTime.now()}] Loading lands...');
    _allLands = await _landRepository.fetchLands();
    
    // Logs pour le débogage
    print('[${DateTime.now()}] Loaded ${_allLands.length} lands');
    print('Types available: ${_allLands.map((l) => l.type).toSet()}');
    print('Statuses available: ${_allLands.map((l) => l.status).toSet()}');
    
    // Imprimez quelques détails sur chaque terrain
    for (var land in _allLands) {
      print('Land: ${land.title}, Type: ${land.type}, Status: ${land.status}');
    }
    
    emit(LandLoaded(_allLands));
  } catch (e, stackTrace) {
    print('[${DateTime.now()}] Error loading lands: $e');
    print('Stack trace: $stackTrace');
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
    print('All lands count: ${_allLands.length}');
    print('Selected types: ${event.selectedTypes}');
    print('Selected statuses: ${event.selectedStatuses}');

    // Si aucun filtre n'est sélectionné, afficher tous les terrains
    if (event.selectedTypes.isEmpty && event.selectedStatuses.isEmpty) {
      print('[${DateTime.now()}] No filters selected, showing all lands');
      emit(LandLoaded(_allLands));
      return;
    }

    // Imprimez les types de tous les terrains pour le débogage
    print('Available types in lands: ${_allLands.map((l) => l.type).toSet()}');
    print('Available statuses in lands: ${_allLands.map((l) => l.status).toSet()}');

    var filteredLands = _allLands.where((land) {
      print('Checking land: ${land.title}, Type: ${land.type}, Status: ${land.status}');

      // Vérifie le type seulement si des types sont sélectionnés
      bool matchesType = event.selectedTypes.isEmpty || 
                        event.selectedTypes.contains(land.type);
      
      // Vérifie le statut seulement si des statuts sont sélectionnés
      bool matchesStatus = event.selectedStatuses.isEmpty || 
                          event.selectedStatuses.contains(land.status);

      // Vérifie la recherche si une requête est présente
      bool matchesSearch = event.searchQuery.isEmpty ||
          land.title.toLowerCase().contains(event.searchQuery.toLowerCase()) ||
          land.location.toLowerCase().contains(event.searchQuery.toLowerCase()) ||
          land.description.toLowerCase().contains(event.searchQuery.toLowerCase());

      print('matchesType: $matchesType, matchesStatus: $matchesStatus, matchesSearch: $matchesSearch');

      return matchesType && matchesStatus && matchesSearch;
    }).toList();

    // Tri des résultats
    switch (event.sortBy) {
      case 'newest':
        filteredLands.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'price_asc':
        filteredLands.sort((a, b) => 0); // À implémenter quand le prix sera ajouté
        break;
      case 'price_desc':
        filteredLands.sort((a, b) => 0); // À implémenter quand le prix sera ajouté
        break;
    }

    print('[${DateTime.now()}] Filtered lands count: ${filteredLands.length}');
    emit(LandLoaded(filteredLands));
  } catch (e, stackTrace) {
    print('[${DateTime.now()}] Error applying filters: $e');
    print('Stack trace: $stackTrace');
    emit(LandError('Error applying filters: $e'));
  }
}
}