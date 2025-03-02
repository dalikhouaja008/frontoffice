import 'package:flutter/material.dart';
import 'package:the_boost/core/constants/colors.dart';
import 'package:the_boost/core/constants/dimensions.dart';
import 'package:the_boost/core/utils/responsive_helper.dart';

enum SectionBackground { white, light, primary }

class SectionContainer extends StatelessWidget {
  final Widget child;
  final SectionBackground background;
  final EdgeInsetsGeometry? padding;
  final bool useContentWidthConstraint;

  const SectionContainer({
    Key? key,
    required this.child,
    this.background = SectionBackground.white,
    this.padding,
    this.useContentWidthConstraint = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final defaultPadding = EdgeInsets.symmetric(
      horizontal: isMobile ? AppDimensions.paddingL : AppDimensions.paddingXXL,
      vertical: AppDimensions.paddingSection,
    );

    return Container(
      width: double.infinity,
      color: _getBackgroundColor(),
      child: Padding(
        padding: padding ?? defaultPadding,
        child: Center(
          child: Container(
            constraints: useContentWidthConstraint
                ? BoxConstraints(maxWidth: ResponsiveHelper.getContentMaxWidth(context))
                : null,
            child: child,
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (background) {
      case SectionBackground.white:
        return Colors.white;
      case SectionBackground.light:
        return AppColors.backgroundLight;
      case SectionBackground.primary:
        return AppColors.primary;
    }
  }
}