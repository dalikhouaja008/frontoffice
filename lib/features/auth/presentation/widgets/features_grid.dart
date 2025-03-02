// presentation/widgets/features_grid.dart
import 'package:flutter/material.dart';
import 'package:the_boost/core/constants/dimensions.dart';
import 'package:the_boost/core/constants/text_styles.dart';
import 'package:the_boost/core/utils/responsive_helper.dart';
import 'package:the_boost/features/auth/presentation/widgets/section_title.dart';

import '../widgets/feature_card.dart';

class FeaturesGrid extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<FeatureItem> features;
  final int crossAxisCount;
  final double childAspectRatio;

  const FeaturesGrid({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.features,
    this.crossAxisCount = 4,
    this.childAspectRatio = 1.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    
    final actualCrossAxisCount = isMobile 
        ? 1 
        : isTablet 
            ? (crossAxisCount > 2 ? 2 : crossAxisCount)
            : crossAxisCount;
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? AppDimensions.paddingL : AppDimensions.paddingXXL,
        vertical: AppDimensions.paddingSection,
      ),
      child: Column(
        children: [
          SectionTitle(title: title),
          const SizedBox(height: AppDimensions.paddingM),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.body1,
          ),
          const SizedBox(height: AppDimensions.paddingXXL),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: actualCrossAxisCount,
              childAspectRatio: childAspectRatio,
              crossAxisSpacing: AppDimensions.paddingL,
              mainAxisSpacing: AppDimensions.paddingL,
            ),
            itemCount: features.length,
            itemBuilder: (context, index) {
              final feature = features[index];
              return FeatureCard(
                icon: feature.icon,
                title: feature.title,
                description: feature.description,
                onTap: feature.onTap,
              );
            },
          ),
        ],
      ),
    );
  }
}

class FeatureItem {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback? onTap;

  FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
    this.onTap,
  });
}