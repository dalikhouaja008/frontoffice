// lib/features/auth/presentation/pages/dashboard/widgets/dashboard_stats.dart
import 'package:flutter/material.dart';
import 'package:the_boost/core/constants/dimensions.dart';
import 'package:the_boost/core/utils/responsive_helper.dart';

class DashboardStats extends StatelessWidget {
  const DashboardStats({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    // Static values matching the screenshot
    const totalValue = 7380.00;
    const totalInvested = 6150.00;
    const totalReturn = 1230.00;
    const roi = 20.0;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: AppDimensions.paddingL),
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: isMobile
          ? Column(
              children: [
                _buildStatItem(
                  context: context,
                  title: "Portfolio Value",
                  value: "${totalValue.toStringAsFixed(2)} €",
                  changeText: "+${totalReturn.toStringAsFixed(2)} € (${(totalReturn / totalInvested * 100).toStringAsFixed(1)}%)",
                  isPositive: totalReturn > 0,
                ),
                const Divider(height: AppDimensions.paddingXL),
                _buildStatItem(
                  context: context,
                  title: "Invested Capital",
                  value: "${totalInvested.toStringAsFixed(2)} €",
                  changeText: "5 properties",
                ),
                const Divider(height: AppDimensions.paddingXL),
                _buildStatItem(
                  context: context,
                  title: "Total Return",
                  value: "${totalReturn.toStringAsFixed(2)} €",
                  changeText: "${roi.toStringAsFixed(1)}% ROI",
                  isPositive: totalReturn > 0,
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
                    value: "${totalValue.toStringAsFixed(2)} €",
                    changeText: "+${totalReturn.toStringAsFixed(2)} € (${(totalReturn / totalInvested * 100).toStringAsFixed(1)}%)",
                    isPositive: totalReturn > 0,
                  ),
                ),
                const VerticalDivider(width: AppDimensions.paddingXL),
                Expanded(
                  child: _buildStatItem(
                    context: context,
                    title: "Invested Capital",
                    value: "${totalInvested.toStringAsFixed(2)} €",
                    changeText: "5 properties",
                  ),
                ),
                const VerticalDivider(width: AppDimensions.paddingXL),
                Expanded(
                  child: _buildStatItem(
                    context: context,
                    title: "Total Return",
                    value: "${totalReturn.toStringAsFixed(2)} €",
                    changeText: "${roi.toStringAsFixed(1)}% ROI",
                    isPositive: totalReturn > 0,
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
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingS),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingS),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isPositive)
              const Icon(
                Icons.arrow_upward,
                color: Colors.green,
                size: 16,
              ),
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