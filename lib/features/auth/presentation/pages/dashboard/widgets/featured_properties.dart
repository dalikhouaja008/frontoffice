import 'package:flutter/material.dart';
import 'package:the_boost/core/constants/colors.dart';
import 'package:the_boost/core/constants/dimensions.dart';
import 'package:the_boost/core/utils/responsive_helper.dart';
import 'package:the_boost/features/auth/presentation/widgets/buttons/app_button.dart';
import '../../../../domain/entities/property.dart';

class FeaturedProperties extends StatelessWidget {
  final List<Property> properties;

  const FeaturedProperties({
    Key? key,
    required this.properties,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    
    return properties.isEmpty
        ? const Center(
            child: Text(
              "No featured properties available",
              style: TextStyle(
                color: Colors.black54,
              ),
            ),
          )
        : isMobile
            ? Column(
                children: properties.map((property) => _buildPropertyCard(context, property)).toList(),
              )
            : Row(
                children: properties.map((property) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingS),
                      child: _buildPropertyCard(context, property),
                    ),
                  );
                }).toList(),
              );
  }

  Widget _buildPropertyCard(BuildContext context, Property property) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingL),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Property image
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppDimensions.radiusM),
              ),
              image: property.imageUrl.isNotEmpty
                  ? DecorationImage(
                      image: AssetImage(property.imageUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: property.imageUrl.isEmpty
                ? Center(
                    child: Icon(
                      Icons.image,
                      color: Colors.grey[400],
                      size: 48,
                    ),
                  )
                : null,
          ),
          
          // Property details
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingS,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundGreen,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    property.category,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingS),
                Text(
                  property.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  property.location,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingM),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Min Investment",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                        Text(
                          "\$${property.minInvestment.toInt()}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          "Expected Return",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                        Text(
                          "${property.projectedReturn}%",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.paddingL),
                AppButton(
                  text: "Invest Now",
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/property-details',
                      arguments: property.id,
                    );
                  },
                  isFullWidth: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}