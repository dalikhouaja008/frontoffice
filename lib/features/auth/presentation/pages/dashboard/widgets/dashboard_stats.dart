import 'package:flutter/material.dart';
import 'package:the_boost/core/constants/dimensions.dart';
import 'package:the_boost/core/utils/responsive_helper.dart';

class DashboardStats extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: isMobile
          ? Column(
              children: [
                _buildStatItem(
                  context: context,
                  title: "Portfolio Value",
                  value: "\$15,250",
                  changeText: "+\$1,250 (8.9%)",
                  isPositive: true,
                ),
                Divider(height: AppDimensions.paddingXL),
                _buildStatItem(
                  context: context,
                  title: "Invested Capital",
                  value: "\$12,500",
                  changeText: "5 properties",
                ),
                Divider(height: AppDimensions.paddingXL),
                _buildStatItem(
                  context: context,
                  title: "Total Return",
                  value: "\$2,750",
                  changeText: "22% ROI",
                  isPositive: true,
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: _buildStatItem(
                    context: context,
                    title: "Portfolio Value",
                    value: "\$15,250",
                    changeText: "+\$1,250 (8.9%)",
                    isPositive: true,
                  ),
                ),
                VerticalDivider(width: AppDimensions.paddingXL),
                Expanded(
                  child: _buildStatItem(
                    context: context,
                    title: "Invested Capital",
                    value: "\$12,500",
                    changeText: "5 properties",
                  ),
                ),
                VerticalDivider(width: AppDimensions.paddingXL),
                Expanded(
                  child: _buildStatItem(
                    context: context,
                    title: "Total Return",
                    value: "\$2,750",
                    changeText: "22% ROI",
                    isPositive: true,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatItem({
    required BuildContext context,
    required String title,
    required String value,
    required String changeText,
    bool isPositive = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
        SizedBox(height: AppDimensions.paddingS),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: AppDimensions.paddingS),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isPositive
                ? Icon(
                    Icons.arrow_upward,
                    color: Colors.green,
                    size: 16,
                  )
                : SizedBox(width: 0),
            Text(
              changeText,
              style: TextStyle(
                fontSize: 14,
                color: isPositive ? Colors.green : Colors.black54,
                fontWeight: isPositive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ],
    );
  }
}