// lib/features/auth/presentation/widgets/catalogue/land_card.dart
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
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

  // Convert IPFS link to a usable URL if needed
  String _resolveImageUrl(String cid) {
    if (cid.startsWith('ipfs://')) {
      // Replace 'ipfs://' with a gateway URL
      return 'https://ipfs.io/ipfs/${cid.replaceFirst('ipfs://', '')}';
    }
    return cid; // Already a direct URL (e.g., https://picsum.photos/...)
  }

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
                        _resolveImageUrl(land.imageCIDs!.first),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(child: CircularProgressIndicator());
                        },
                        errorBuilder: (context, error, stackTrace) =>
                            const Text('Image Not Available'),
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
                        icon: const Icon(Icons.volume_up,
                            color: AppColors.primary),
                        onPressed: onSpeak,
                        tooltip: 'Speak description',
                      ),
                      IconButton(
                        icon: const Icon(Icons.volume_off,
                            color: AppColors.primary),
                        onPressed: onStopSpeaking,
                        tooltip: 'Stop speaking',
                      ),
                      IconButton(
                        icon: const Icon(Icons.share,
                            color: AppColors.primary),
                        onPressed: () => _shareLand(context),
                        tooltip: 'Share land',
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

  void _shareLand(BuildContext context) {
    final String deepLink = 'https://yourapp.com/lands/${land.id}';
    final String shareText = '''
🏡 Land for Sale: ${land.title}
📍 Location: ${land.location}
📏 Surface: ${land.surface ?? 'N/A'} m²
💰 Price: ${land.totalPrice?.toStringAsFixed(2) ?? 'N/A'} DT
📜 Description: ${land.description ?? 'No description available'}
🔍 Status: ${land.status}
👉 More Details: $deepLink
📞 Contact us for more information!
''';

    Share.share(
      shareText,
      subject: 'Land for Sale: ${land.title}',
    );
  }
}