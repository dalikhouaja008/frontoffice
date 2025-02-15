import 'package:flutter/material.dart';
import 'package:the_boost/features/auth/presentation/models/land_model.dart';
import '../models/land_model.dart';

class LandCard extends StatelessWidget {
  final Land land;
  final VoidCallback? onTap;

  const LandCard({
    Key? key,
    required this.land,
    this.onTap,
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
            _buildImage(),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    land.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  _buildLocationRow(),
                  const SizedBox(height: 8),
                  _buildPriceRow(),
                  const SizedBox(height: 8),
                  _buildStatusChips(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: land.imageUrl != null
          ? Image.network(
              land.imageUrl!,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  _buildPlaceholderImage(),
            )
          : _buildPlaceholderImage(),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: 120,
      color: Colors.grey[200],
      child: const Icon(
        Icons.landscape,
        size: 40,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildLocationRow() {
    return Row(
      children: [
        const Icon(Icons.location_on, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            land.location,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow() {
    return Text(
      '${land.price.toStringAsFixed(0)} DT',
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.green,
      ),
    );
  }

  Widget _buildStatusChips() {
    return Row(
      children: [
        _buildChip(
          text: land.type == LandType.AGRICULTURAL ? 'Agricole' : 'Urbain',
          color: Colors.blue,
        ),
        const SizedBox(width: 8),
        _buildChip(
          text: switch (land.status) {
            LandStatus.PENDING => 'En attente',
            LandStatus.APPROVED => 'Approuvé',
            LandStatus.REJECTED => 'Rejeté',
          },
          color: switch (land.status) {
            LandStatus.PENDING => Colors.orange,
            LandStatus.APPROVED => Colors.green,
            LandStatus.REJECTED => Colors.red,
          },
        ),
      ],
    );
  }

  Widget _buildChip({required String text, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}