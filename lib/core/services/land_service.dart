import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:the_boost/features/auth/data/models/land_model.dart';

class LandService {
  static const String _baseUrl = 'http://localhost:5000/lands';

  // Fetch all lands from the backend
  Future<List<Land>> fetchLands() async {
    try {
      print('[${DateTime.now()}] LandService: Fetching lands...');
      final response = await http.get(Uri.parse(_baseUrl));

      print('[${DateTime.now()}] LandService: Response status: ${response.statusCode}');
      print('[${DateTime.now()}] LandService: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('[${DateTime.now()}] LandService: ✅ Lands fetched successfully: $data');
        return data.map((json) => Land.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load lands: ${response.statusCode}');
      }
    } catch (e) {
      print('[${DateTime.now()}] LandService: ❌ Error fetching lands: $e');
      rethrow;
    }
  }

  // Fetch a single land by ID
  Future<Land?> fetchLandById(String id) async {
    try {
      print('[${DateTime.now()}] LandService: Fetching land by ID: $id...');
      final response = await http.get(Uri.parse('$_baseUrl/$id'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print('[${DateTime.now()}] LandService: ✅ Land fetched successfully');
        return Land.fromJson(data);
      } else if (response.statusCode == 404) {
        print('[${DateTime.now()}] LandService: ⚠️ Land not found');
        return null; // Land not found
      } else {
        throw Exception('Failed to load land by ID: ${response.statusCode}');
      }
    } catch (e) {
      print('[${DateTime.now()}] LandService: ❌ Error fetching land by ID: $e');
      rethrow;
    }
  }
}