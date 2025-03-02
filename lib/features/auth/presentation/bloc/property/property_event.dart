part of 'property_bloc.dart';

abstract class PropertyEvent extends Equatable {
  const PropertyEvent();

  @override
  List<Object> get props => [];
}

class LoadProperties extends PropertyEvent {}

class SetCategory extends PropertyEvent {
  final String category;
  
  const SetCategory(this.category);
  
  @override
  List<Object> get props => [category];
}

class SetPriceRange extends PropertyEvent {
  final RangeValues range;
  
  const SetPriceRange(this.range);
  
  @override
  List<Object> get props => [range];
}

class SetReturnRange extends PropertyEvent {
  final RangeValues range;
  
  const SetReturnRange(this.range);
  
  @override
  List<Object> get props => [range];
}

class ToggleRiskLevel extends PropertyEvent {
  final String riskLevel;
  
  const ToggleRiskLevel(this.riskLevel);
  
  @override
  List<Object> get props => [riskLevel];
}

class ResetFilters extends PropertyEvent {}