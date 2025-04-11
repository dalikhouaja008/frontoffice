import 'package:flutter/material.dart';
import 'package:the_boost/core/constants/dimensions.dart';
import 'package:the_boost/core/constants/text_styles.dart';
import 'package:the_boost/core/utils/responsive_helper.dart';

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
    
    // Determine the effective grid count based on screen size
    final effectiveCrossAxisCount = isMobile 
        ? 1 
        : isTablet 
            ? 2 
            : crossAxisCount;
    
    // Adjust aspect ratio for different screen sizes
    final effectiveAspectRatio = isMobile 
        ? 1.2 
        : isTablet 
            ? 1.0 
            : childAspectRatio;
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? AppDimensions.paddingL : AppDimensions.paddingXXL,
        vertical: isMobile ? AppDimensions.paddingXL : AppDimensions.paddingSection,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Text(
            title,
            style: AppTextStyles.h2,
            textAlign: isMobile ? TextAlign.center : TextAlign.left,
          ),
          const SizedBox(height: AppDimensions.paddingM),
          // Section subtitle
          Text(
            subtitle,
            style: AppTextStyles.body1,
            textAlign: isMobile ? TextAlign.center : TextAlign.left,
          ),
          const SizedBox(height: AppDimensions.paddingXL),
          // Features grid with explicit height calculation
          LayoutBuilder(
            builder: (context, constraints) {
              // Calculate the appropriate card height based on available width
              final cardWidth = (constraints.maxWidth - 
                  (AppDimensions.paddingL * (effectiveCrossAxisCount - 1))) / effectiveCrossAxisCount;
              
              final cardHeight = cardWidth / effectiveAspectRatio;
              
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: effectiveCrossAxisCount,
                  childAspectRatio: effectiveAspectRatio,
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
                    height: cardHeight,
                  );
                },
              );
            }
          ),
        ],
      ),
    );
  }
}

// Include the FeatureCard widget to ensure compatibility
class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  const FeatureCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.description,
    this.onTap,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon container with fixed size
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingM),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.green.shade700,
                    size: 28,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingM),
                // Title with limited lines
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppDimensions.paddingS),
                // Description uses remaining space
                Expanded(
                  child: Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}