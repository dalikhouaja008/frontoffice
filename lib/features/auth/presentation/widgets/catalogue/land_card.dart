// widgets/land_card.dart

import 'package:flutter/material.dart';
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
              child: Image.asset(
                land.imageUrl,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    land.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    land.location,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${land.surface.toStringAsFixed(0)} m²',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${land.price.toStringAsFixed(0)} DT',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildChip(_getLandTypeLabel(land.type), Colors.blue),
                      const SizedBox(width: 8),
                      _buildChip(_getLandStatusLabel(land.status), _getStatusColor(land.status)),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _getLandTypeLabel(LandType type) {
    switch (type) {
      case LandType.AGRICULTURAL:
        return 'Agricole';
      case LandType.RESIDENTIAL:
        return 'Résidentiel';
      case LandType.INDUSTRIAL:
        return 'Industriel';
      case LandType.COMMERCIAL:
        return 'Commercial';
    }
  }

  String _getLandStatusLabel(LandStatus status) {
    switch (status) {
      case LandStatus.AVAILABLE:
        return 'Disponible';
      case LandStatus.PENDING:
        return 'En attente';
      case LandStatus.SOLD:
        return 'Vendu';
    }
  }

  Color _getStatusColor(LandStatus status) {
    switch (status) {
      case LandStatus.AVAILABLE:
        return Colors.green;
      case LandStatus.PENDING:
        return Colors.orange;
      case LandStatus.SOLD:
        return Colors.red;
    }
  }
}