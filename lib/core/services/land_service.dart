// lib/core/services/land_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:the_boost/features/auth/data/models/land_model.dart';
import 'dart:io';

class LandService {
  static const String _baseUrl = 'http://localhost:5000/lands';

  Future<List<Land>> fetchLands() async {
  print('[${DateTime.now()}] LandService: 🚀 Using static lands for testing');
  return [
    Land(
      id: "67cc49c20984a92a5c99917e",
      title: "Terrain à Tunis",
      description: "Beau terrain constructible",
      location: "Tunis, Lac 2",
      surface: 1200.5,
      totalTokens: 1000,
      pricePerToken: "0.5",
      priceland: "500.0",
      ownerId: "123456",
      ownerAddress: "0x1234567890abcdef1234567890abcdef12345678",
      latitude: 36.8065,
      longitude: 10.1815,
      status: LandValidationStatus.VALIDATED,
      landtype: LandType.RESIDENTIAL,
      ipfsCIDs: ["QmX1"],
      imageCIDs: ['assets/1.jpg'],
      blockchainTxHash: "0xabc123",
      blockchainLandId: "67cc49c20984a92a5c99917e",
      validations: [
        ValidationEntry(
          validator: "validator1",
          validatorType: ValidatorType.NOTAIRE,
          timestamp: 1696118400, // 2023-10-01
          isValidated: true,
          cidComments: "QmZ1",
        ),
      ],
      amenities: {
        "electricity": true,
        "water": true,
        "roadAccess": true,
        "buildingPermit": false,
        "gas": false,
        "sewer": false,
        "internet": false,
        "publicTransport": true,
        "pavedRoad": true,
        "boundaryMarkers": false,
        "drainage": false,
        "floodRisk": false,
        "rainwaterCollection": false,
        "fenced": false,
        "trees": false,
        "wellWater": false,
        "flatTerrain": true,
      },
      createdAt: DateTime.parse("2025-03-08T13:44:34.779Z"),
      updatedAt: DateTime.parse("2025-03-08T13:44:34.779Z"),
    ),
    Land(
      id: "67cc4a5b0984a92a5c999182",
      title: "Terrain à Djerba",
      description: "Beau terrain pour agriculture",
      location: "Djerba",
      surface: 5000.0,
      totalTokens: 2000,
      pricePerToken: "0.3",
      priceland: "600.0",
      ownerId: "112233",
      ownerAddress: "0xabcdef1234567890abcdef1234567890abcdef12",
      latitude: 33.8076,
      longitude: 10.8451,
      status: LandValidationStatus.PENDING_VALIDATION,
      landtype: LandType.AGRICULTURAL,
      ipfsCIDs: ["QmX2"],
      imageCIDs: ['assets/2.jpg'],
      blockchainTxHash: "0xdef456",
      blockchainLandId: "67cc4a5b0984a92a5c999182",
      validations: [
        ValidationEntry(
          validator: "validator2",
          validatorType: ValidatorType.GEOMETRE,
          timestamp: 1696204800, // 2023-10-02
          isValidated: false,
          cidComments: "QmZ2",
        ),
      ],
      amenities: {
        "electricity": false,
        "water": true,
        "roadAccess": false,
        "buildingPermit": false,
        "gas": false,
        "sewer": false,
        "internet": false,
        "publicTransport": false,
        "pavedRoad": false,
        "boundaryMarkers": true,
        "drainage": false,
        "floodRisk": true,
        "rainwaterCollection": true,
        "fenced": false,
        "trees": true,
        "wellWater": true,
        "flatTerrain": false,
      },
      createdAt: DateTime.parse("2025-03-08T13:47:07.047Z"),
      updatedAt: DateTime.parse("2025-03-08T13:47:07.047Z"),
    ),
    Land(
      id: "67ce32d669b63f67974cdd4b",
      title: "Terrain à Sousse",
      description: "Beau terrain pour développement commercial",
      location: "Sousse",
      surface: 800.0,
      totalTokens: 1500,
      pricePerToken: "0.7",
      priceland: "1050.0",
      ownerId: "445566",
      ownerAddress: "0x7890abcdef1234567890abcdef1234567890abcd",
      latitude: 35.8256,
      longitude: 10.6411,
      status: LandValidationStatus.PARTIALLY_VALIDATED,
      landtype: LandType.COMMERCIAL,
      ipfsCIDs: ["QmX3"],
      imageCIDs: ['assets/3.jpg'],
      blockchainTxHash: "0xghi789",
      blockchainLandId: "67ce32d669b63f67974cdd4b",
      validations: [
        ValidationEntry(
          validator: "validator3",
          validatorType: ValidatorType.EXPERT_JURIDIQUE,
          timestamp: 1696291200, // 2023-10-03
          isValidated: true,
          cidComments: "QmZ3",
        ),
        ValidationEntry(
          validator: "validator4",
          validatorType: ValidatorType.NOTAIRE,
          timestamp: 1696377600, // 2023-10-04
          isValidated: false,
          cidComments: "QmZ4",
        ),
      ],
      amenities: {
        "electricity": true,
        "water": true,
        "roadAccess": true,
        "buildingPermit": true,
        "gas": true,
        "sewer": true,
        "internet": true,
        "publicTransport": true,
        "pavedRoad": true,
        "boundaryMarkers": true,
        "drainage": true,
        "floodRisk": false,
        "rainwaterCollection": false,
        "fenced": true,
        "trees": false,
        "wellWater": false,
        "flatTerrain": true,
      },
      createdAt: DateTime.parse("2025-03-10T00:31:18.869Z"),
      updatedAt: DateTime.parse("2025-03-10T00:31:18.869Z"),
    ),
    Land(
      id: "67ebfb5412ccc9f26c3e721e",
      title: "Terrain à Sfax",
      description: "Terrain industriel",
      location: "Sfax",
      surface: 3000.0,
      totalTokens: 2500,
      pricePerToken: "0.4",
      priceland: "1000.0",
      ownerId: "1237899",
      ownerAddress: "0x111222333444555666777888999aaabbbcccddd",
      latitude: 34.7398,
      longitude: 10.7603,
      status: LandValidationStatus.REJECTED,
      landtype: LandType.INDUSTRIAL,
      ipfsCIDs: ["QmX4"],
      imageCIDs: ['assets/4.jpg'],
      blockchainTxHash: "0xjkl012",
      blockchainLandId: "67ebfb5412ccc9f26c3e721e",
      validations: [
        ValidationEntry(
          validator: "validator5",
          validatorType: ValidatorType.GEOMETRE,
          timestamp: 1696464000, // 2025-04-05
          isValidated: false,
          cidComments: "QmZ5",
        ),
      ],
      amenities: {
        "electricity": true,
        "water": true,
        "roadAccess": true,
        "buildingPermit": false,
        "gas": false,
        "sewer": true,
        "internet": false,
        "publicTransport": false,
        "pavedRoad": true,
        "boundaryMarkers": false,
        "drainage": true,
        "floodRisk": false,
        "rainwaterCollection": false,
        "fenced": true,
        "trees": false,
        "wellWater": false,
        "flatTerrain": true,
      },
      createdAt: DateTime.parse("2025-04-01T14:42:28.273Z"),
      updatedAt: DateTime.parse("2025-04-01T14:42:28.273Z"),
    ),
    Land(
      id: "67f024f3ce1890bd59ff31bf",
      title: "Beachfront Tourism Project",
      description: "Prime beachfront location for hotel development",
      location: "Hammamet Sud",
      surface: 4000.0,
      totalTokens: 3000,
      pricePerToken: "1.0",
      priceland: "3000.0",
      ownerId: "fnesrine",
      ownerAddress: "0xaaa111222333444555666777888999bbbcccddd",
      latitude: 36.3772,
      longitude: 10.5437,
      status: LandValidationStatus.VALIDATED,
      landtype: LandType.COMMERCIAL,
      ipfsCIDs: ["QmX5"],
      imageCIDs: ['assets/5.jpg'],
      blockchainTxHash: "0xmno345",
      blockchainLandId: "67f024f3ce1890bd59ff31bf",
      validations: [
        ValidationEntry(
          validator: "validator6",
          validatorType: ValidatorType.NOTAIRE,
          timestamp: 1696550400, // 2025-04-06
          isValidated: true,
          cidComments: "QmZ6",
        ),
        ValidationEntry(
          validator: "validator7",
          validatorType: ValidatorType.EXPERT_JURIDIQUE,
          timestamp: 1696636800, // 2025-04-07
          isValidated: true,
          cidComments: "QmZ7",
        ),
      ],
      amenities: {
        "electricity": true,
        "water": true,
        "roadAccess": true,
        "buildingPermit": true,
        "gas": false,
        "sewer": true,
        "internet": true,
        "publicTransport": true,
        "pavedRoad": true,
        "boundaryMarkers": true,
        "drainage": true,
        "floodRisk": false,
        "rainwaterCollection": true,
        "fenced": true,
        "trees": true,
        "wellWater": false,
        "flatTerrain": false,
      },
      createdAt: DateTime.parse("2025-04-04T18:29:07.990Z"),
      updatedAt: DateTime.parse("2025-04-04T18:29:07.990Z"),
    ),
  ];
}

  Future<Land?> fetchLandById(String id) async {
    print('[${DateTime.now()}] LandService: 🚀 Fetching land with ID: $id');
    try {
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };

      final response = await http.get(
        Uri.parse('$_baseUrl/$id'),
        headers: headers,
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
    } on SocketException catch (e) {
      print('[${DateTime.now()}] LandService: ❌ Network error: $e');
      throw Exception('Network error: Unable to connect to the server. Please check your internet connection or server status.');
    } on HttpException catch (e) {
      print('[${DateTime.now()}] LandService: ❌ HTTP error: $e');
      throw Exception('HTTP error: $e');
    } catch (e) {
      print('[${DateTime.now()}] LandService: ❌ Error fetching land by ID: $e');
      throw Exception('Error fetching land by ID: $e');
    }
  }
}