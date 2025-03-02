// presentation/pages/property_details/widgets/property_information.dart
import 'package:flutter/material.dart';
import 'package:the_boost/core/constants/colors.dart';
import 'package:the_boost/core/constants/dimensions.dart';
import 'package:the_boost/core/constants/text_styles.dart';
import 'package:the_boost/features/auth/presentation/widgets/learn_more_page.dart';
import '../../../../domain/entities/property.dart';

class PropertyInformation extends StatelessWidget {
  final Property property;

  const PropertyInformation({
    Key? key,
    required this.property,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: "Property Overview"),
       const  SizedBox(height: AppDimensions.paddingM),
        _buildPropertyStats(),
        const SizedBox(height: AppDimensions.paddingL),
        _buildPropertyDescription(),
        const SizedBox(height: AppDimensions.paddingL),
        _buildInvestmentHighlights(),
        const SizedBox(height: AppDimensions.paddingL),
        _buildRiskAssessment(),
      ],
    );
  }

  Widget _buildPropertyStats() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            label: "Price/Token",
            value: "\$${property.tokenPrice}",
          ),
          _buildStatItem(
            label: "Total Value",
            value: "\$${_formatLargeNumber(property.totalValue)}",
          ),
          _buildStatItem(
            label: "Available Tokens",
            value: "${property.availableTokens}",
          ),
          _buildStatItem(
            label: "Funding",
            value: "${(property.fundingPercentage * 100).toInt()}%",
            valueColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.black54,
          ),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildPropertyDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "About This Property",
          style: AppTextStyles.h4,
        ),
        SizedBox(height: AppDimensions.paddingM),
        Text(
          "This premium ${property.category.toLowerCase()} property offers exceptional investment potential. Located in the heart of ${property.location}, it benefits from strong market fundamentals and projected growth in the coming years.\n\nThe property has been carefully vetted by our acquisition team, ensuring it meets our strict investment criteria for location, value, and potential returns.",
          style: TextStyle(
            fontSize: 14,
            height: 1.6,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildInvestmentHighlights() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Investment Highlights",
          style: AppTextStyles.h4,
        ),
        SizedBox(height: AppDimensions.paddingM),
        _buildHighlightItem(
          "Premium Location",
          "Prime area with excellent accessibility and visibility",
        ),
        _buildHighlightItem(
          "Strong Market Fundamentals",
          "Located in a growing market with positive economic indicators",
        ),
        _buildHighlightItem(
          "Projected Returns",
          "Estimated annual return of ${property.projectedReturn}% based on historical data",
        ),
        _buildHighlightItem(
          "Professional Management",
          "Property professionally managed to maximize value and returns",
        ),
      ],
    );
  }

  Widget _buildHighlightItem(String title, String description) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppDimensions.paddingM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            color: AppColors.primary,
            size: 20,
          ),
          SizedBox(width: AppDimensions.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskAssessment() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Risk Assessment",
          style: AppTextStyles.h4,
        ),
        SizedBox(height: AppDimensions.paddingM),
        Container(
          padding: EdgeInsets.all(AppDimensions.paddingL),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              _buildRiskItem(
                title: "Risk Level",
                value: property.riskLevel,
                color: _getRiskColor(property.riskLevel),
              ),
              Divider(height: AppDimensions.paddingXL),
              Text(
                "Investing in real estate involves various risks, including market fluctuations, liquidity concerns, and property-specific risks. This investment is categorized as ${property.riskLevel.toLowerCase()} risk based on our comprehensive risk assessment framework.",
                style: TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRiskItem({
    required String title,
    required String value,
    required Color color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingM,
            vertical: AppDimensions.paddingXS,
          ),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Color _getRiskColor(String riskLevel) {
    switch (riskLevel) {
      case 'Low':
        return Colors.green;
      case 'Medium':
        return Colors.orange;
      case 'Medium-High':
        return Colors.amber.shade700;
      case 'High':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  String _formatLargeNumber(double number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toString();
    }
  }
}