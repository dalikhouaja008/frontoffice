// lib/features/auth/presentation/pages/dashboard/widgets/featured_properties.dart
import 'package:flutter/material.dart';
import 'package:the_boost/core/constants/colors.dart';
import 'package:the_boost/core/constants/dimensions.dart';
import 'package:the_boost/core/utils/responsive_helper.dart';
import 'package:the_boost/features/auth/data/models/land_model.dart';
import 'package:the_boost/features/auth/presentation/widgets/buttons/app_button.dart';
import 'package:the_boost/features/auth/domain/entities/property.dart';

class FeaturedProperties extends StatelessWidget {
  final List<Land> lands;

  const FeaturedProperties({
    Key? key,
    required this.lands,
  }) : super(key: key);

  List<Property> _mapLandsToProperties() {
    return lands.where((land) => land.status == LandValidationStatus.VALIDATED).map((land) {
      final tokenPrice = land.totalTokens != null && land.totalTokens! > 0 
          ? land.totalPrice / land.totalTokens! 
          : 0.0;
      return Property(
        id: land.id,
        title: land.title,
        location: land.location,
        category: land.landtype.toString().split('.').last,
        minInvestment: tokenPrice,
        tokenPrice: tokenPrice,
        totalValue: land.totalPrice,
        projectedReturn: 20.0, // Static for now
        riskLevel: 'Medium', // Static for now
        availableTokens: land.totalTokens ?? 0,
        fundingPercentage: 50.0, // Static for now
        imageUrl: land.imageCIDs.isNotEmpty ? land.imageCIDs.first : '',
        isFeatured: true,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final properties = _mapLandsToProperties();

    return Container(
      margin: const EdgeInsets.only(top: AppDimensions.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(AppDimensions.paddingL),
            child: Text(
              "Featured Properties",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          properties.isEmpty
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
                      children: properties
                          .map((property) => _buildPropertyCard(context, property))
                          .toList(),
                    )
                  : Row(
                      children: properties.map((property) {
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppDimensions.paddingS),
                            child: _buildPropertyCard(context, property),
                          ),
                        );
                      }).toList(),
                    ),
        ],
      ),
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
          Stack(
            children: [
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
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    "${property.fundingPercentage.toStringAsFixed(0)}% Funded",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        property.category.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingS,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        property.riskLevel,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  ],
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
                const SizedBox(height: 4),
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
                          "${property.minInvestment.toStringAsFixed(2)} €",
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
                const SizedBox(height: AppDimensions.paddingS),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Token Price",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                        Text(
                          "${property.tokenPrice.toStringAsFixed(2)} €",
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
                          "Available Tokens",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                        Text(
                          "${property.availableTokens}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
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
                      '/land-details',
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