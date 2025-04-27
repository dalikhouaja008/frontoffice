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

  const PreferencesLoaded({
    required this.preferences,
  });

  PreferencesLoaded copyWith({
    UserPreferences? preferences,
  }) {
    return PreferencesLoaded(
      preferences: preferences ?? this.preferences,
    );
  }

  @override
  List<Object?> get props => [preferences];
}

class PreferencesSaved extends PreferencesState {
  final UserPreferences preferences;

  const PreferencesSaved({required this.preferences});

  @override
  List<Object> get props => [preferences];
}
class PreferencesError extends PreferencesState {
  final String message;

  const PreferencesError({required this.message});

  @override
  List<Object> get props => [message];
}