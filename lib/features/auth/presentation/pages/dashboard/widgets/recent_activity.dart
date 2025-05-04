import 'package:flutter/material.dart';
import 'package:the_boost/core/constants/colors.dart';
import 'package:the_boost/core/constants/dimensions.dart';

class RecentActivity extends StatelessWidget {
  const RecentActivity({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Placeholder data for recent activities
    // In a real app, you would fetch this from a service
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildActivityItem(
            icon: Icons.real_estate_agent,
            color: Colors.green,
            title: "Token Purchase",
            description: "You purchased 5 tokens of Villa Azur",
            timeAgo: "2 days ago",
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildActivityItem(
            icon: Icons.trending_up,
            color: Colors.blue,
            title: "Value Increase",
            description: "Mountain Lodge tokens increased by 3.2%",
            timeAgo: "4 days ago",
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildActivityItem(
            icon: Icons.monetization_on,
            color: Colors.orange,
            title: "Dividend Payout",
            description: "Received \$125 from Urban Heights property",
            timeAgo: "1 week ago",
          ),
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            child: TextButton(
              onPressed: () {
                // Navigate to activity history page
              },
              child: const Text(
                "View All Activity",
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
    required String timeAgo,
  }) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: AppDimensions.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Text(
            timeAgo,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}