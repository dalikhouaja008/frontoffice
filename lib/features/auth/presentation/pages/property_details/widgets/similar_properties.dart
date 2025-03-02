// presentation/pages/property_details/widgets/similar_properties.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_boost/core/constants/dimensions.dart';
import 'package:the_boost/core/constants/text_styles.dart';
import '../../../../domain/entities/property.dart';
import '../../../bloc/property_controller.dart';

class SimilarProperties extends StatelessWidget {
  final String currentPropertyId;
  final String category;

  const SimilarProperties({
    Key? key,
    required this.currentPropertyId,
    required this.category,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final propertyController = Provider.of<PropertyController>(context);
    
    // Get similar properties (same category, excluding current property)
    final similarProperties = propertyController.properties
        .where((p) => p.category == category && p.id != currentPropertyId)
        .take(3)
        .toList();
    
    if (similarProperties.isEmpty) {
      return SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Similar Properties",
          style: AppTextStyles.h4,
        ),
        SizedBox(height: AppDimensions.paddingM),
        Container(
          height: 300,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: similarProperties.length,
            itemBuilder: (context, index) {
              final property = similarProperties[index];
              return _buildPropertyCard(context, property);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPropertyCard(BuildContext context, Property property) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacementNamed(
          context,
          '/property-details',
          arguments: property.id,
        );
      },
      child: Container(
        width: 280,
        margin: EdgeInsets.only(right: AppDimensions.paddingL),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 3),
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
                borderRadius: BorderRadius.vertical(
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
              padding: EdgeInsets.all(AppDimensions.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.title,
                    style: TextStyle(
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
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(height: AppDimensions.paddingM),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Min Investment",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                          Text(
                            "\$${property.minInvestment.toInt()}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "Expected Return",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                          Text(
                            "${property.projectedReturn}%",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}