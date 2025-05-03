import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:the_boost/core/constants/colors.dart';
import 'package:the_boost/features/auth/data/models/land_model.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:cached_network_image/cached_network_image.dart';

class LandMapCarouselView extends StatefulWidget {
  final Land land;
  final bool isFullScreen;

  const LandMapCarouselView({
    Key? key, 
    required this.land, 
    this.isFullScreen = false,
  }) : super(key: key);

  @override
  State<LandMapCarouselView> createState() => _LandMapCarouselViewState();
}

class _LandMapCarouselViewState extends State<LandMapCarouselView> {
  final PageController _pageController = PageController();
  final MapController _mapController = MapController();
  int _currentImageIndex = 0;
  bool _showFullScreen = false;
  bool _mapLoaded = false;

  // Liste des images
  late final List<String> _imageList;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  void _loadImages() {
    _imageList = [];
    
    // Utiliser imageUrls en priorité, sinon imageCIDs
    if (widget.land.imageUrls != null && widget.land.imageUrls!.isNotEmpty) {
      _imageList.addAll(widget.land.imageUrls!);
    } 
    else if (widget.land.imageCIDs != null && widget.land.imageCIDs!.isNotEmpty) {
      _imageList.addAll(widget.land.imageCIDs!);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Vérifier si les coordonnées sont disponibles
    final hasCoordinates = widget.land.latitude != null && widget.land.longitude != null;
    
    return _showFullScreen 
        ? _buildFullScreenCarousel()
        : LayoutBuilder(
            builder: (context, constraints) {
              // Décider de la mise en page en fonction de la largeur
              final isWideScreen = constraints.maxWidth > 700;
              
              if (isWideScreen) {
                return _buildWideLayout(hasCoordinates);
              } else {
                return _buildNarrowLayout(hasCoordinates);
              }
            },
          );
  }
  
  Widget _buildWideLayout(bool hasCoordinates) {
    return Card(
      margin: const EdgeInsets.all(0),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.hardEdge,
      child: Row(
        children: [
          // CARTE (CÔTÉ GAUCHE)
          Expanded(
            flex: 1,
            child: hasCoordinates 
                ? _buildMap()
                : _buildNoMapAvailable(),
          ),
          
          // CAROUSEL (CÔTÉ DROIT)
          Expanded(
            flex: 1,
            child: _imageList.isNotEmpty
                ? _buildCarousel()
                : _buildNoImagesContainer(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNarrowLayout(bool hasCoordinates) {
    return Column(
      children: [
        // CAROUSEL (HAUT)
        SizedBox(
          height: 250,
          child: _imageList.isNotEmpty
              ? _buildCarousel()
              : _buildNoImagesContainer(),
        ),
        
        const SizedBox(height: 16),
        
        // CARTE (BAS)
        SizedBox(
          height: 250,
          child: hasCoordinates 
              ? _buildMap()
              : _buildNoMapAvailable(),
        ),
      ],
    );
  }

  Widget _buildMap() {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            center: LatLng(widget.land.latitude!, widget.land.longitude!),
            zoom: 14.0,
            interactiveFlags: InteractiveFlag.all,
            onMapReady: () {
              setState(() {
                _mapLoaded = true;
              });
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c'],
              userAgentPackageName: 'com.theboost.app',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  width: 50.0,
                  height: 50.0,
                  point: LatLng(widget.land.latitude!, widget.land.longitude!),
                  builder: (ctx) => TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.7, end: 1.0),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: child,
                      );
                    },
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 50,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        
        // Overlay d'information
        Positioned(
          left: 10,
          top: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.land.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.land.landtype != null)
                  Text(
                    'Type: ${_getLandTypeDisplay(widget.land.landtype!)}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ),
        
        // Boutons de contrôle de la carte
        Positioned(
          right: 10,
          bottom: 10,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    final currentZoom = _mapController.zoom;
                    _mapController.move(
                      _mapController.center,
                      currentZoom + 1,
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () {
                    final currentZoom = _mapController.zoom;
                    _mapController.move(
                      _mapController.center,
                      currentZoom - 1,
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.my_location),
                  onPressed: () {
                    _mapController.move(
                      LatLng(widget.land.latitude!, widget.land.longitude!),
                      14.0,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildNoMapAvailable() {
    return Container(
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.map,
            size: 60,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Location Available',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This property has no coordinates',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildCarousel() {
    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentImageIndex = index;
            });
          },
          itemCount: _imageList.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _showFullScreen = true;
                });
              },
              child: Hero(
                tag: 'property_image_$index',
                child: CachedNetworkImage(
                  imageUrl: _imageList[index],
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[200],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline, 
                          color: Colors.grey[400],
                          size: 40
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Failed to load image',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        
        // Navigation arrows if multiple images
        if (_imageList.length > 1) ...[
          // Previous button
          Positioned(
            left: 10,
            top: 0,
            bottom: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  if (_currentImageIndex > 0) {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
          ),
          
          // Next button
          Positioned(
            right: 10,
            top: 0,
            bottom: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  if (_currentImageIndex < _imageList.length - 1) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
        
        // Counter badge
        Positioned(
          top: 15,
          right: 15,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.photo_library,
                  color: Colors.white,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  '${_currentImageIndex + 1}/${_imageList.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Fullscreen button
        Positioned(
          bottom: 15,
          right: 15,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _showFullScreen = true;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.fullscreen,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildNoImagesContainer() {
    return Container(
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            size: 60,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Images Available',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This property has no images yet',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFullScreenCarousel() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Full screen gallery
          PhotoViewGallery.builder(
            itemCount: _imageList.length,
            builder: (context, index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: CachedNetworkImageProvider(_imageList[index]),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
                heroAttributes: PhotoViewHeroAttributes(tag: 'property_image_$index'),
              );
            },
            scrollPhysics: const BouncingScrollPhysics(),
            backgroundDecoration: const BoxDecoration(color: Colors.black),
            pageController: PageController(initialPage: _currentImageIndex),
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            loadingBuilder: (context, event) => Center(
              child: SizedBox(
                width: 30.0,
                height: 30.0,
                child: CircularProgressIndicator(
                  value: event == null
                      ? 0
                      : event.cumulativeBytesLoaded / (event.expectedTotalBytes ?? 1),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
          ),
          
          // Close button
          Positioned(
            top: 40,
            right: 20,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _showFullScreen = false;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
          
          // Image counter
          Positioned(
            top: 40,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_currentImageIndex + 1}/${_imageList.length}',
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
    );
  }
  
  String _getLandTypeDisplay(LandType landType) {
    switch (landType) {
      case LandType.residential:
        return 'Residential';
      case LandType.commercial:
        return 'Commercial';
      case LandType.agricultural:
        return 'Agricultural';
      case LandType.industrial:
        return 'Industrial';
      default:
        return landType.toString().split('.').last;
    }
  }
}