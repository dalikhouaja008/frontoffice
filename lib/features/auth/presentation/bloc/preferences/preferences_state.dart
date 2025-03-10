part of 'preferences_bloc.dart';

abstract class PreferencesState extends Equatable {
  const PreferencesState();
  
  @override
  List<Object?> get props => [];
}

class PreferencesInitial extends PreferencesState {}

class PreferencesLoading extends PreferencesState {}

class PreferencesSaving extends PreferencesState {}

class PreferencesLoaded extends PreferencesState {
  final UserPreferences preferences;
  final List<LandType>? availableLandTypes;

  const PreferencesLoaded({
    required this.preferences,
    this.availableLandTypes,
  });

  PreferencesLoaded copyWith({
    UserPreferences? preferences,
    List<LandType>? availableLandTypes,
  }) {
    return PreferencesLoaded(
      preferences: preferences ?? this.preferences,
      availableLandTypes: availableLandTypes ?? this.availableLandTypes,
    );
  }

  @override
  List<Object?> get props => [preferences, availableLandTypes];
}

class PreferencesSaved extends PreferencesState {
  final UserPreferences preferences;

  const PreferencesSaved({required this.preferences});

  @override
  List<Object> get props => [preferences];
}

class LandTypesLoaded extends PreferencesState {
  final List<LandType> landTypes;

  const LandTypesLoaded({required this.landTypes});

  @override
  List<Object> get props => [landTypes];
}

class PreferencesError extends PreferencesState {
  final String message;

  const PreferencesError({required this.message});

  @override
  List<Object> get props => [message];
}