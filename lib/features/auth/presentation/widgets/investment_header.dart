// presentation/pages/invest/widgets/investment_header.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/utils/responsive_helper.dart';

class InvestmentHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? AppDimensions.paddingL : AppDimensions.paddingXXL,
        vertical: isMobile ? AppDimensions.paddingXL : AppDimensions.paddingXXL,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundGreen,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Investment Opportunities",
            style: AppTextStyles.h2.copyWith(
              fontSize: isMobile ? 24 : 32,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Discover and invest in premium tokenized land assets",
            style: AppTextStyles.body2.copyWith(
              fontSize: isMobile ? 14 : 18,
            ),
          ),
          SizedBox(height: 20),
          _buildStatCards(context),
        ],
      ),
    );
  }

  Widget _buildStatCards(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return isMobile
        ? Column(
            children: [
              _StatCard(
                value: '26',
                label: 'Available Properties',
                icon: Icons.location_on,
              ),
              SizedBox(height: 10),
              _StatCard(
                value: '\$100',
                label: 'Minimum Investment',
                icon: Icons.attach_money,
              ),
              SizedBox(height: 10),
              _StatCard(
                value: '8.4%',
                label: 'Avg. Annual Return',
                icon: Icons.trending_up,
              ),
            ],
          )
        : Row(
            children: [
              Expanded(
                child: _StatCard(
                  value: '26',
                  label: 'Available Properties',
                  icon: Icons.location_on,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  value: '\$100',
                  label: 'Minimum Investment',
                  icon: Icons.attach_money,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  value: '8.4%',
                  label: 'Avg. Annual Return',
                  icon: Icons.trending_up,
                ),
              ),
            ],
          );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return Container(
      padding: EdgeInsets.all(isMobile ? AppDimensions.paddingM : AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.backgroundGreen,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: isMobile ? 18 : 24,
            ),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: isMobile ? 16 : 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: isMobile ? 10 : 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}