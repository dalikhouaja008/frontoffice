import 'package:the_boost/core/services/land_service.dart';
import 'package:the_boost/features/auth/data/models/land_model.dart';
import 'package:the_boost/features/auth/domain/repositories/land_repository.dart';

class LandRepositoryImpl implements LandRepository {
  final LandService _landService;

  LandRepositoryImpl(this._landService);

  @override
  Future<List<Land>> fetchLands() async {
  try {
    print('[${DateTime.now()}] LandRepositoryImpl: Fetching lands...');
    final lands = await _landService.fetchLands();
    print('[${DateTime.now()}] LandRepositoryImpl: ✅ Lands fetched successfully: $lands');
    return lands;
  } catch (e) {
    print('[${DateTime.now()}] LandRepositoryImpl: ❌ Error fetching lands: $e');
    throw Exception('Error fetching lands: $e');
  }
}

  @override
  Future<Land?> fetchLandById(String id) async {
    try {
      return await _landService.fetchLandById(id);
    } catch (e) {
      print('[${DateTime.now()}] LandRepositoryImpl: ❌ Error fetching land by ID: $e');
      rethrow;
    }
  }
}