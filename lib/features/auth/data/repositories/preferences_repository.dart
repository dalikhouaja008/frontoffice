import 'package:the_boost/features/auth/data/models/land_model.dart';
import 'package:the_boost/features/auth/domain/entities/user_preferences.dart';

abstract class PreferencesRepository {
  Future<UserPreferences?> getUserPreferences();
  Future<UserPreferences> saveUserPreferences(UserPreferences preferences);
  Future<List<LandType>> getAvailableLandTypes();
}