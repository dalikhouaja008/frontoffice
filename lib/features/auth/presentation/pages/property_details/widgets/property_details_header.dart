// presentation/pages/property_details/widgets/property_details_header.dart
import 'package:flutter/material.dart';
import 'package:the_boost/core/constants/colors.dart';
import 'package:the_boost/core/constants/dimensions.dart';
import 'package:the_boost/core/constants/text_styles.dart';
import 'package:the_boost/core/utils/responsive_helper.dart';
import '../../../../domain/entities/property.dart';

class PropertyDetailsHeader extends StatelessWidget {
  final Property property;

  const PropertyDetailsHeader({
    Key? key,
    required this.property,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return Container(
      width: double.infinity,
      height: isMobile ? 250 : 350,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        image: property.imageUrl.isNotEmpty
            ? DecorationImage(
                image: AssetImage(property.imageUrl),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: Stack(
        children: [
          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
                stops: [0.6, 1.0],
              ),
            ),
          ),
          
          // Property information
          Positioned(
            bottom: AppDimensions.paddingXL,
            left: isMobile ? AppDimensions.paddingL : AppDimensions.paddingXXL,
            right: isMobile ? AppDimensions.paddingL : AppDimensions.paddingXXL,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingS,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    property.category,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: AppDimensions.paddingS),
                Text(
                  property.title,
                  style: AppTextStyles.h2.copyWith(
                    color: Colors.white,
                    fontSize: isMobile ? 24 : 32,
                  ),
                ),
                SizedBox(height: AppDimensions.paddingS),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Colors.white70,
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      property.location,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}