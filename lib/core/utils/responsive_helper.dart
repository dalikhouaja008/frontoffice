import 'package:flutter/material.dart';
import '../constants/dimensions.dart';

class ResponsiveHelper {
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < AppDimensions.mobileBreakpoint;
  }
  
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= AppDimensions.mobileBreakpoint && width < AppDimensions.tabletBreakpoint;
  }
  
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= AppDimensions.tabletBreakpoint;
  }
  
  static double getPercentWidth(BuildContext context, double percent) {
    return MediaQuery.of(context).size.width * (percent / 100);
  }
  
  static Widget horizontalSpacerByDevice(BuildContext context) {
    if (isMobile(context)) {
      return const SizedBox(width: AppDimensions.paddingL);
    } else if (isTablet(context)) {
      return const SizedBox(width: AppDimensions.paddingXL);
    } else {
      return const SizedBox(width: AppDimensions.paddingXXL);
    }
  }
  
  static double getContentMaxWidth(BuildContext context) {
    if (isMobile(context)) {
      return MediaQuery.of(context).size.width * 0.9;
    } else {
      return 1200.0; // Max content width for large screens
    }
  }
}