import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:the_boost/core/di/dependency_injection.dart';
import 'package:the_boost/core/services/session_service.dart';
import 'package:the_boost/features/auth/data/models/land_model.dart';

class LandService {
  static const String _baseUrl = 'http://localhost:5000/lands';
  final SessionService _sessionService = getIt<SessionService>();

  Future<List<Land>> fetchLands() async {
  print('[${DateTime.now()}] LandService: 🚀 Fetching lands from $_baseUrl');
  try {
    // Retrieve session data
    final sessionData = await _sessionService.getSession();
    if (sessionData == null || sessionData.accessToken.isEmpty) {
      throw Exception('No authentication token available');
    }

    final token = sessionData.accessToken;

    final response = await http.get(
      Uri.parse(_baseUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    print('[${DateTime.now()}] LandService: 📡 Response status: ${response.statusCode}');
    print('[${DateTime.now()}] LandService: 📡 Response body: ${response.body}');

    if (response.statusCode == 200) {
      // Parse the response body
      final decodedData = jsonDecode(response.body);
      if (decodedData == null) {
        throw Exception('Response body is null after decoding');
      }
      if (decodedData is! List<dynamic>) {
        throw Exception('Expected a list of lands, but got: ${decodedData.runtimeType}');
      }

      // Map the data to Land objects with error handling
      final lands = <Land>[];
      for (var json in decodedData) {
        try {
          final land = Land.fromJson(json as Map<String, dynamic>);
          lands.add(land);
        } catch (e) {
          print('[${DateTime.now()}] LandService: ⚠️ Error parsing land JSON: $json');
          print('[${DateTime.now()}] LandService: ⚠️ Error details: $e');
          continue; // Skip this land and continue with the next one
        }
      }

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
      // Retrieve session data
      final sessionData = await _sessionService.getSession();
      if (sessionData == null || sessionData.accessToken.isEmpty) {
        throw Exception('No authentication token available');
      }

      final token = sessionData.accessToken;

      final response = await http.get(
        Uri.parse('$_baseUrl/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
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