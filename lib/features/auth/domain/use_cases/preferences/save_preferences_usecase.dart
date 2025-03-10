import 'package:the_boost/features/auth/domain/entities/user_preferences.dart';

import '../../../data/repositories/preferences_repository.dart';

class SavePreferencesUseCase {
  final PreferencesRepository repository;

  SavePreferencesUseCase(this.repository);

  Future<UserPreferences> execute(UserPreferences preferences) async {
    return await repository.saveUserPreferences(preferences);
  }
}