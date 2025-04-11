// lib/core/services/land_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:the_boost/features/auth/data/models/land_model.dart';

class LandService {
  static const String _baseUrl = 'http://localhost:5000/lands'; // Adjust to your backend URL

  Future<List<Land>> fetchLands() async {
    print('[${DateTime.now()}] LandService: 🚀 Fetching lands from $_baseUrl');
    try {
      final response = await http.get(Uri.parse(_baseUrl));
      print('[${DateTime.now()}] LandService: 📡 Response status: ${response.statusCode}');
      print('[${DateTime.now()}] LandService: 📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        final lands = data.map((json) => Land.fromJson(json)).toList();
        print('[${DateTime.now()}] LandService: ✅ Successfully fetched ${lands.length} lands');
        return lands;
      }
      throw Exception('Failed to load lands: ${response.statusCode}');
    } catch (e) {
      print('[${DateTime.now()}] LandService: ❌ Error fetching lands: $e');
      rethrow;
    }
  }

  Future<Land?> fetchLandById(String id) async {
    print('[${DateTime.now()}] LandService: 🚀 Fetching land with ID: $id');
    try {
      final response = await http.get(Uri.parse('$_baseUrl/$id'));
      print('[${DateTime.now()}] LandService: 📡 Response status: ${response.statusCode}');
      print('[${DateTime.now()}] LandService: 📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final land = Land.fromJson(jsonDecode(response.body));
        print('[${DateTime.now()}] LandService: ✅ Successfully fetched land: ${land.id}');
        return land;
      } else if (response.statusCode == 404) {
        print('[${DateTime.now()}] LandService: ℹ️ Land with ID $id not found');
        return null;
      }
      throw Exception('Failed to load land: ${response.statusCode}');
    } catch (e) {
      print('[${DateTime.now()}] LandService: ❌ Error fetching land by ID: $e');
      rethrow;
    }
  }
}