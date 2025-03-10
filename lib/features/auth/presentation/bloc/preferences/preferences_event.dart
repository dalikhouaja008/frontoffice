part of 'preferences_bloc.dart';

abstract class PreferencesEvent extends Equatable {
  const PreferencesEvent();

  @override
  List<Object> get props => [];
}

class LoadPreferences extends PreferencesEvent {}

class SavePreferences extends PreferencesEvent {
  final UserPreferences preferences;

  const SavePreferences(this.preferences);

  @override
  List<Object> get props => [preferences];
}

class LoadLandTypes extends PreferencesEvent {}