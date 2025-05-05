import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:the_boost/core/di/dependency_injection.dart';
import 'package:the_boost/core/services/session_service.dart';
import 'package:the_boost/features/auth/data/models/land_model.dart';

class LandService {
  // Mise à jour de l'URL pour pointer vers l'endpoint catalogue
  static const String _baseUrl = 'http://localhost:2000/lands';
  static const String _catalogueUrl = 'http://localhost:2000/lands/catalogue';
  final SessionService _sessionService = getIt<SessionService>();

Future<List<Land>> fetchLands() async {
  try {

    print('LandService: 🚀 Fetching lands from $_catalogueUrl');
    
    final sessionData = await _sessionService.getSession();
    if (sessionData == null || sessionData.accessToken.isEmpty) {
      throw Exception('No authentication token available');
    }

    final token = sessionData.accessToken;
    final response = await http.get(
      Uri.parse(_catalogueUrl),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
    );
    
    // Log du statut de la réponse
    print('LandService: 📡 Response status: ${response.statusCode}');
    
    // Afficher le corps complet de la réponse
    print('========== BEGINNING OF FULL JSON RESPONSE ==========');
    print(response.body);
    print('========== END OF FULL JSON RESPONSE ==========');
    
    if (response.statusCode == 200) {
      final decodedData = jsonDecode(response.body);
      
      // Log de la structure des données
      print('LandService: 🔍 JSON structure type: ${decodedData.runtimeType}');
      
      if (decodedData is! List<dynamic>) {
        throw Exception('Expected a list of lands but got ${decodedData.runtimeType}');
      }
      
      // Affiche les clés du premier élément pour débogage
      if (decodedData.isNotEmpty && decodedData.first is Map) {
        print('LandService: 🔑 First item keys: ${(decodedData.first as Map).keys.toList()}');
      }
      
      final lands = decodedData.map((json) {
        // Récupérer les données enrichies du backend
        final Map<String, dynamic> landJson = json as Map<String, dynamic>;
        
        // Traitement spécifique des amenities pour débogage
        if (landJson['amenities'] != null) {
          print('LandService: 🔧 Amenities type: ${landJson['amenities'].runtimeType}');
          print(' LandService: 🔧 Amenities value: ${landJson['amenities']}');
        } else {
          print('LandService: ⚠️ No amenities found for land ID: ${landJson['_id']}');
        }
        
        // Vérifier si les URLs d'images et documents sont disponibles
        if (landJson['imageInfos'] != null && landJson['imageInfos'] is List) {
          landJson['imageUrls'] = (landJson['imageInfos'] as List).map((info) => info['url'].toString()).toList();
        }
        
        if (landJson['documentInfos'] != null && landJson['documentInfos'] is List) {
          landJson['documentUrls'] = (landJson['documentInfos'] as List).map((info) => info['url'].toString()).toList();
        }
        
        // S'assurer que le coverImageUrl est défini
        if (landJson['coverImageUrl'] == null && landJson['imageUrls'] != null && (landJson['imageUrls'] as List).isNotEmpty) {
          landJson['coverImageUrl'] = landJson['imageUrls'][0];
        }
        
        return Land.fromJson(landJson);
      }).toList();
      
      print(' LandService: ✅ Successfully fetched ${lands.length} lands');
      
      // Log détaillé pour le premier terrain (uniquement à des fins de débogage)
      if (lands.isNotEmpty) {
        final firstLand = lands.first;
        print(' LandService: 📊 Sample land - ID: ${firstLand.id}, Title: ${firstLand.title}');
        print(' LandService: 📊 Sample land - Amenities: ${firstLand.amenities}');
      }
      
      return lands;
    }
    throw Exception('Failed to load lands: ${response.statusCode}');
  } catch (e) {
    print(' LandService: ❌ Error fetching lands: $e');
    print('LandService: ❌ Stack trace: ${StackTrace.current}');
    rethrow;
  }
}

