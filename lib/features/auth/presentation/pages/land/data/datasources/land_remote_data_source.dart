import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:the_boost/core/error/exceptions.dart';
import 'package:the_boost/features/auth/presentation/pages/land/data/models/land_model.dart';

abstract class LandRemoteDataSource {
  Future<List<LandModel>> getMyLands();
}

class LandRemoteDataSourceImpl implements LandRemoteDataSource {
  final http.Client client;
  final String baseUrl;

  LandRemoteDataSourceImpl({
    required this.client,
    this.baseUrl = 'http://localhost:5000',
  });

  @override
  Future<List<LandModel>> getMyLands() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/lands/my-lands'),
        headers: {
          'Content-Type': 'application/json',
          // Add your authentication headers here if needed
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          final List<dynamic> landsJson = jsonResponse['data'];
          return landsJson.map((json) => LandModel.fromJson(json)).toList();
        } else {
          throw ServerException(
              message: jsonResponse['message'] ?? 'Unknown error');
        }
      } else {
        throw ServerException(
          message: 'Failed to load lands: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw ServerException(
        message: 'Failed to load lands: ${e.toString()}',
      );
    }
  }
}
