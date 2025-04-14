// lib/features/auth/presentation/bloc/lands/land_bloc.dart
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
    on<LoadLandsForUser>(_onLoadLandsForUser);
    on<LoadLandTypes>(_onLoadLandTypes);
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

  Future<void> _onLoadLandsForUser(LoadLandsForUser event, Emitter<LandState> emit) async {
    print('[${DateTime.now()}] LandBloc: 🚀 Handling LoadLandsForUser event for user ${event.userId}');
    emit(LandLoading());
    try {
      final lands = await _landService.fetchLandsForUser(event.userId, event.accessToken);
      _allLands = lands;
      print('[${DateTime.now()}] LandBloc: ✅ Loaded ${lands.length} lands for user ${event.userId}');
      emit(LandLoaded(lands: lands));
    } catch (e) {
      print('[${DateTime.now()}] LandBloc: ❌ Error loading lands for user ${event.userId}: $e');
      if (e.toString().contains('Invalid access token')) {
        emit(LandUnauthenticated());
      } else {
        emit(LandError(message: 'Failed to load lands: $e'));
      }
    }
  }

  Future<void> _onLoadLandTypes(LoadLandTypes event, Emitter<LandState> emit) async {
    print('[${DateTime.now()}] LandBloc: 🚀 Handling LoadLandTypes event');
    // Placeholder for loading land types
    // Emit a state if necessary
  }

  void _onNavigateToLandDetails(NavigateToLandDetails event, Emitter<LandState> emit) {
    print('[${DateTime.now()}] LandBloc: 🚀 Navigating to land details: ${event.land.id}');
    emit(NavigatingToLandDetails(land: event.land));
  }

  void _onApplyFilters(ApplyFilters event, Emitter<LandState> emit) {
    print('[${DateTime.now()}] LandBloc: 🚀 Applying filters: ${event.priceRange}, ${event.searchQuery}, ${event.sortBy}, ${event.landType}, ${event.validationStatus}, ${event.amenities}');
    if (_allLands.isEmpty) {
      print('[${DateTime.now()}] LandBloc: ❌ No lands loaded yet');
      emit(LandError(message: 'No lands loaded yet'));
      return;
    }

    var filteredLands = _allLands.where((land) {
      final matchesPrice = land.totalPrice >= event.priceRange.start && land.totalPrice <= event.priceRange.end;
      final matchesQuery = event.searchQuery.isEmpty ||
          land.title.toLowerCase().contains(event.searchQuery.toLowerCase());
      final matchesLandType = event.landType == null || land.landtype == event.landType;
      final matchesValidationStatus = event.validationStatus == null || land.status == event.validationStatus;
      final matchesAmenities = event.amenities.entries.every((entry) {
        if (!entry.value) return true; // If amenity is not selected, skip filter
        return land.amenities[entry.key] == true;
      });

      return matchesPrice && matchesQuery && matchesLandType && matchesValidationStatus && matchesAmenities;
    }).toList();

    if (event.sortBy == 'price_asc') {
      filteredLands.sort((a, b) => a.totalPrice.compareTo(b.totalPrice));
    } else if (event.sortBy == 'price_desc') {
      filteredLands.sort((a, b) => b.totalPrice.compareTo(a.totalPrice));
    } else if (event.sortBy == 'newest') {
      filteredLands.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    print('[${DateTime.now()}] LandBloc: ✅ Filtered ${filteredLands.length} lands');
    emit(LandLoaded(lands: filteredLands));
  }
}