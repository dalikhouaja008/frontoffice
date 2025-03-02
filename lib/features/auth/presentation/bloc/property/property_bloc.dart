import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:the_boost/features/auth/domain/entities/property.dart';
import 'package:the_boost/features/auth/domain/use_cases/investments/get_properties_usecase.dart';

part 'property_event.dart';
part 'property_state.dart';

class PropertyBloc extends Bloc<PropertyEvent, PropertyState> {
  final GetPropertiesUseCase getPropertiesUseCase;

  // Filter state
  String _selectedCategory = 'All';
  RangeValues _priceRange = const RangeValues(100, 50000);
  RangeValues _returnRange = const RangeValues(5, 20);
  List<String> _selectedRiskLevels = ['Low', 'Medium', 'Medium-High', 'High'];

  String get selectedCategory => _selectedCategory;
  RangeValues get priceRange => _priceRange;
  RangeValues get returnRange => _returnRange;
  List<String> get selectedRiskLevels => _selectedRiskLevels;

  PropertyBloc({required this.getPropertiesUseCase}) : super(PropertyInitial()) {
    on<LoadProperties>(_onLoadProperties);
    on<SetCategory>(_onSetCategory);
    on<SetPriceRange>(_onSetPriceRange);
    on<SetReturnRange>(_onSetReturnRange);
    on<ToggleRiskLevel>(_onToggleRiskLevel);
    on<ResetFilters>(_onResetFilters);
  }

  List<Property> getFilteredProperties(List<Property> properties) {
    return properties.where((property) {
      // Filter by category
      if (_selectedCategory != 'All' && property.category != _selectedCategory) {
        return false;
      }

      // Filter by price range
      if (property.minInvestment < _priceRange.start ||
          property.minInvestment > _priceRange.end) {
        return false;
      }

      // Filter by return range
      if (property.projectedReturn < _returnRange.start ||
          property.projectedReturn > _returnRange.end) {
        return false;
      }

      // Filter by risk level
      if (!_selectedRiskLevels.contains(property.riskLevel)) {
        return false;
      }

      return true;
    }).toList();
  }

  Future<void> _onLoadProperties(LoadProperties event, Emitter<PropertyState> emit) async {
    emit(PropertyLoading());

    try {
      final properties = await getPropertiesUseCase.execute();
      emit(PropertyLoaded(
        properties: properties,
        filteredProperties: getFilteredProperties(properties),
      ));
    } catch (e) {
      emit(PropertyError(message: e.toString()));
    }
  }

  void _onSetCategory(SetCategory event, Emitter<PropertyState> emit) {
    _selectedCategory = event.category;
    if (state is PropertyLoaded) {
      final currentState = state as PropertyLoaded;
      emit(PropertyLoaded(
        properties: currentState.properties,
        filteredProperties: getFilteredProperties(currentState.properties),
      ));
    }
  }

  void _onSetPriceRange(SetPriceRange event, Emitter<PropertyState> emit) {
    _priceRange = event.range;
    if (state is PropertyLoaded) {
      final currentState = state as PropertyLoaded;
      emit(PropertyLoaded(
        properties: currentState.properties,
        filteredProperties: getFilteredProperties(currentState.properties),
      ));
    }
  }

  void _onSetReturnRange(SetReturnRange event, Emitter<PropertyState> emit) {
    _returnRange = event.range;
    if (state is PropertyLoaded) {
      final currentState = state as PropertyLoaded;
      emit(PropertyLoaded(
        properties: currentState.properties,
        filteredProperties: getFilteredProperties(currentState.properties),
      ));
    }
  }

  void _onToggleRiskLevel(ToggleRiskLevel event, Emitter<PropertyState> emit) {
    if (_selectedRiskLevels.contains(event.riskLevel)) {
      _selectedRiskLevels.remove(event.riskLevel);
    } else {
      _selectedRiskLevels.add(event.riskLevel);
    }
    
    if (state is PropertyLoaded) {
      final currentState = state as PropertyLoaded;
      emit(PropertyLoaded(
        properties: currentState.properties,
        filteredProperties: getFilteredProperties(currentState.properties),
      ));
    }
  }

  void _onResetFilters(ResetFilters event, Emitter<PropertyState> emit) {
    _selectedCategory = 'All';
    _priceRange = const RangeValues(100, 50000);
    _returnRange = const RangeValues(5, 20);
    _selectedRiskLevels = ['Low', 'Medium', 'Medium-High', 'High'];
    
    if (state is PropertyLoaded) {
      final currentState = state as PropertyLoaded;
      emit(PropertyLoaded(
        properties: currentState.properties,
        filteredProperties: getFilteredProperties(currentState.properties),
      ));
    }
  }
}