  // New method to fetch available land types
Future<List<String>> getLandTypes() async {
  print('[${DateTime.now()}] LandService: 🚀 Fetching available land types');
  try {
    final sessionData = await _sessionService.getSession();
    if (sessionData == null || sessionData.accessToken.isEmpty) {
      throw Exception('No authentication token available');
    }

    final token = sessionData.accessToken;
    final response = await http.get(
      Uri.parse('http://localhost:2000/lands/types'), // 📌 Assuming you have an endpoint /lands/types
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
    );

    print('[${DateTime.now()}] LandService: 📡 Response status (types): ${response.statusCode}');

    if (response.body.length > 500) {
      print('[${DateTime.now()}] LandService: 📡 Response body (truncated): ${response.body.substring(0, 500)}...');
    } else {
      print('[${DateTime.now()}] LandService: 📡 Response body: ${response.body}');
    }

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      final List<String> landTypes = data.map((type) => type.toString()).toList();
      print('[${DateTime.now()}] LandService: ✅ Successfully fetched ${landTypes.length} land types');
      return landTypes;
    }

    throw Exception('Failed to load land types: ${response.statusCode}');
  } catch (e) {
    print('[${DateTime.now()}] LandService: ❌ Error fetching land types: $e');
    rethrow;
  }
}


  Future<Land?> fetchLandById(String id) async {
    print('[${DateTime.now()}] LandService: 🚀 Fetching land with ID: $id');
    try {
      final sessionData = await _sessionService.getSession();
      if (sessionData == null || sessionData.accessToken.isEmpty) {
        throw Exception('No authentication token available');
      }

      final token = sessionData.accessToken;
      final response = await http.get(
        Uri.parse('$_baseUrl/$id'),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      );
      print('[${DateTime.now()}] LandService: 📡 Response status: ${response.statusCode}');
      
      if (response.body.length > 500) {
        print('[${DateTime.now()}] LandService: 📡 Response body (truncated): ${response.body.substring(0, 500)}...');
      } else {
        print('[${DateTime.now()}] LandService: 📡 Response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> landJson = jsonDecode(response.body);
        
        // Traitement similaire pour les URLs d'images et documents
        if (landJson['imageInfos'] != null && landJson['imageInfos'] is List) {
          landJson['imageUrls'] = (landJson['imageInfos'] as List).map((info) => info['url'].toString()).toList();
        }
        
        if (landJson['documentInfos'] != null && landJson['documentInfos'] is List) {
          landJson['documentUrls'] = (landJson['documentInfos'] as List).map((info) => info['url'].toString()).toList();
        }
        
        // S'assurer que le coverImageUrl est défini
        if (landJson['coverImageUrl'] == null && landJson['imageUrls'] != null && (landJson['imageUrls'] as List).isNotEmpty) {
          landJson['coverImageUrl'] = landJson['imageUrls'][0];
        }
        
        return Land.fromJson(landJson);
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
  
  // Méthode pour récupérer les terrains d'un propriétaire spécifique
  Future<List<Land>> fetchLandsByOwner(String ownerId) async {
    print('[${DateTime.now()}] LandService: 🚀 Fetching lands for owner: $ownerId');
    try {
      final allLands = await fetchLands();
      final ownerLands = allLands.where((land) => land.ownerId == ownerId).toList();
      print('[${DateTime.now()}] LandService: ✅ Found ${ownerLands.length} lands for owner $ownerId');
      return ownerLands;
    } catch (e) {
      print('[${DateTime.now()}] LandService: ❌ Error fetching lands for owner: $e');
      rethrow;
    }
  }
  
  // Méthode pour filtrer les terrains par gamme de prix
  Future<List<Land>> filterLandsByPrice(double minPrice, double maxPrice) async {
    print('[${DateTime.now()}] LandService: 🚀 Filtering lands by price range: $minPrice - $maxPrice');
    try {
      final allLands = await fetchLands();
      final filteredLands = allLands.where((land) {
        final landPrice = land.priceland != null ? double.tryParse(land.priceland!) ?? 0.0 : 0.0;
        return landPrice >= minPrice && landPrice <= maxPrice;
      }).toList();
      
      print('[${DateTime.now()}] LandService: ✅ Found ${filteredLands.length} lands in price range');
      return filteredLands;
    } catch (e) {
      print('[${DateTime.now()}] LandService: ❌ Error filtering lands by price: $e');
      rethrow;
    }
  }
}