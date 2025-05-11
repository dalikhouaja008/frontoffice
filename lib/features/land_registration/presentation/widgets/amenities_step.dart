import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../utils/string_extensions.dart';

class AmenitiesStep extends StatelessWidget {
  final Map<String, bool> amenities;
  final Function(String, bool) onAmenityChanged;

  const AmenitiesStep({
    Key? key,
    required this.amenities,
    required this.onAmenityChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Property Amenities',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          'Select the amenities and features available on your property',
          style: TextStyle(color: Colors.grey[600], fontSize: 16),
        ),
        SizedBox(height: 32),

        // Basic Utilities
        _buildAmenitySection(
          context,
          'Basic Utilities',
          Icons.power,
          [
            'electricity',
            'gas',
            'water',
            'sewer',
            'internet',
          ],
        ),
        SizedBox(height: 24),

        // Studies & Surveys
        _buildAmenitySection(
          context,
          'Studies & Surveys',
          Icons.assignment,
          [
            'geotechnicalSurvey',
            'soilAnalysis',
            'topographicalSurvey',
            'environmentalStudy',
          ],
        ),
        SizedBox(height: 24),

        // Access & Transportation
        _buildAmenitySection(
          context,
          'Access & Transportation',
          Icons.directions_car,
          [
            'roadAccess',
            'publicTransport',
            'pavedRoad',
          ],
        ),
        SizedBox(height: 24),

        // Legal & Administrative
        _buildAmenitySection(
          context,
          'Legal & Administrative',
          Icons.gavel,
          [
            'buildingPermit',
            'zoned',
            'boundaryMarkers',
            'headquarters',
          ],
        ),
        SizedBox(height: 24),

        // Water Management
        _buildAmenitySection(
          context,
          'Water Management',
          Icons.water_drop,
          [
            'drainage',
            'floodRisk',
            'rainwaterCollection',
            'wellWater',
          ],
        ),
        SizedBox(height: 24),

        // Security & Nature
        _buildAmenitySection(
          context,
          'Security & Nature',
          Icons.security,
          [
            'fenced',
            'securitySystem',
            'trees',
            'flatTerrain',
          ],
        ),
      ],
    );
  }

  Widget _buildAmenitySection(
    BuildContext context,
    String title,
    IconData icon,
    List<String> amenityList,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary),
                SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: amenityList.map((amenity) {
                return SizedBox(
                  width: MediaQuery.of(context).size.width > 600
                      ? (MediaQuery.of(context).size.width - 150) / 3
                      : (MediaQuery.of(context).size.width - 100) / 2,
                  child: CheckboxListTile(
                    title: Text(_formatAmenityName(amenity)),
                    value: amenities[amenity] ?? false,
                    onChanged: (bool? value) {
                      onAmenityChanged(amenity, value ?? false);
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  String _formatAmenityName(String amenity) {
    // Convert camelCase to words
    String result = amenity.replaceAllMapped(
      RegExp(r'([A-Z]|[0-9]+)'),
      (Match match) => ' ${match.group(0)}',
    );

    // Capitalize first letter
    return result[0].toUpperCase() + result.substring(1);
  }
}