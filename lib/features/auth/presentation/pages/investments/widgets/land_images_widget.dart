import 'package:flutter/material.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:the_boost/core/constants/colors.dart';
import 'package:the_boost/features/auth/data/models/land_model.dart';

class LandImagesWidget extends StatefulWidget {
  final Land land;

  const LandImagesWidget({Key? key, required this.land}) : super(key: key);

  @override
  State<LandImagesWidget> createState() => _LandImagesWidgetState();
}

class _LandImagesWidgetState extends State<LandImagesWidget> {
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Utiliser imageUrls en priorité, sinon imageCIDs
    final List<String> imageList = [];
    
    // Ajouter les imageUrls si disponibles
    if (widget.land.imageUrls != null && widget.land.imageUrls!.isNotEmpty) {
      imageList.addAll(widget.land.imageUrls!);
    } 
    // Sinon, utiliser les imageCIDs
    else if (widget.land.imageCIDs != null && widget.land.imageCIDs!.isNotEmpty) {
      imageList.addAll(widget.land.imageCIDs!);
    }
    
    // S'il n'y a pas d'images
    if (imageList.isEmpty) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(child: Text('No Images Available')),
      );
    }
    
    // S'il n'y a qu'une seule image
    if (imageList.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          imageList.first,
          height: 300,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => 
              Container(
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(child: Text('Failed to load image')),
              ),
        ),
      );
    }
    
    // S'il y a plusieurs images, on utilise un slideshow et des miniatures
    return Column(
      children: [
        SizedBox(
          height: 300,
          width: double.infinity,
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: ImageSlideshow(
                  width: double.infinity,
                  height: 300,
                  initialPage: 0,
                  indicatorColor: AppColors.primary,
                  indicatorBackgroundColor: Colors.white,
                  onPageChanged: (value) {
                    setState(() {
                      _currentImageIndex = value;
                    });
                  },
                  autoPlayInterval: 5000,
                  isLoop: true,
                  children: imageList.map((imageUrl) {
                    return Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => 
                          Container(
                            color: Colors.grey[300],
                            child: const Center(child: Text('Failed to load image')),
                          ),
                    );
                  }).toList(),
                ),
              ),
              // Indicateur du nombre d'images
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    '${_currentImageIndex + 1}/${imageList.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Galerie miniatures
        if (imageList.length > 1)
          Container(
            height: 80,
            margin: const EdgeInsets.only(top: 10),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: imageList.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentImageIndex = index;
                    });
                  },
                  child: Container(
                    width: 80,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: _currentImageIndex == index 
                            ? AppColors.primary
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: Image.network(
                        imageList[index],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => 
                            Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.error),
                            ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}