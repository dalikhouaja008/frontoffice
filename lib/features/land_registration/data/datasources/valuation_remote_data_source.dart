// lib/features/land_registration/data/datasources/valuation_remote_data_source.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/error/exceptions.dart';

abstract class ValuationRemoteDataSource {
  /// Calls the valuation API to estimate land value
  /// 
  /// Throws a [ServerException] for all server errors
  Future<Map<String, dynamic>> estimateLandValue({
    required LatLng position,
    required double area,
    required String zoning,
    required bool nearWater,
    required bool roadAccess,
    required bool utilities,
  });
  
  /// Gets the current ETH price
  /// 
  /// Throws a [ServerException] for all server errors
  Future<Map<String, dynamic>> getEthPrice();
}

class ValuationRemoteDataSourceImpl implements ValuationRemoteDataSource {
  final http.Client client;
  final String baseUrl;
  final String ethPriceApiUrl;

  ValuationRemoteDataSourceImpl({
    required this.client,
    String? customBaseUrl,
    String? customEthPriceApiUrl,
  }) : 
    baseUrl = customBaseUrl ?? 'http://localhost:5000',
    ethPriceApiUrl = customEthPriceApiUrl ?? 'https://api.coingecko.com/api/v3/simple/price?ids=ethereum&vs_currencies=usd,eur,tnd';

  @override
  Future<Map<String, dynamic>> estimateLandValue({
    required LatLng position,
    required double area,
    required String zoning,
    required bool nearWater,
    required bool roadAccess,
    required bool utilities,
  }) async {
    try {
      // Modified to use simulation logic since endpoint is not available
      print('Warning: Using local simulation for land valuation since API endpoint is not available');
      
      // Simulate a successful API response
      final simulatedResponse = _generateSimulatedValuationResponse(
        position: position,
        area: area,
        zoning: zoning,
        nearWater: nearWater,
        roadAccess: roadAccess,
        utilities: utilities,
      );
      
      return simulatedResponse;
    } catch (e) {
      print('Error in estimateLandValue: $e');
      throw ServerException(message: e.toString());
    }
  }

  Map<String, dynamic> _generateSimulatedValuationResponse({
    required LatLng position,
    required double area,
    required String zoning,
    required bool nearWater,
    required bool roadAccess,
    required bool utilities,
  }) {
    // Base price per square meter in TND
    double basePricePerSqMeter = 200;
    
    // Apply multipliers based on property features
    double zoningMultiplier = 1.0;
    switch (zoning.toLowerCase()) {
      case 'residential':
        zoningMultiplier = 1.5;
        break;
      case 'commercial':
        zoningMultiplier = 2.0;
        break;
      case 'industrial':
        zoningMultiplier = 1.8;
        break;
      case 'agricultural':
        zoningMultiplier = 0.8;
        break;
    }
    
    // Feature multipliers
    double featureMultiplier = 1.0;
    if (nearWater) featureMultiplier += 0.15;
    if (roadAccess) featureMultiplier += 0.1;
    if (utilities) featureMultiplier += 0.2;
    
    // Calculate total estimated value in TND
    final estimatedValue = (area * basePricePerSqMeter * zoningMultiplier * featureMultiplier).round();
    
    // Use a fixed conversion rate for ETH (this should be fetched from an API in production)
    final ethPriceTND = 3000.0;
    final estimatedValueETH = estimatedValue / ethPriceTND;
    
    // Generate valuation factors for display
    final valuationFactors = [
      {
        'factor': 'Land Type',
        'adjustment': '${((zoningMultiplier - 1) * 100).toStringAsFixed(0)}%',
      },
      {
        'factor': 'Amenities',
        'adjustment': '${((featureMultiplier - 1) * 100).toStringAsFixed(0)}%',
      },
    ];
    
    // Generate comparable properties - simulated nearby properties with slightly different prices
    final comparables = [
      {
        'id': 'comp1',
        'address': 'Nearby Property 1',
        'price': estimatedValue * 0.9,
        'priceInETH': estimatedValueETH * 0.9,
        'area': area * 0.95,
        'pricePerSqFt': (estimatedValue * 0.9) / (area * 0.95),
        'pricePerSqFtETH': (estimatedValueETH * 0.9) / (area * 0.95),
        'features': {
          'nearWater': nearWater,
          'roadAccess': roadAccess,
          'utilities': utilities,
        },
      },
      {
        'id': 'comp2',
        'address': 'Nearby Property 2',
        'price': estimatedValue * 1.1,
        'priceInETH': estimatedValueETH * 1.1,
        'area': area * 1.05,
        'pricePerSqFt': (estimatedValue * 1.1) / (area * 1.05),
        'pricePerSqFtETH': (estimatedValueETH * 1.1) / (area * 1.05),
        'features': {
          'nearWater': nearWater,
          'roadAccess': roadAccess,
          'utilities': utilities,
        },
      },
    ];
    
    // Return the simulated response format that matches what the API would return
    return {
      'location': {
        'position': {
          'latitude': position.latitude,
          'longitude': position.longitude,
        },
        'address': 'Simulated Address at ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}',
      },
      'valuation': {
        'estimatedValue': estimatedValue,
        'estimatedValueETH': estimatedValueETH,
        'areaInSqFt': area,
        'avgPricePerSqFt': estimatedValue / area,
        'avgPricePerSqFtETH': estimatedValueETH / area,
        'zoning': zoning,
        'valuationFactors': valuationFactors,
        'currentEthPriceTND': ethPriceTND,
      },
      'comparables': comparables,
    };
  }

  @override
  Future<Map<String, dynamic>> getEthPrice() async {
    try {
      final response = await client.get(Uri.parse(ethPriceApiUrl));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        
        // Extract ETH prices
        final ethData = jsonResponse['ethereum'];
        if (ethData == null) {
          // If API didn't return expected format, provide fallback values
          return {
            'ethPriceUSD': 2500.0,
            'ethPriceEUR': 2300.0,
            'ethPriceTND': 7500.0,
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          };
        }
        
        final priceUsd = ethData['usd'] ?? 0.0;
        final priceEur = ethData['eur'] ?? 0.0;
        final priceTnd = ethData['tnd'] ?? (priceUsd * 3.0); // Fallback conversion if TND not available
        
        return {
          'ethPriceUSD': priceUsd,
          'ethPriceEUR': priceEur,
          'ethPriceTND': priceTnd,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        };
      } else {
        throw ServerException(message: 'Failed to get ETH price: ${response.body}');
      }
    } catch (e) {
      print('Error in getEthPrice: $e');
      
      // Provide fallback values if API call fails
      return {
        'ethPriceUSD': 2500.0,
        'ethPriceEUR': 2300.0,
        'ethPriceTND': 7500.0,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
    }
  }
}