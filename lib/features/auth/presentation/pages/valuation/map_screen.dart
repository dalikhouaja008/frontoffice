import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:the_boost/core/services/prop_service.dart';
import '../../../../../debug_tools.dart';
import '../../../data/models/property/property.dart';
import 'valuation_screen.dart';
import 'package:the_boost/core/constants/colors.dart';
import 'package:the_boost/core/constants/dimensions.dart';

class MapScreen extends StatefulWidget {
  final LatLng initialPosition;
  final ApiService apiService;
  final bool isExpanded;

  MapScreen({
    required this.initialPosition,
    required this.apiService,
    this.isExpanded = true,
  });

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with SingleTickerProviderStateMixin {
  final Completer<GoogleMapController> _controller = Completer();
  final TextEditingController _searchController = TextEditingController();
  
  Set<Marker> _markers = {};
  List<Property> _properties = [];
  bool _isLoading = false;
  String _errorMessage = '';
  double _searchRadius = 5000; // meters
  late LatLng _currentPosition;
  late BitmapDescriptor _propertyIcon;
  int _retryCount = 0;
  
  // Filter state
  bool _isFilterVisible = false;
  String _selectedZoning = 'All';
  double _minPrice = 0;
  double _maxPrice = 10000000;
  bool _showOnlyWithUtilities = false;
  bool _showOnlyWithRoadAccess = false;
  
  // UI Animation controllers
  late AnimationController _animationController;
  late Animation<double> _animation;
  
  final List<String> _zoningOptions = ['All', 'Residential', 'Commercial', 'Agricultural', 'Industrial', 'Mixed-Use'];
  
  @override
  void initState() {
    super.initState();
    _currentPosition = widget.initialPosition;
    _propertyIcon = BitmapDescriptor.defaultMarker;
    _loadCustomMarker();
    _loadPropertiesNearby();
    
    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    // Wait for UI to build, then load map
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // If the map is initially collapsed in widget.isExpanded, start animation from 0
      if (!widget.isExpanded) {
        _animationController.value = 0;
      } else {
        _animationController.value = 1;
      }
    });
  }

  @override
  void didUpdateWidget(MapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Handle expand/collapse transitions
    if (widget.isExpanded && !oldWidget.isExpanded) {
      _animationController.forward();
    } else if (!widget.isExpanded && oldWidget.isExpanded) {
      _animationController.reverse();
    }
  }

  void _showApiDebugTool() {
    ApiDebugTool.testAllEndpoints(context, widget.apiService.baseUrl);
  }
  
  Future<void> _loadCustomMarker() async {
    setState(() {
      _propertyIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
    });
  }
  
  Future<void> _loadPropertiesNearby() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
    }
    
    try {
      print('Loading properties near ${_currentPosition.latitude}, ${_currentPosition.longitude}');
      
      final properties = await widget.apiService.getNearbyProperties(
        _currentPosition,
        radius: _searchRadius,
      );
      
      if (mounted) {
        setState(() {
          _properties = properties;
          _createMarkers();
          _isLoading = false;
          _retryCount = 0; // Reset retry count on success
        });
      }
      
      // Log success
      print('Successfully loaded ${properties.length} properties');
      
      // If no properties found, show a message but don't retry automatically
      if (properties.isEmpty && mounted) {
        _showSnackBar(
          'No properties found in this area',
          isError: false,
          action: SnackBarAction(
            label: 'Expand Search',
            onPressed: () {
              setState(() {
                _searchRadius = _searchRadius * 2;
              });
              _loadPropertiesNearby();
            },
          )
        );
      }
    } catch (e) {
      print('Error loading properties: $e');
      
      if (mounted) {
        setState(() {
          _errorMessage = 'Error loading properties: $e';
          _isLoading = false;
        });
        
        // Show error message
        _showSnackBar(
          'Error loading properties: $e',
          isError: true,
          action: SnackBarAction(
            label: 'Retry',
            onPressed: _loadPropertiesNearby,
          )
        );
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false, SnackBarAction? action}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        backgroundColor: isError ? Colors.red.shade700 : AppColors.primary,
        duration: Duration(seconds: action != null ? 8 : 3),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        action: action,
      ),
    );
  }
  
  void _createMarkers() {
    final Set<Marker> markers = {};
    
    // Add current position marker
    markers.add(
      Marker(
        markerId: MarkerId('current_position'),
        position: _currentPosition,
        infoWindow: InfoWindow(title: 'Your Location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    );
    
    // Add property markers with ETH prices
    for (final property in _filteredProperties()) {
      markers.add(
        Marker(
          markerId: MarkerId(property.id),
          position: property.location,
          infoWindow: InfoWindow(
            title: property.formatPriceETH(),
            snippet: property.address,
            onTap: () {
              _showPropertyDetails(property);
            },
          ),
          icon: _propertyIcon,
        ),
      );
    }
    
    setState(() {
      _markers = markers;
    });
  }

  // Filter properties based on current filter settings
  List<Property> _filteredProperties() {
    return _properties.where((property) {
      // Filter by zoning
      if (_selectedZoning != 'All' && property.zoning != _selectedZoning) {
        return false;
      }
      
      // Filter by price
      if (property.price < _minPrice || property.price > _maxPrice) {
        return false;
      }
      
      // Filter by utilities
      if (_showOnlyWithUtilities && !property.features.utilities) {
        return false;
      }
      
      // Filter by road access
      if (_showOnlyWithRoadAccess && !property.features.roadAccess) {
        return false;
      }
      
      return true;
    }).toList();
  }
  
  void _showPropertyDetails(Property property) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: EdgeInsets.only(
          top: MediaQuery.of(context).size.height * 0.05,
          left: MediaQuery.of(context).size.width * 0.05,
          right: MediaQuery.of(context).size.width * 0.05,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: Offset(0, 5),
            ),
          ],
        ),
        height: MediaQuery.of(context).size.height * 0.85,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with close button
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Property Details',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          property.address,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Price section with gradient card
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.shade50,
                            Colors.blue.shade100,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Ethereum Value',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.blue.shade800,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  property.formatPriceETH(),
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.blue.shade200,
                            margin: EdgeInsets.symmetric(horizontal: 20),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'TND Value',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.green.shade800,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '${property.price.toStringAsFixed(0)} TND',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 24),
                    
                    // Location details
                    Text(
                      'Location',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    SizedBox(height: 12),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPropertyAddressRow('Address', property.address),
                          if (property.city != null) _buildPropertyAddressRow('City', property.city!),
                          if (property.state != null) _buildPropertyAddressRow('State', property.state!),
                          if (property.zipCode != null) _buildPropertyAddressRow('Zip Code', property.zipCode!),
                          _buildPropertyAddressRow('Coordinates', 
                            '${property.location.latitude.toStringAsFixed(6)}, ${property.location.longitude.toStringAsFixed(6)}'
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24),

                    // Property details section
                    Text(
                      'Property Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    SizedBox(height: 12),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          _buildPropertyInfoRow(
                            'Area', 
                            property.area != null ? '${property.area!.toStringAsFixed(0)} sq ft' : 'Unknown'
                          ),
                          _buildPropertyInfoRow(
                            'Price/sq ft (ETH)', 
                            property.currentPricePerSqFtETH != null 
                              ? '${property.currentPricePerSqFtETH!.toStringAsFixed(6)} ETH' 
                              : 'Unknown'
                          ),
                          _buildPropertyInfoRow(
                            'Price/sq ft (TND)', 
                            property.pricePerSqFt != null 
                              ? '${property.pricePerSqFt!.toStringAsFixed(2)} TND' 
                              : 'Unknown'
                          ),
                          _buildPropertyInfoRow('Zoning', property.zoning ?? 'Unknown'),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 24),
                    
                    // Features section with visual indicators
                    Text(
                      'Features',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    SizedBox(height: 12),
                    
                    Row(
                      children: [
                        _buildFeatureCard('Water Access', property.features.nearWater),
                        SizedBox(width: 16),
                        _buildFeatureCard('Road Access', property.features.roadAccess),
                        SizedBox(width: 16),
                        _buildFeatureCard('Utilities', property.features.utilities),
                      ],
                    ),
                    
                    SizedBox(height: 32),
                    
                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: Icon(Icons.calculate),
                            label: Text('Value Similar Land'),
                            onPressed: () {
                              Navigator.of(context).pop();
                              _navigateToValuation(property);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              textStyle: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        if (property.sourceUrl != null && property.sourceUrl!.isNotEmpty) ...[
                          SizedBox(width: 16),
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: Icon(Icons.link),
                              label: Text('View Source'),
                              onPressed: () {
                                // In a real app, launch URL
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Would open: ${property.sourceUrl}')),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                side: BorderSide(color: AppColors.primary),
                                padding: EdgeInsets.symmetric(vertical: 16),
                                textStyle: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPropertyAddressRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade800,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPropertyInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade900,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFeatureCard(String feature, bool available) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: available ? Colors.green.shade50 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: available ? Colors.green.shade300 : Colors.grey.shade300,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              available ? Icons.check_circle : Icons.cancel,
              color: available ? Colors.green.shade700 : Colors.grey.shade500,
              size: 24,
            ),
            SizedBox(height: 8),
            Text(
              feature,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: available ? Colors.green.shade800 : Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  void _navigateToValuation(Property? property) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ValuationScreen(
          apiService: widget.apiService,
          initialPosition: property?.location ?? _currentPosition,
          prefilledArea: property?.area,
          prefilledZoning: property?.zoning,
        ),
      ),
    );
  }
  
  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }
  
  void _onMapTap(LatLng position) {
    setState(() {
      _currentPosition = position;
      
      // Add a marker at tapped position
      _markers.removeWhere((marker) => marker.markerId.value == 'selected_position');
      _markers.add(
        Marker(
          markerId: MarkerId('selected_position'),
          position: position,
          infoWindow: InfoWindow(
            title: 'Selected Location',
            snippet: 'Tap to value this land',
            onTap: () {
              _navigateToValuation(null);
            },
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
        ),
      );
    });
  }
  
  Future<void> _searchLocation() async {
    if (_searchController.text.isEmpty) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      final result = await widget.apiService.searchProperties(_searchController.text);
      final geocodedLocation = result['geocodedLocation'];
      final properties = result['properties'] as List<Property>;
      
      final LatLng position = LatLng(
        geocodedLocation['lat'],
        geocodedLocation['lng'],
      );
      
      // Move map to search location
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newLatLngZoom(position, 14));
      
      setState(() {
        _currentPosition = position;
        _properties = properties;
        _createMarkers();
        _isLoading = false;
      });
      
      if (properties.isEmpty) {
        _showSnackBar(
          'No properties found for "${_searchController.text}"',
          action: SnackBarAction(
            label: 'Expand Search',
            onPressed: () {
              setState(() {
                _searchRadius = _searchRadius * 1.5;
              });
              _loadPropertiesNearby();
            },
          )
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error searching location: $e';
        _isLoading = false;
      });
      
      _showSnackBar(
        'Error searching location: $e', 
        isError: true,
        action: SnackBarAction(
          label: 'Retry',
          onPressed: _searchLocation,
        )
      );
    }
  }
  
  void _adjustSearchRadius(double value) {
    setState(() {
      _searchRadius = value;
    });
    _loadPropertiesNearby();
  }
  
  void _toggleFilters() {
    setState(() {
      _isFilterVisible = !_isFilterVisible;
    });
  }
  
  void _applyFilters() {
    _createMarkers();
    setState(() {
      _isFilterVisible = false;
    });
    
    final filteredCount = _filteredProperties().length;
    final totalCount = _properties.length;
    
    if (filteredCount < totalCount) {
      _showSnackBar(
        'Showing $filteredCount of $totalCount properties',
        action: SnackBarAction(
          label: 'Reset Filters',
          onPressed: _resetFilters,
        )
      );
    }
  }
  
  void _resetFilters() {
    setState(() {
      _selectedZoning = 'All';
      _minPrice = 0;
      _maxPrice = 10000000;
      _showOnlyWithUtilities = false;
      _showOnlyWithRoadAccess = false;
    });
    _createMarkers();
  }

  @override
  Widget build(BuildContext context) {
    // Determine if we're on a web/large screen
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 1200;
    final isMediumScreen = screenWidth > 768 && screenWidth <= 1200;
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          color: Colors.grey.shade50,
          child: Column(
            children: [
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                height: _isFilterVisible ? null : 0,
                child: _isFilterVisible ? _buildFilterPanel() : null,
              ),
              
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                height: _animation.value * 64 + (1 - _animation.value) * 64,
                child: _buildSearchBar(),
              ),
              
              if (_isLoading)
                LinearProgressIndicator(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  color: AppColors.primary,
                ),
              
              if (_errorMessage.isNotEmpty)
                Container(
                  color: Colors.red.shade50,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage,
                          style: TextStyle(color: Colors.red.shade800),
                        ),
                      ),
                      TextButton(
                        onPressed: _loadPropertiesNearby,
                        child: Text('RETRY'),
                      )
                    ],
                  ),
                ),
              
              Expanded(
                child: Stack(
                  children: [
                    // Main map
                    ClipRRect(
                      borderRadius: widget.isExpanded ? BorderRadius.zero : BorderRadius.circular(12),
                      child: GoogleMap(
                        onMapCreated: _onMapCreated,
                        initialCameraPosition: CameraPosition(
                          target: widget.initialPosition,
                          zoom: 14,
                        ),
                        markers: _markers,
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                        onTap: _onMapTap,
                        zoomControlsEnabled: false, // We'll add custom controls
                      ),
                    ),
                    
                    // Custom map controls positioned at the right side for web
                    Positioned(
                      right: 16,
                      bottom: 100,
                      child: Column(
                        children: [
                          _buildMapControlButton(
                            icon: Icons.add,
                            tooltip: 'Zoom In',
                            onPressed: () async {
                              final controller = await _controller.future;
                              controller.animateCamera(CameraUpdate.zoomIn());
                            },
                          ),
                          SizedBox(height: 8),
                          _buildMapControlButton(
                            icon: Icons.remove,
                            tooltip: 'Zoom Out',
                            onPressed: () async {
                              final controller = await _controller.future;
                              controller.animateCamera(CameraUpdate.zoomOut());
                            },
                          ),
                          SizedBox(height: 8),
                          _buildMapControlButton(
                            icon: Icons.my_location,
                            tooltip: 'My Location',
                            onPressed: () async {
                              final controller = await _controller.future;
                              controller.animateCamera(
                                CameraUpdate.newLatLngZoom(
                                  _currentPosition,
                                  14,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    
                    // Map legend/status in top right corner
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.location_on,
                              color: AppColors.primary,
                              size: 16,
                            ),
                            SizedBox(width: 8),
                            Text(
                              '${_filteredProperties().length} properties',
                              style: TextStyle(
                                color: Colors.grey.shade800,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                height: _animation.value * 64 + (1 - _animation.value) * 64,
                color: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    // Left side: Status and radius control
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          Icon(
                            Icons.travel_explore,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Search radius: ${(_searchRadius / 1000).toStringAsFixed(1)} km',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Container(
                            width: isLargeScreen ? 200 : (isMediumScreen ? 150 : 100),
                            child: Slider(
                              value: _searchRadius,
                              min: 1000,
                              max: 10000,
                              divisions: 9,
                              activeColor: AppColors.primary,
                              inactiveColor: AppColors.primary.withOpacity(0.2),
                              onChanged: (value) {
                                setState(() {
                                  _searchRadius = value;
                                });
                              },
                              onChangeEnd: _adjustSearchRadius,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 16),
                    // Right side: Action buttons
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        OutlinedButton.icon(
                          icon: Icon(Icons.tune),
                          label: Text('Filters'),
                          onPressed: _toggleFilters,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: BorderSide(color: AppColors.primary),
                          ),
                        ),
                        SizedBox(width: 12),
                        ElevatedButton.icon(
                          icon: Icon(Icons.add_location_alt),
                          label: Text('Value Selected Location'),
                          onPressed: () {
                            _navigateToValuation(null);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
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
      },
    );
  }
  
  Widget _buildMapControlButton({required IconData icon, required String tooltip, required VoidCallback onPressed}) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon),
        onPressed: onPressed,
        tooltip: tooltip,
        color: AppColors.primary,
        iconSize: 20,
      ),
    );
  }
  
  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by address, city, or region',
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
                style: TextStyle(
                  fontSize: 16,
                ),
                onSubmitted: (_) => _searchLocation(),
              ),
            ),
          ),
          SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: _searchLocation,
            icon: Icon(Icons.search),
            label: Text('Search'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              textStyle: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.refresh, color: AppColors.primary),
            onPressed: _loadPropertiesNearby,
            tooltip: 'Refresh properties',
          ),
        ],
      ),
    );
  }
  
  Widget _buildFilterPanel() {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.filter_list, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'Filter Properties',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              Spacer(),
              TextButton(
                onPressed: _resetFilters,
                child: Text('Reset'),
              ),
              SizedBox(width: 8),
              ElevatedButton(
                onPressed: _applyFilters,
                child: Text('Apply'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
              SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: _toggleFilters,
                tooltip: 'Close filters',
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Zoning filter
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Zoning Type',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: DropdownButton<String>(
                        value: _selectedZoning,
                        isExpanded: true,
                        underline: SizedBox(),
                        items: _zoningOptions.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedZoning = newValue!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16),
              // Price range filter
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Price Range (TND)',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    RangeSlider(
                      values: RangeValues(_minPrice, _maxPrice),
                      min: 0,
                      max: 10000000,
                      divisions: 20,
                      labels: RangeLabels(
                        '${_minPrice.toStringAsFixed(0)} TND',
                        '${_maxPrice.toStringAsFixed(0)} TND',
                      ),
                      activeColor: AppColors.primary,
                      inactiveColor: AppColors.primary.withOpacity(0.2),
                      onChanged: (RangeValues values) {
                        setState(() {
                          _minPrice = values.start;
                          _maxPrice = values.end;
                        });
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_minPrice.toStringAsFixed(0)} TND',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          '${_maxPrice.toStringAsFixed(0)} TND',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16),
              // Features filter
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Features',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Checkbox(
                          value: _showOnlyWithUtilities,
                          activeColor: AppColors.primary,
                          onChanged: (value) {
                            setState(() {
                              _showOnlyWithUtilities = value!;
                            });
                          },
                        ),
                        Text('Has Utilities'),
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: _showOnlyWithRoadAccess,
                          activeColor: AppColors.primary,
                          onChanged: (value) {
                            setState(() {
                              _showOnlyWithRoadAccess = value!;
                            });
                          },
                        ),
                        Text('Has Road Access'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}