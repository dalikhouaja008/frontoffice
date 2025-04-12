import 'package:flutter/material.dart';
import 'package:the_boost/core/constants/colors.dart';
import 'package:the_boost/features/auth/data/models/land_model.dart';

class LandCard extends StatelessWidget {
  final Land land;
  final VoidCallback onTap;

  const LandCard({
    Key? key,
    required this.land,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: land.imageCIDs.isNotEmpty
                  ? Image.network(
                      land.imageCIDs[0],
                      height: 120, // Reduced height for smaller card
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 120,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported, size: 40),
                      ),
                    )
                  : Container(
                      height: 120,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported, size: 40),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(8), // Reduced padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    land.title,
                    style: const TextStyle(
                      fontSize: 14, // Smaller font size
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    land.location,
                    style: TextStyle(
                      fontSize: 12, // Smaller font size
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${land.surface.toStringAsFixed(0)} m²',
                        style: const TextStyle(
                          fontSize: 12, // Smaller font size
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${land.totalPrice.toStringAsFixed(2)} DT',
                        style: const TextStyle(
                          fontSize: 14, // Smaller font size
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    children: [
                      _buildChip(_getLandTypeLabel(land.landtype), Colors.blue),
                      _buildChip(
                          _getLandStatusLabel(land.status), _getStatusColor(land.status)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Amenities Section
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      if (land.amenities['electricity'] == true)
                        _buildAmenityChip(Icons.electrical_services, 'Electricity', Colors.green),
                      if (land.amenities['water'] == true)
                        _buildAmenityChip(Icons.water_drop, 'Water', Colors.blue),
                      if (land.amenities['roadAccess'] == true)
                        _buildAmenityChip(Icons.directions_car, 'Road Access', Colors.grey),
                      if (land.amenities['buildingPermit'] == true)
                        _buildAmenityChip(Icons.build, 'Building Permit', Colors.orange),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10, // Smaller font size for chips
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildAmenityChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10, // Smaller font size for amenities
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getLandTypeLabel(LandType type) {
    switch (type) {
      case LandType.AGRICULTURAL:
        return 'Agricole';
      case LandType.RESIDENTIAL:
        return 'Résidentiel';
      case LandType.COMMERCIAL:
        return 'Commercial';
      case LandType.INDUSTRIAL:
        return 'Industriel';
    }
  }

  String _getLandStatusLabel(LandValidationStatus status) {
    switch (status) {
      case LandValidationStatus.PENDING_VALIDATION:
        return 'En attente';
      case LandValidationStatus.VALIDATED:
        return 'Validé';
      case LandValidationStatus.REJECTED:
        return 'Rejeté';
      case LandValidationStatus.PARTIALLY_VALIDATED:
        return 'Partiellement Validé';
    }
  }

  Color _getStatusColor(LandValidationStatus status) {
    switch (status) {
      case LandValidationStatus.PENDING_VALIDATION:
        return Colors.orange;
      case LandValidationStatus.VALIDATED:
        return Colors.green;
      case LandValidationStatus.REJECTED:
        return Colors.red;
      case LandValidationStatus.PARTIALLY_VALIDATED:
        return Colors.amber;
    }
  }
}