import 'package:flutter/material.dart';
import 'package:the_boost/core/constants/colors.dart';
import 'package:the_boost/features/auth/data/models/land_model.dart';

class LandAmenitiesWidget extends StatefulWidget {
  final Land land;

  const LandAmenitiesWidget({Key? key, required this.land}) : super(key: key);

  @override
  State<LandAmenitiesWidget> createState() => _LandAmenitiesWidgetState();
}

class _LandAmenitiesWidgetState extends State<LandAmenitiesWidget> {
  late Map<String, bool> _amenitiesMap = {};
  bool _showAllAmenities = false;
  
  @override
  void initState() {
    super.initState();
    _convertAmenitiesListToMap();
  }

  // Fonction de débogage pour voir ce que contient réellement l'objet amenities
  void _debugAmenities() {
    print('===== DEBUGGING AMENITIES =====');
    print('Amenities type: ${widget.land.amenities.runtimeType}');
    print('Amenities value: ${widget.land.amenities}');
    print('Amenities toString: ${widget.land.amenities.toString()}');
    if (widget.land.amenities is List) {
      print('Is List: true');
      print('List length: ${(widget.land.amenities as List).length}');
      if ((widget.land.amenities as List).isNotEmpty) {
        print('First item type: ${(widget.land.amenities as List)[0].runtimeType}');
        print('First item value: ${(widget.land.amenities as List)[0]}');
      }
    }
    print('================================');
  }

  // Convertir le format [[key, value]] en Map<String, bool>
  void _convertAmenitiesListToMap() {
    final dynamic amenitiesList = widget.land.amenities;
    _debugAmenities(); // Appel de la fonction de débogage
    
    if (amenitiesList == null) {
      _amenitiesMap = {};
      return;
    }
    
    // Si c'est déjà un Map, on l'utilise directement
    if (amenitiesList is Map<String, bool>) {
      _amenitiesMap = amenitiesList;
      return;
    }
    
    // Si c'est une liste (le cas actuel dans le JSON)
    if (amenitiesList is List) {
      final Map<String, bool> map = {};
      for (final item in amenitiesList) {
        if (item is List && item.length >= 2) {
          final key = item[0].toString();
          final value = item[1] is bool ? item[1] : (item[1].toString().toLowerCase() == 'true');
          map[key] = value;
        }
      }
      _amenitiesMap = map;
      print('Converted amenities map: $_amenitiesMap'); // Pour débogage
    }
  }

  @override
  Widget build(BuildContext context) {
    // Si aucune aménité, afficher un message
    if (_amenitiesMap.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
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
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'No amenities information available for this land',
                        style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                        textAlign: TextAlign.center,
                      ),
                      // Bouton pour rafraîchir (pour des tests)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _convertAmenitiesListToMap();
                          });
                        },
                        child: const Text('Refresh data'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Organiser les aménités par catégories
    final Map<String, List<MapEntry<String, bool>>> categorizedAmenities = {
      'Utilities': [],
      'Access': [],
      'Urban Planning': [],
      'Water Management': [],
      'Security': [],
      'Natural Features': [],
    };

    // Séparer les aménités disponibles et non disponibles
    final Map<String, bool> availableAmenities = {};
    final Map<String, bool> unavailableAmenities = {};
    
    _amenitiesMap.forEach((key, value) {
      if (value) {
        availableAmenities[key] = true;
      } else {
        unavailableAmenities[key] = false;
      }
      
      // Catégorisation
      if (['electricity', 'gas', 'water', 'sewer', 'internet'].contains(key)) {
        categorizedAmenities['Utilities']!.add(MapEntry(key, value));
      }
      else if (['roadAccess', 'publicTransport', 'pavedRoad'].contains(key)) {
        categorizedAmenities['Access']!.add(MapEntry(key, value));
      }
      else if (['buildingPermit', 'boundaryMarkers'].contains(key)) {
        categorizedAmenities['Urban Planning']!.add(MapEntry(key, value));
      }
      else if (['drainage', 'floodRisk', 'rainwaterCollection'].contains(key)) {
        categorizedAmenities['Water Management']!.add(MapEntry(key, value));
      }
      else if (['fenced'].contains(key)) {
        categorizedAmenities['Security']!.add(MapEntry(key, value));
      }
      else if (['trees', 'wellWater', 'flatTerrain'].contains(key)) {
        categorizedAmenities['Natural Features']!.add(MapEntry(key, value));
      }
    });

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                if (_amenitiesMap.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _showAllAmenities = !_showAllAmenities;
                      });
                    },
                    child: Text(
                      _showAllAmenities ? 'Show Less' : 'Show All',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (!_showAllAmenities)
              // Vue compacte des aménités disponibles uniquement
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Available Features',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 12),
                  availableAmenities.isEmpty 
                  ? const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'No available amenities',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    )
                  : Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: availableAmenities.keys
                          .take(availableAmenities.length > 8 ? 8 : availableAmenities.length)
                          .map((key) => _buildAmenityChipCompact(key))
                          .toList(),
                    ),
                  if (availableAmenities.length > 8)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        '+${availableAmenities.length - 8} more',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                          fontSize: 14,
                        ),
                      ),
                    ),
                ],
              )
            else
              // Vue détaillée avec toutes les catégories
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: categorizedAmenities.entries
                    .where((entry) => entry.value.isNotEmpty)
                    .map((category) {
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
                      ...category.value.map((amenity) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6.0),
                          child: _buildAmenityListItem(amenity.key, amenity.value),
                        );
                      }).toList(),
                      const SizedBox(height: 12),
                    ],
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmenityChipCompact(String name) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getAmenityIcon(name),
            color: AppColors.primary,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            _formatAmenityNameShort(name),
            style: TextStyle(
              color: Colors.grey[800],
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenityListItem(String name, bool isAvailable) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: isAvailable ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isAvailable ? Icons.check : Icons.close,
            color: isAvailable ? Colors.green : Colors.red.withOpacity(0.7),
            size: 14,
          ),
        ),
        const SizedBox(width: 8),
        Icon(
          _getAmenityIcon(name),
          color: isAvailable ? AppColors.primary : Colors.grey,
          size: 18,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            _formatAmenityName(name),
            style: TextStyle(
              color: isAvailable ? Colors.black87 : Colors.grey,
              fontWeight: isAvailable ? FontWeight.w500 : FontWeight.normal,
              fontSize: 14,
            ),
          ),
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
  
  // Version courte du nom pour l'affichage compact
  String _formatAmenityNameShort(String name) {
    final shortNames = {
      'electricity': 'Elec',
      'water': 'Water',
      'gas': 'Gas',
      'internet': 'Net',
      'roadAccess': 'Road',
      'fenced': 'Fence',
      'pavedRoad': 'Paved',
      'flatTerrain': 'Flat',
      'sewer': 'Sewer',
      'trees': 'Trees',
    };
    
    if (shortNames.containsKey(name)) {
      return shortNames[name]!;
    }
    
    final words = _formatAmenityName(name).split(' ');
    if (words.isNotEmpty) {
      return words[0];
    }
    
    return name;
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
        return Icons.straighten;
        
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