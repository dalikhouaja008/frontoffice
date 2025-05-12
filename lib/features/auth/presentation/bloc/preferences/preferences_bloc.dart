import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:the_boost/features/auth/data/models/land_model.dart';
import 'package:the_boost/features/auth/domain/entities/user_preferences.dart';
import 'package:the_boost/features/auth/domain/use_cases/preferences/get_preferences_usecase.dart';
import 'package:the_boost/features/auth/domain/use_cases/preferences/save_preferences_usecase.dart';
import 'package:the_boost/features/auth/domain/use_cases/preferences/get_land_types_usecase.dart';

part 'preferences_event.dart';
part 'preferences_state.dart';

class PreferencesBloc extends Bloc<PreferencesEvent, PreferencesState> {
  final GetPreferencesUseCase getPreferencesUseCase;
  final SavePreferencesUseCase savePreferencesUseCase;
  final GetLandTypesUseCase getLandTypesUseCase;

  PreferencesBloc({
    required this.getPreferencesUseCase,
    required this.savePreferencesUseCase,
    required this.getLandTypesUseCase,
  }) : super(PreferencesInitial()) {
    on<LoadPreferences>(_onLoadPreferences);
    on<SavePreferences>(_onSavePreferences);
    on<LoadLandTypes>(_onLoadLandTypes); // Added handler for LoadLandTypes
  }

  Future<void> _onLoadPreferences(
    LoadPreferences event,
    Emitter<PreferencesState> emit,
  ) async {
    print('[${DateTime.now()}] PreferencesBloc: 🔄 Loading preferences');
    
    emit(PreferencesLoading());
    
    try {
      final preferences = await getPreferencesUseCase.execute();
      
      if (preferences != null) {
        print('[${DateTime.now()}] PreferencesBloc: ✅ Preferences loaded successfully');
        emit(PreferencesLoaded(preferences: preferences));
      } else {
        print('[${DateTime.now()}] PreferencesBloc: ℹ️ No preferences found, using defaults');
        emit(PreferencesLoaded(preferences: UserPreferences.defaultPreferences()));
      }
    } catch (e) {
      print('[${DateTime.now()}] PreferencesBloc: ❌ Error loading preferences: $e');
      emit(PreferencesError(message: 'Failed to load preferences: $e'));
    }
  }

  Future<void> _onSavePreferences(
    SavePreferences event,
    Emitter<PreferencesState> emit,
  ) async {
    print('[${DateTime.now()}] PreferencesBloc: 🔄 Saving preferences');
    
    emit(PreferencesSaving());
    
    try {
      final updatedPreferences = await savePreferencesUseCase.execute(event.preferences);
      
      print('[${DateTime.now()}] PreferencesBloc: ✅ Preferences saved successfully');
      emit(PreferencesSaved(preferences: updatedPreferences));
    } catch (e) {
      print('[${DateTime.now()}] PreferencesBloc: ❌ Error saving preferences: $e');
      emit(PreferencesError(message: 'Failed to save preferences: $e'));
    }
  }

  // New handler for LoadLandTypes event
  Future<void> _onLoadLandTypes(
    LoadLandTypes event,
    Emitter<PreferencesState> emit,
  ) async {
    print('[${DateTime.now()}] PreferencesBloc: 🔄 Loading land types');
    
    try {
      final landTypes = await getLandTypesUseCase.execute();
      
      print('[${DateTime.now()}] PreferencesBloc: ✅ Land types loaded successfully');
      emit(LandTypesLoaded(landTypes: landTypes));
    } catch (e) {
      print('[${DateTime.now()}] PreferencesBloc: ❌ Error loading land types: $e');
      emit(PreferencesError(message: 'Failed to load land types: $e'));
    }
  }
}