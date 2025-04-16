// lib/features/auth/presentation/widgets/catalogue/land_card.dart
import 'package:flutter/material.dart';
import 'package:the_boost/core/constants/colors.dart';
import 'package:the_boost/core/constants/dimensions.dart';
import 'package:the_boost/features/auth/data/models/land_model.dart';

class LandCard extends StatelessWidget {
  final Land land;
  final VoidCallback onTap;
  final VoidCallback onSpeak;
  final VoidCallback onStopSpeaking;

  const LandCard({
    Key? key,
    required this.land,
    required this.onTap,
    required this.onSpeak,
    required this.onStopSpeaking,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusM),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Placeholder for land image (if imageCIDs are available)
            Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppDimensions.borderRadiusM),
                    ),
                  ),
                  child: land.imageCIDs?.isNotEmpty == true
                    ? Image.network(
                        land.imageCIDs!.first, // Now safe because we checked isNotEmpty
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) => const Text('Image Not Available'),
                      )
                    : const Text('No Image Available'),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingS),
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
                  const SizedBox(height: AppDimensions.spacingS),
                  Text(
                    land.location,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppDimensions.spacingS),
                  Text(
                    'Price: ${land.totalPrice?.toStringAsFixed(2) ?? 'N/A'} DT',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingS),
                  Text(
                    land.description ?? 'No description available',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppDimensions.spacingS),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.volume_up, color: AppColors.primary),
                        onPressed: onSpeak,
                        tooltip: 'Speak description',
                      ),
                      IconButton(
                        icon: const Icon(Icons.volume_off, color: AppColors.primary),
                        onPressed: onStopSpeaking,
                        tooltip: 'Stop speaking',
                      ),
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
}