// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_boost/core/di/dependency_injection.dart';
import 'package:the_boost/core/services/land_service.dart';
import 'package:the_boost/features/auth/data/models/land_model.dart';

part 'land_event.dart';
part 'land_state.dart';

class LandBloc extends Bloc<LandEvent, LandState> {
  final LandService _landService;
  List<Land> _allLands = [];

  LandBloc() : _landService = getIt<LandService>(), super(LandInitial()) {
    on<LoadLands>(_onLoadLands);
    on<NavigateToLandDetails>(_onNavigateToLandDetails);
    on<ApplyFilters>(_onApplyFilters);
  }

  Future<void> _onLoadLands(LoadLands event, Emitter<LandState> emit) async {
    print('[${DateTime.now()}] LandBloc: 🚀 Handling LoadLands event');
    emit(LandLoading());
    try {
      final lands = await _landService.fetchLands();
      _allLands = lands;
      print('[${DateTime.now()}] LandBloc: ✅ Loaded ${lands.length} lands');
      emit(LandLoaded(lands: lands));
    } catch (e) {
      print('[${DateTime.now()}] LandBloc: ❌ Error loading lands: $e');
      emit(LandError(message: 'Failed to load lands: $e'));
    }
  }

  void _onNavigateToLandDetails(NavigateToLandDetails event, Emitter<LandState> emit) {
    print('[${DateTime.now()}] LandBloc: 🚀 Navigating to land details: ${event.land.id}');
    emit(NavigatingToLandDetails(land: event.land));
  }

  void _onApplyFilters(ApplyFilters event, Emitter<LandState> emit) {
    print('[${DateTime.now()}] LandBloc: 🚀 Applying filters: ${event.priceRange}, ${event.searchQuery}, ${event.sortBy}, ${event.landType}, ${event.validationStatus}, ${event.availability}, ${event.amenities}');
    if (_allLands.isEmpty) {
      print('[${DateTime.now()}] LandBloc: ❌ No lands loaded yet, attempting reload');
      emit(LandError(message: 'No lands loaded yet. Please retry.'));
      add(LoadLands());
      return;
    }

    var filteredLands = _allLands.where((land) {
      final price = land.priceland != null ? double.tryParse(land.priceland!) ?? 0.0 : 0.0;
      final matchesPrice = price >= event.priceRange.start && price <= event.priceRange.end;
      final matchesQuery = event.searchQuery.isEmpty || land.title.toLowerCase().contains(event.searchQuery.toLowerCase());
      final matchesLandType = event.landType == null || (land.landtype?.name == event.landType);
      final matchesValidationStatus = event.validationStatus == null || land.status == event.validationStatus;
      final matchesAvailability = event.availability == null || land.availability == event.availability;

      final amenities = event.amenities;
      final matchesAmenities = amenities == null || amenities.entries.every((entry) {
        if (entry.value) return land.amenities?[entry.key] == true;
        return true;
      });

      return matchesPrice && matchesQuery && matchesLandType && matchesValidationStatus && matchesAvailability && matchesAmenities;
    }).toList();

    if (event.sortBy == 'price_asc') 
    filteredLands.sort((a, b) => 
      (double.tryParse(a.priceland ?? '0') ?? 0.0)
      .compareTo(double.tryParse(b.priceland ?? '0') ?? 0.0));
  else if (event.sortBy == 'price_desc') 
    filteredLands.sort((a, b) => 
      (double.tryParse(b.priceland ?? '0') ?? 0.0)
      .compareTo(double.tryParse(a.priceland ?? '0') ?? 0.0));
    else if (event.sortBy == 'title_asc') filteredLands.sort((a, b) => a.title.compareTo(b.title));
    else if (event.sortBy == 'title_desc') filteredLands.sort((a, b) => b.title.compareTo(a.title));
    else if (event.sortBy == 'newest') filteredLands.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    print('[${DateTime.now()}] LandBloc: ✅ Filtered ${filteredLands.length} lands');
    emit(LandLoaded(lands: filteredLands));
  }

  // Placeholder for TTS methods (implement if needed)
  void speak(String text) {}
  void stopSpeaking() {}
}