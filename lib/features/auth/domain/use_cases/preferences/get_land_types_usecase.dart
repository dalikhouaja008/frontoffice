import 'package:the_boost/features/auth/data/models/land_model.dart';
import '../../../data/repositories/preferences_repository.dart';

class GetLandTypesUseCase {
  final PreferencesRepository repository;

  GetLandTypesUseCase(this.repository);
  
  // Implement the execute method
  Future<List<String>> execute() async {
    return await repository.getAvailableLandTypes();
  }
}