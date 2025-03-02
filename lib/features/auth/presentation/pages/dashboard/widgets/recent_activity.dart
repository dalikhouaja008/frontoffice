// presentation/pages/dashboard/widgets/recent_activity.dart
import 'package:flutter/material.dart';
import 'package:the_boost/core/constants/dimensions.dart';
import 'package:the_boost/core/utils/responsive_helper.dart';


class RecentActivity extends StatelessWidget {
  // Sample data - in a real app, this would come from your API/database
  final List<Map<String, dynamic>> activities = [
    {
      'type': 'purchase',
      'property': 'Urban Development Land - Downtown Metro',
      'amount': 2500,
      'tokens': 50,
      'date': '2025-02-15',
    },
    {
      'type': 'dividend',
      'property': 'Commercial District - Tech Corridor',
      'amount': 250,
      'date': '2025-02-10',
    },
    {
      'type': 'purchase',
      'property': 'Residential Development - Lakeside Community',
      'amount': 3000,
      'tokens': 40,
      'date': '2025-01-28',
    },
    {
      'type': 'sale',
      'property': 'Mixed-Use Development - Harbor District',
      'amount': 1800,
      'tokens': 12,
      'date': '2025-01-15',
    },
  ];

  RecentActivity({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: activities.length,
        separatorBuilder: (context, index) => Divider(height: 1),
        itemBuilder: (context, index) {
          final activity = activities[index];
          return _buildActivityItem(context, activity);
        },
      ),
    );
  }

  Widget _buildActivityItem(BuildContext context, Map<String, dynamic> activity) {
    final isMobile = ResponsiveHelper.isMobile(context);
    
    IconData icon;
    Color iconColor;
    String actionText;
    
    switch (activity['type']) {
      case 'purchase':
        icon = Icons.add_circle;
        iconColor = Colors.green;
        actionText = "Purchased ${activity['tokens']} tokens";
        break;
      case 'sale':
        icon = Icons.remove_circle;
        iconColor = Colors.red;
        actionText = "Sold ${activity['tokens']} tokens";
        break;
      case 'dividend':
        icon = Icons.attach_money;
        iconColor = Colors.amber;
        actionText = "Received dividend";
        break;
      default:
        icon = Icons.info;
        iconColor = Colors.blue;
        actionText = "Transaction";
    }
    
    final date = DateTime.parse(activity['date']);
    final formattedDate = "${date.month}/${date.day}/${date.year}";
    
    return Padding(
      padding: EdgeInsets.all(AppDimensions.paddingL),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppDimensions.paddingM),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
            ),
          ),
          SizedBox(width: AppDimensions.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  actionText,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  activity['property'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (!isMobile) SizedBox(width: AppDimensions.paddingM),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "\$${activity['amount']}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 4),
              Text(
                formattedDate,
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
  }
}