import 'package:flutter/material.dart';
import 'package:the_boost/core/constants/colors.dart';
import 'package:the_boost/features/auth/data/models/land_model.dart';

class LandAmenitiesWidget extends StatelessWidget {
  final Land land;

  const LandAmenitiesWidget({Key? key, required this.land}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Vérifier si le champ amenities existe et n'est pas null
    Map<String, bool> amenitiesList = land.amenities ?? {};
    
    // Organiser les aménités par catégories
    final Map<String, List<MapEntry<String, bool>>> categorizedAmenities = {
      'Utilities': [],
      'Access': [],
      'Urban Planning': [],
      'Water Management': [],
      'Security': [],
      'Natural Features': [],
    };

    // Remplir les catégories avec les aménités correspondantes
    amenitiesList.entries.forEach((entry) {
      final key = entry.key;
      final value = entry.value;
      
      // Utilities
      if (['electricity', 'gas', 'water', 'sewer', 'internet'].contains(key)) {
        categorizedAmenities['Utilities']!.add(MapEntry(key, value));
      }
      // Access
      else if (['roadAccess', 'publicTransport', 'pavedRoad'].contains(key)) {
        categorizedAmenities['Access']!.add(MapEntry(key, value));
      }
      // Urban Planning
      else if (['buildingPermit', 'boundaryMarkers'].contains(key)) {
        categorizedAmenities['Urban Planning']!.add(MapEntry(key, value));
      }
      // Water Management
      else if (['drainage', 'floodRisk', 'rainwaterCollection'].contains(key)) {
        categorizedAmenities['Water Management']!.add(MapEntry(key, value));
      }
      // Security
      else if (['fenced'].contains(key)) {
        categorizedAmenities['Security']!.add(MapEntry(key, value));
      }
      // Natural Features
      else if (['trees', 'wellWater', 'flatTerrain'].contains(key)) {
        categorizedAmenities['Natural Features']!.add(MapEntry(key, value));
      }
      // Autres (non catégorisés)
      else {
        // Si on veut les afficher, on pourrait ajouter une catégorie "Autres"
      }
    });

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.home_work, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Amenities',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (amenitiesList.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'No amenities information available for this land',
                    style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                  ),
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: categorizedAmenities.entries.map((category) {
                  if (category.value.isEmpty) return const SizedBox.shrink();
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.key,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        children: category.value.map((amenity) => 
                          _buildAmenityChip(amenity.key, amenity.value)
                        ).toList(),
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmenityChip(String name, bool isAvailable) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          _getAmenityIcon(name),
          color: isAvailable ? AppColors.primary : Colors.grey,
          size: 18,
        ),
        const SizedBox(width: 4),
        Text(
          _formatAmenityName(name),
          style: TextStyle(
            color: isAvailable ? Colors.black87 : Colors.grey,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 4),
        Icon(
          isAvailable ? Icons.check_circle : Icons.cancel,
          color: isAvailable ? Colors.green : Colors.red.withOpacity(0.7),
          size: 14,
        ),
      ],
    );
  }

  String _formatAmenityName(String name) {
    // Si le nom est en camelCase (comme dans votre DTO), le convertir en mots séparés
    String formattedName = name.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => ' ${match.group(0)}'
    );

    // Première lettre en majuscule
    if (formattedName.isNotEmpty) {
      formattedName = formattedName[0].toUpperCase() + formattedName.substring(1);
    }

    return formattedName;
  }

  IconData _getAmenityIcon(String name) {
    switch (name.toLowerCase()) {
      // Utilities
      case 'electricity':
        return Icons.electrical_services;
      case 'gas':
        return Icons.propane_tank;
      case 'water':
        return Icons.water_drop;
      case 'sewer':
        return Icons.plumbing;
      case 'internet':
        return Icons.wifi;
        
      // Access
      case 'roadaccess':
        return Icons.add_road;
      case 'publictransport':
        return Icons.directions_bus;
      case 'pavedroad':
        return Icons.straighten; // Remplacé Icons.road par Icons.straighten
        
      // Urban Planning
      case 'buildingpermit':
        return Icons.business_center;
      case 'boundarymarkers':
        return Icons.border_all;
        
      // Water Management
      case 'drainage':
        return Icons.water;
      case 'floodrisk':
        return Icons.warning;
      case 'rainwatercollection':
        return Icons.cloud;
        
      // Security
      case 'fenced':
        return Icons.fence;
        
      // Natural Features
      case 'trees':
        return Icons.park;
      case 'wellwater':
        return Icons.local_drink;
      case 'flatterrain':
        return Icons.landscape;
        
      // Default
      default:
        return Icons.check_circle_outline;
    }
  }
}