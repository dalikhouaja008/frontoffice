import 'package:the_boost/features/auth/domain/entities/user_preferences.dart';

import '../../../data/repositories/preferences_repository.dart';

class GetPreferencesUseCase {
  final PreferencesRepository repository;

  GetPreferencesUseCase(this.repository);

  Future<UserPreferences?> execute() async {
    return await repository.getUserPreferences();
  }
}