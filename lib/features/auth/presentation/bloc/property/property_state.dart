part of 'property_bloc.dart';

abstract class PropertyState extends Equatable {
  const PropertyState();
  
  @override
  List<Object> get props => [];
}

class PropertyInitial extends PropertyState {}

class PropertyLoading extends PropertyState {}

class PropertyLoaded extends PropertyState {
  final List<Property> properties;
  final List<Property> filteredProperties;
  
  const PropertyLoaded({
    required this.properties,
    required this.filteredProperties,
  });
  
  @override
  List<Object> get props => [properties, filteredProperties];
}

class PropertyError extends PropertyState {
  final String message;
  
  const PropertyError({required this.message});
  
  @override
  List<Object> get props => [message];
}