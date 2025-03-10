// lib/core/services/gemini_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta';
  final String _apiKey;
  
  GeminiService({required String apiKey,String modelName = 'gemini-1.5-pro',}) : _apiKey = apiKey;
  
  // Method to send a user query to Gemini and get a response
  Future<String> getInvestmentAdvice(String query) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/models/gemini-1.5-pro:generateContent?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text': '''
                  You are an investment advisor specialized in land tokenization and blockchain-based real estate investments.
                  Provide helpful, accurate, and concise information about investing in tokenized land assets.
                  Focus on explaining concepts in simple terms, highlighting benefits and risks, and guiding users in making informed decisions.
                  
                  User question: $query
                  '''
                }
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 800,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      } else {
        print('Error: ${response.statusCode}, ${response.body}');
        return 'Sorry, I encountered an error while processing your request. Please try again later.';
      }
    } catch (e) {
      print('Exception: $e');
      return 'Sorry, something went wrong. Please check your connection and try again.';
    }
  }
}