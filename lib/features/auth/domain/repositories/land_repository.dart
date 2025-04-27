import 'package:the_boost/features/auth/data/models/land_model.dart';

abstract class LandRepository {
  Future<List<Land>> fetchLands();
  Future<Land?> fetchLandById(String id);
}