import 'package:flutter/material.dart';
import 'package:the_boost/features/auth/data/models/land_model.dart';

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
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Section
                Stack(
                  children: [
                    SizedBox(
                      height: constraints.maxHeight * 0.5,
                      width: double.infinity,
                      child: land.imageCIDs.isNotEmpty
                          ? Image.network(
                              'https://ipfs.io/ipfs/${land.imageCIDs.first}',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  _buildPlaceholder(constraints.maxHeight * 0.5),
                            )
                          : _buildPlaceholder(constraints.maxHeight * 0.5),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: _buildStatusChip(),
                    ),
                  ],
                ),
                // Details Section
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
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
                        // Location
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 16),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                land.location,
                                style: Theme.of(context).textTheme.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        // Info Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Surface
                            Text(
                              '${land.surface} m²',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            // Type
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                land.type.toString().split('.').last,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Price
                        Text(
                          '\$${land.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPlaceholder(double height) {
    return Container(
      height: height,
      color: Colors.grey.shade200,
      child: Center(
        child: Icon(
          Icons.landscape,
          size: 48,
          color: Colors.grey.shade400,
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    Color backgroundColor;
    switch (land.status) {
      case LandStatus.AVAILABLE:
        backgroundColor = Colors.green;
        break;
      case LandStatus.PENDING:
        backgroundColor = Colors.orange;
        break;
      case LandStatus.SOLD:
        backgroundColor = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        land.status.toString().split('.').last,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}