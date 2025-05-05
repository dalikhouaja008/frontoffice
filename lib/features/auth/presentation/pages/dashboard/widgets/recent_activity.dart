import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:the_boost/core/constants/colors.dart';
import 'package:the_boost/core/constants/dimensions.dart';
import 'package:the_boost/features/auth/domain/entities/token.dart';
import 'package:the_boost/features/auth/presentation/bloc/investment/investment_bloc.dart';

enum ActivityType {
  purchase,
  listing,
  sale,
  priceUpdate,
}

class ActivityItem {
  final ActivityType type;
  final DateTime date;
  final String title;
  final String description;
  final String tokenInfo;
  final String? imageUrl;
  final String? valueChange;
  final bool isPositiveChange;

  ActivityItem({
    required this.type,
    required this.date,
    required this.title,
    required this.description,
    required this.tokenInfo,
    this.imageUrl,
    this.valueChange,
    this.isPositiveChange = false,
  });

  // Factory method to create activity items from tokens data
  static List<ActivityItem> createFromTokens(List<Token> tokens) {
    List<ActivityItem> activities = [];
    
    for (var token in tokens) {
      // Add purchase activity
      activities.add(
        ActivityItem(
          type: ActivityType.purchase,
          date: token.purchaseInfo.date,
          title: "Token Purchase",
          description: "You purchased token #${token.tokenNumber}",
          tokenInfo: token.land.title,
          imageUrl: token.land.imageUrl,
          valueChange: token.purchaseInfo.formattedPrice,
          isPositiveChange: false,
        ),
      );
      
      // If the token is listed, add listing activity
      if (token.isListed && token.listingInfo != null) {
        activities.add(
          ActivityItem(
            type: ActivityType.listing,
            date: DateTime.now(), // Replace with actual listing date when available
            title: "Listed for Sale",
            description: "You listed token #${token.tokenNumber} for sale",
            tokenInfo: token.land.title,
            imageUrl: token.land.imageUrl,
            valueChange: token.listingInfo!.formattedPrice,
            isPositiveChange: true,
          ),
        );
      }
      
      // If there's a price change, add price update activity
      if (token.currentMarketInfo.change != 0) {
        activities.add(
          ActivityItem(
            type: ActivityType.priceUpdate,
            date: DateTime.now().subtract(const Duration(days: 1)), // Estimate, replace with actual date
            title: "Price Change",
            description: "Token #${token.tokenNumber} price has changed",
            tokenInfo: token.land.title,
            imageUrl: token.land.imageUrl,
            valueChange: token.currentMarketInfo.changeFormatted,
            isPositiveChange: token.currentMarketInfo.change > 0,
          ),
        );
      }
    }
    
    // Sort activities by date (most recent first)
    activities.sort((a, b) => b.date.compareTo(a.date));
    
    return activities;
  }
}

class RecentActivity extends StatelessWidget {
  final int maxItems;

  const RecentActivity({
    Key? key,
    this.maxItems = 3,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InvestmentBloc, InvestmentState>(
      builder: (context, state) {
        if (state is InvestmentLoading) {
          return _buildLoadingActivity();
        } else if (state is InvestmentLoaded) {
          return _buildActivity(context, state.tokens);
        } else if (state is InvestmentRefreshing) {
          return _buildActivity(context, state.tokens);  
        } else if (state is InvestmentError) {
          return _buildErrorActivity(context, state.message);
        } else {
          return _buildEmptyActivity();
        }
      },
    );
  }
  
  Widget _buildActivity(BuildContext context, List<Token> tokens) {
    final activities = ActivityItem.createFromTokens(tokens);
    
    if (activities.isEmpty) {
      return _buildEmptyActivity();
    }
    
    // Limit the number of activities shown
    final displayedActivities = activities.length > maxItems
        ? activities.sublist(0, maxItems)
        : activities;
    
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
          for (int i = 0; i < displayedActivities.length; i++) 
            Column(
              children: [
                _buildActivityItem(context, displayedActivities[i]),
                if (i < displayedActivities.length - 1)
                  const Divider(height: 1, indent: 16, endIndent: 16),
              ],
            ),
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            child: TextButton(
              onPressed: () {
                // Navigate to full activity history
                Navigator.pushNamed(context, '/activity');
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

  Widget _buildActivityItem(BuildContext context, ActivityItem activity) {
    // Determine the icon based on activity type
    IconData activityIcon;
    Color iconColor;
    
    switch (activity.type) {
      case ActivityType.purchase:
        activityIcon = Icons.shopping_cart;
        iconColor = Colors.blue;
        break;
      case ActivityType.listing:
        activityIcon = Icons.sell;
        iconColor = Colors.orange;
        break;
      case ActivityType.sale:
        activityIcon = Icons.paid;
        iconColor = Colors.green;
        break;
      case ActivityType.priceUpdate:
        activityIcon = Icons.trending_up;
        iconColor = activity.isPositiveChange ? Colors.green : Colors.red;
        break;
    }
    
    // Format relative time (e.g., "3 hours ago")
    final timeAgo = timeago.format(activity.date, locale: 'en');
    
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              activityIcon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: AppDimensions.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  activity.description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timeAgo,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (activity.valueChange != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  activity.valueChange!,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: activity.type == ActivityType.priceUpdate
                        ? (activity.isPositiveChange ? Colors.green : Colors.red)
                        : Colors.black,
                  ),
                ),
                if (activity.type == ActivityType.priceUpdate)
                  Icon(
                    activity.isPositiveChange
                        ? Icons.arrow_upward
                        : Icons.arrow_downward,
                    color: activity.isPositiveChange ? Colors.green : Colors.red,
                    size: 14,
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingActivity() {
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
        children: List.generate(
          maxItems,
          (index) => Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.paddingM),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 120,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 180,
                            height: 14,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 60,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 60,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
              if (index < maxItems - 1)
                const Divider(height: 1, indent: 16, endIndent: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorActivity(BuildContext context, String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.paddingL),
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
          const Icon(
            Icons.error_outline,
            color: Colors.orange,
            size: 40,
          ),
          const SizedBox(height: AppDimensions.paddingS),
          const Text(
            "Couldn't load activity",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingXS),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingM),
          TextButton.icon(
            onPressed: () {
              context.read<InvestmentBloc>().add(LoadEnhancedTokens());
            },
            icon: const Icon(Icons.refresh),
            label: const Text("Try Again"),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyActivity() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.paddingL),
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
          Icon(
            Icons.history,
            color: Colors.grey[400],
            size: 48,
          ),
          const SizedBox(height: AppDimensions.paddingM),
          const Text(
            "No recent activity",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingS),
          Text(
            "Your investment activities will appear here",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}