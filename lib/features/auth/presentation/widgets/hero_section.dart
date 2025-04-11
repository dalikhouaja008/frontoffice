// presentation/widgets/hero_section.dart
import 'package:flutter/material.dart';
import 'package:the_boost/core/constants/colors.dart';
import 'package:the_boost/core/constants/dimensions.dart';
import 'package:the_boost/core/constants/text_styles.dart';
import 'package:the_boost/core/utils/responsive_helper.dart';
import 'package:the_boost/features/auth/presentation/widgets/buttons/app_button.dart';

import '../bloc/routes.dart';


class HeroSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? primaryButtonText;
  final String? secondaryButtonText;
  final VoidCallback? onPrimaryButtonPressed;
  final VoidCallback? onSecondaryButtonPressed;
  final Widget? image;
  final bool useGradientBackground;

  const HeroSection({
    Key? key,
    required this.title,
    required this.subtitle,
    this.primaryButtonText,
    this.secondaryButtonText,
    this.onPrimaryButtonPressed,
    this.onSecondaryButtonPressed,
    this.image,
    this.useGradientBackground = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? AppDimensions.paddingL : AppDimensions.paddingXXL, 
        vertical: isMobile ? AppDimensions.paddingXL : AppDimensions.paddingSection
      ),
      decoration: BoxDecoration(
        gradient: useGradientBackground ? LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            AppColors.backgroundGreen,
          ],
        ) : null,
        color: useGradientBackground ? null : Colors.white,
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: _buildHeroContent(context, isMobile),
            )
          : Row(
              children: _buildHeroContent(context, isMobile),
            ),
    );
  }
  
  List<Widget> _buildHeroContent(BuildContext context, bool isMobile) {
  return [
    Expanded(
      flex: 5,
      child: Column(
        crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: isMobile ? TextAlign.center : TextAlign.left,
            style: AppTextStyles.h1.copyWith(
              fontSize: isMobile ? 32 : 48,
              height: 1.2,
            ),
          ),
          SizedBox(height: 24),
          Text(
            subtitle,
            textAlign: isMobile ? TextAlign.center : TextAlign.left,
            style: AppTextStyles.body1.copyWith(
              fontSize: isMobile ? 16 : 18,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: isMobile ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              if (primaryButtonText != null)
                AppButton(
                  text: primaryButtonText!,
                  onPressed: onPrimaryButtonPressed ?? () {},
                  type: ButtonType.primary,
                ),
              const SizedBox(width: 16),
              if (secondaryButtonText != null)
                AppButton(
                  text: secondaryButtonText!,
                  onPressed: onSecondaryButtonPressed ?? () {},
                  type: ButtonType.outline,
                ),
            ],
          ),
          // Add map button with icon here
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.investmentMap),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: isMobile ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                Icon(
                  Icons.map,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Explore Interactive Map',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    if (!isMobile) const SizedBox(width: 40),
    if (image != null && !isMobile)
      Expanded(
        flex: 5,
        child: image!,
      ),
    if (image != null && isMobile) 
      const SizedBox(height: 40),
    if (image != null && isMobile)
      SizedBox(
        width: double.infinity,
        height: 300,
        child: image,
      ),
  ];
}
}