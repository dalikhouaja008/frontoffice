import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_boost/core/constants/colors.dart';
import 'package:the_boost/core/constants/dimensions.dart';
import 'package:the_boost/core/constants/text_styles.dart';
import 'package:the_boost/features/auth/presentation/bloc/property/property_bloc.dart';

class InvestmentFilters extends StatelessWidget {
  final PropertyBloc bloc;
  final bool isMobile;

  const InvestmentFilters({
    Key? key,
    required this.bloc,
    required this.isMobile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isMobile ? double.infinity : 250,
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilterHeader(),
          const Divider(),
          const SizedBox(height: AppDimensions.paddingM),
          _buildCategoryFilter(),
          const SizedBox(height: AppDimensions.paddingL),
          _buildPriceRangeFilter(),
          const SizedBox(height: AppDimensions.paddingL),
          _buildReturnRangeFilter(),
          const SizedBox(height: AppDimensions.paddingL),
          _buildRiskLevelFilter(),
        ],
      ),
    );
  }

  Widget _buildFilterHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Filters", style: AppTextStyles.h3),
        TextButton(
          onPressed: () => bloc.add(ResetFilters()),
          child: Text(
            "Reset",
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Property Type",
          style: AppTextStyles.h4,
        ),
        const SizedBox(height: AppDimensions.paddingS),
        BlocBuilder<PropertyBloc, PropertyState>(
          builder: (context, state) {
            return Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                _buildCategoryChip('All', bloc.selectedCategory),
                _buildCategoryChip('Residential', bloc.selectedCategory),
                _buildCategoryChip('Commercial', bloc.selectedCategory),
                _buildCategoryChip('Agricultural', bloc.selectedCategory),
                _buildCategoryChip('Industrial', bloc.selectedCategory),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String category, String selectedCategory) {
    final isSelected = category == selectedCategory;

    return FilterChip(
      label: Text(
        category,
        style: TextStyle(
          color: isSelected ? Colors.white : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 14,
        ),
      ),
      selected: isSelected,
      selectedColor: AppColors.primary,
      backgroundColor: Colors.grey.shade200,
      checkmarkColor: Colors.white,
      onSelected: (_) => bloc.add(SetCategory(category)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 4,
        vertical: 2,
      ),
    );
  }

  Widget _buildPriceRangeFilter() {
    return BlocBuilder<PropertyBloc, PropertyState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Investment Range",
                  style: AppTextStyles.h4,
                ),
                Text(
                  "\$${bloc.priceRange.start.round()} - \$${bloc.priceRange.end.round()}",
                  style: AppTextStyles.body3,
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.paddingM),
            RangeSlider(
              min: 100,
              max: 50000,
              divisions: 100,
              values: bloc.priceRange,
              activeColor: AppColors.primary,
              inactiveColor: Colors.grey.shade300,
              labels: RangeLabels(
                "\$${bloc.priceRange.start.round()}",
                "\$${bloc.priceRange.end.round()}",
              ),
              onChanged: (values) => bloc.add(SetPriceRange(values)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildReturnRangeFilter() {
    return BlocBuilder<PropertyBloc, PropertyState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Projected Return",
                  style: AppTextStyles.h4,
                ),
                Text(
                  "${bloc.returnRange.start.round()}% - ${bloc.returnRange.end.round()}%",
                  style: AppTextStyles.body3,
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.paddingM),
            RangeSlider(
              min: 5,
              max: 20,
              divisions: 15,
              values: bloc.returnRange,
              activeColor: AppColors.primary,
              inactiveColor: Colors.grey.shade300,
              labels: RangeLabels(
                "${bloc.returnRange.start.round()}%",
                "${bloc.returnRange.end.round()}%",
              ),
              onChanged: (values) => bloc.add(SetReturnRange(values)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRiskLevelFilter() {
    return BlocBuilder<PropertyBloc, PropertyState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Risk Level",
              style: AppTextStyles.h4,
            ),
            const SizedBox(height: AppDimensions.paddingM),
            _buildRiskLevelItem('Low', Colors.green),
            _buildRiskLevelItem('Medium', Colors.orange),
            _buildRiskLevelItem('Medium-High', Colors.deepOrange),
            _buildRiskLevelItem('High', Colors.red),
          ],
        );
      },
    );
  }

  Widget _buildRiskLevelItem(String level, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: bloc.selectedRiskLevels.contains(level),
              activeColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              onChanged: (_) => bloc.add(ToggleRiskLevel(level)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              level,
              style: AppTextStyles.body2,
            ),
          ),
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}