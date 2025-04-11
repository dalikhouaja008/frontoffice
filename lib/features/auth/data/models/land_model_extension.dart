// lib/features/auth/data/models/land_model_extension.dart
import 'package:the_boost/features/auth/data/models/land_model.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

// Extension to add geo-coordinates to Land model
extension LandMapExtension on Land {
  // Get coordinates (we'll generate mock coordinates based on id)
  LatLng get coordinates {
    // For demonstration, generate deterministic coordinates based on id
    final idValue = int.tryParse(id) ?? id.hashCode;
    final latBase = 36.7783; // Base latitude (San Francisco)
    final lngBase = -119.4179; // Base longitude (California)
    
    // Create a small variation based on id
    final latOffset = (idValue % 100) / 100;
    final lngOffset = (idValue % 50) / 100;
    
    return LatLng(latBase + latOffset, lngBase + lngOffset);
  }
  
  // Get color for heat map based on price
  Color get heatMapColor {
    // Determine color based on price range (higher price = more intense color)
    if (price >= 800000) {
      return Colors.red;
    } else if (price >= 500000) {
      return Colors.orange;
    } else if (price >= 300000) {
      return Colors.yellow;
    } else {
      return Colors.green;
    }
  }
}