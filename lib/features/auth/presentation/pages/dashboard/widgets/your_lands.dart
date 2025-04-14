// lib/features/auth/presentation/pages/dashboard/widgets/your_lands.dart
import 'package:flutter/material.dart';
import 'package:the_boost/core/constants/dimensions.dart';

class YourLands extends StatelessWidget {
  const YourLands({super.key});

  // Static list of lands for display
  static const List<Map<String, dynamic>> staticLands = [
    {
      'title': 'Terrain à Tunis',
      'location': 'Tunis, Tunisia',
      'investedAmount': 500.00,
    },
    {
      'title': 'Terrain à Djerba',
      'location': 'Djerba, Tunisia',
      'investedAmount': 600.00,
    },
    {
      'title': 'Terrain à Sousse',
      'location': 'Sousse, Tunisia',
      'investedAmount': 1050.00,
    },
    {
      'title': 'Terrain à Sfax',
      'location': 'Sfax, Tunisia',
      'investedAmount': 1000.00,
    },
    {
      'title': 'Beachfront Tourism Project',
      'location': 'Hammamet, Tunisia',
      'investedAmount': 3000.00,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      margin: const EdgeInsets.only(top: AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Your Lands",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingL),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: staticLands.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final land = staticLands[index];
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppDimensions.paddingM,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          land['title'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          land['location'],
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "${land['investedAmount'].toStringAsFixed(2)} €",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Invested",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}