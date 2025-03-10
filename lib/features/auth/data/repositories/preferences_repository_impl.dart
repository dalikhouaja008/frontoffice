import 'package:the_boost/features/auth/data/datasources/preferences_remote_data_source.dart';
import 'package:the_boost/features/auth/data/models/land_model.dart';
import 'package:the_boost/features/auth/domain/entities/user_preferences.dart';
import 'preferences_repository.dart';

class PreferencesRepositoryImpl implements PreferencesRepository {
  final PreferencesRemoteDataSource _remoteDataSource;
  
  PreferencesRepositoryImpl(this._remoteDataSource);
  
  @override
  Future<UserPreferences?> getUserPreferences() async {
    try {
      final remotePrefs = await _remoteDataSource.getUserPreferences();
      return remotePrefs;
    } catch (e) {
      print('PreferencesRepository: ❌ Error fetching preferences: $e');
      // Return default preferences if remote fetch fails
      return UserPreferences.defaultPreferences();
    }
  }
  
  @override
  Future<UserPreferences> saveUserPreferences(UserPreferences preferences) async {
    try {
      final updatedPrefs = await _remoteDataSource.updateUserPreferences(preferences);
      return updatedPrefs;
    } catch (e) {
      print('PreferencesRepository: ❌ Error saving preferences: $e');
      rethrow;
    }
  }
  
  @override
  Future<List<LandType>> getAvailableLandTypes() async {
    try {
      return await _remoteDataSource.getAvailableLandTypes();
    } catch (e) {
      print('PreferencesRepository: ❌ Error fetching land types: $e');
      // Return default land types if remote fetch fails
      return LandType.values;
    }
  }
}