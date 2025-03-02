// presentation/pages/property_details/widgets/property_gallery.dart
import 'package:flutter/material.dart';
import 'package:the_boost/core/constants/dimensions.dart';
import 'package:the_boost/core/constants/text_styles.dart';
import '../../../../domain/entities/property.dart';

class PropertyGallery extends StatelessWidget {
  final Property property;

  const PropertyGallery({
    Key? key,
    required this.property,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // For demonstration, we'll create placeholder images
    // In a real app, these would come from the property entity
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Property Gallery",
          style: AppTextStyles.h4,
          // presentation/pages/property_details/widgets/property_gallery.dart (continued)
        ),
        SizedBox(height: AppDimensions.paddingM),
        Container(
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5, // In a real app, this would be the number of images
            itemBuilder: (context, index) {
              return Container(
                width: 350,
                margin: EdgeInsets.only(right: AppDimensions.paddingM),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  image: property.imageUrl.isNotEmpty && index == 0
                      ? DecorationImage(
                          image: AssetImage(property.imageUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: property.imageUrl.isEmpty || index > 0
                    ? Center(
                        child: Text(
                          "Image ${index + 1}",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : null,
              );
            },
          ),
        ),
      ],
    );
  }
}