import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';

import '../../../../../core/services/prop_service.dart';
import '../../../../../core/utils/string_utils.dart';
import '../../../data/models/property/valuation_result.dart';
import 'package:the_boost/core/constants/colors.dart';

class ValuationScreen extends StatefulWidget {
  final ApiService apiService;
  final LatLng initialPosition;
  final double? prefilledArea;
  final String? prefilledZoning;
  final bool isExpanded;

  ValuationScreen({
    required this.apiService,
    required this.initialPosition,
    this.prefilledArea,
    this.prefilledZoning,
    this.isExpanded = true,
  });

  @override
  _ValuationScreenState createState() => _ValuationScreenState();
}

class _ValuationScreenState extends State<ValuationScreen> with SingleTickerProviderStateMixin {
  final Completer<GoogleMapController> _controller = Completer();
  final TextEditingController _areaController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  late LatLng _selectedPosition;
  String _selectedZoning = 'residential';
  bool _nearWater = false;
  bool _roadAccess = true;
  bool _utilities = true;
  
  bool _isLoading = false;
  bool _isMapExpanded = false;
  String _errorMessage = '';
  ValuationResult? _valuationResult;
  Map<String, dynamic>? _ethPriceData;
  String _selectedCurrency = 'ETH';
  bool _showingInputs = true;
  
  // Animation controllers
  late AnimationController _mapSizeController;
  late Animation<double> _mapSizeAnimation;
  
  // UI customization settings
  final double _defaultMapHeight = 300.0;
  final double _expandedMapHeight = 500.0;
  final primaryColor = AppColors.primary;
  
  @override
  void initState() {
    super.initState();
    _selectedPosition = widget.initialPosition;
    
    if (widget.prefilledArea != null) {
      _areaController.text = widget.prefilledArea!.toString();
    }
    
    if (widget.prefilledZoning != null && widget.prefilledZoning!.isNotEmpty) {
      _selectedZoning = widget.prefilledZoning!;
    }
    
    _fetchEthPrice();
    
    // Initialize animation controllers
    _mapSizeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _mapSizeAnimation = Tween<double>(
      begin: _defaultMapHeight,
      end: _expandedMapHeight,
    ).animate(CurvedAnimation(
      parent: _mapSizeController,
      curve: Curves.easeInOut,
    ));
    
    _mapSizeController.addListener(() {
      setState(() {});
    });
  }
  
  Future<void> _fetchEthPrice() async {
    try {
      final priceData = await widget.apiService.getEthPrice();
      if (mounted) {
        setState(() {
          _ethPriceData = priceData;
        });
      }
    } catch (e) {
      print('Error fetching ETH price: $e');
    }
  }
  
  @override
  void dispose() {
    _areaController.dispose();
    _mapSizeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  void _toggleMapSize() {
    setState(() {
      _isMapExpanded = !_isMapExpanded;
    });
    
    if (_isMapExpanded) {
      _mapSizeController.forward();
    } else {
      _mapSizeController.reverse();
    }
  }
  
  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }
  
  void _onMapTap(LatLng position) {
    setState(() {
      _selectedPosition = position;
      _updateMarker();
    });
  }
  
  void _updateMarker() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLng(_selectedPosition));
  }
  
  Future<void> _calculateLandValue() async {
    if (_areaController.text.isEmpty) {
      _showInfoSnackBar('Please enter land area', isError: true);
      return;
    }
    
    final double? area = double.tryParse(_areaController.text);
    if (area == null || area <= 0) {
      _showInfoSnackBar('Please enter a valid land area', isError: true);
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _valuationResult = null;
    });
    
    try {
      final result = await widget.apiService.estimateLandValue(
        position: _selectedPosition,
        area: area,
        zoning: _selectedZoning,
        nearWater: _nearWater,
        roadAccess: _roadAccess,
        utilities: _utilities,
      );
      
      setState(() {
        _valuationResult = result;
        _isLoading = false;
        _showingInputs = false;
      });
      
      // Smooth scroll to results after a short delay
      Future.delayed(Duration(milliseconds: 300), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: Duration(milliseconds: 800),
            curve: Curves.easeOutQuint,
          );
        }
      });
      
      // Collapse map for better focus on results
      if (_isMapExpanded) {
        _toggleMapSize();
      }
      
      _showInfoSnackBar('Valuation complete! Scroll to view detailed results.');
    } catch (e) {
      setState(() {
        _errorMessage = 'Error calculating value: $e';
        _isLoading = false;
      });
      _showInfoSnackBar('Error calculating value', isError: true);
    }
  }

  void _showInfoSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.info_outline,
              color: Colors.white,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade700 : primaryColor,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: Duration(seconds: isError ? 6 : 3),
        action: isError ? SnackBarAction(
          label: 'DISMISS',
          textColor: Colors.white,
          onPressed: () {},
        ) : null,
      ),
    );
  }
  
  void _resetForm() {
    setState(() {
      _showingInputs = true;
      _valuationResult = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Detect screen size for responsive adjustments
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 1200;
    final isMediumScreen = screenWidth > 768 && screenWidth <= 1200;
    final isSmallScreen = screenWidth <= 768;

    return Scaffold(
      body: Column(
        children: [
          // Map section
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            height: _mapSizeAnimation.value,
            curve: Curves.easeInOut,
            child: Stack(
              children: [
                // Map
                GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _selectedPosition,
                    zoom: 15,
                  ),
                  markers: {
                    Marker(
                      markerId: MarkerId('selected_position'),
                      position: _selectedPosition,
                      infoWindow: InfoWindow(title: 'Selected Land'),
                    ),
                  },
                  onTap: _onMapTap,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                ),
                
                // Custom map controls
                Positioned(
                  right: 16,
                  bottom: 16,
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
                              _selectedPosition,
                              15,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                
                // Map resize button
                Positioned(
                  right: 16,
                  top: 16,
                  child: _buildMapControlButton(
                    icon: _isMapExpanded ? Icons.fullscreen_exit : Icons.fullscreen,
                    tooltip: _isMapExpanded ? 'Shrink Map' : 'Expand Map',
                    onPressed: _toggleMapSize,
                  ),
                ),
                
                // Location info
                Positioned(
                  left: 16,
                  top: 16,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                          color: primaryColor,
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Selected Location',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            Text(
                              '${_selectedPosition.latitude.toStringAsFixed(5)}, ${_selectedPosition.longitude.toStringAsFixed(5)}',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Information section - scrollable content
          Expanded(
            child: Stack(
              children: [
                SingleChildScrollView(
                  controller: _scrollController,
                  padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
                  child: Column(
                    children: [
                      // Always show results if available
                      if (_valuationResult != null)
                        _buildValuationResult(_valuationResult!, isLargeScreen, isMediumScreen),
                      
                      // Input form (conditionally shown)
                      AnimatedSwitcher(
                        duration: Duration(milliseconds: 300),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SizeTransition(
                              sizeFactor: animation,
                              child: child,
                            ),
                          );
                        },
                        child: _showingInputs
                          ? _buildInputForm(isLargeScreen, isMediumScreen)
                          : SizedBox.shrink(),
                      ),
                      
                      // If we have results but inputs are hidden, show a button to edit inputs
                      if (_valuationResult != null && !_showingInputs)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: OutlinedButton.icon(
                            icon: Icon(Icons.edit),
                            label: Text('Edit Inputs'),
                            onPressed: () {
                              setState(() {
                                _showingInputs = true;
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              foregroundColor: primaryColor,
                              side: BorderSide(color: primaryColor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              textStyle: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                
                // Error message overlay
                if (_errorMessage.isNotEmpty)
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.shade100.withOpacity(0.5),
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade700, size: 24),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Error',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red.shade700,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  _errorMessage,
                                  style: TextStyle(
                                    color: Colors.red.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () {
                              setState(() {
                                _errorMessage = '';
                              });
                            },
                            color: Colors.red.shade700,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMapControlButton({required IconData icon, required String tooltip, required VoidCallback onPressed}) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: 40,
        height: 40,
        margin: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          padding: EdgeInsets.zero,
          icon: Icon(icon, size: 20),
          onPressed: onPressed,
          color: primaryColor,
        ),
      ),
    );
  }
  
  Widget _buildInputForm(bool isLargeScreen, bool isMediumScreen) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.real_estate_agent,
                    size: 28,
                    color: primaryColor,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Land Valuation Calculator',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Enter land details to estimate its market value',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            Divider(height: 40),
            
            // Land details section - responsive layout for larger screens
            isLargeScreen || isMediumScreen
                ? _buildTwoColumnInputs()
                : _buildSingleColumnInputs(),
            
            SizedBox(height: 24),
            
            // Land Features Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Land Features',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Select features that apply to this property',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 16),
                
                // Feature cards in a row for larger screens, column for smaller
                isLargeScreen || isMediumScreen
                    ? Row(
                        children: [
                          Expanded(
                            child: _buildFeatureToggleCard(
                              title: 'Water Access',
                              description: 'Property is near a body of water',
                              icon: Icons.water,
                              isActive: _nearWater,
                              onToggle: (value) {
                                setState(() {
                                  _nearWater = value;
                                });
                              },
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: _buildFeatureToggleCard(
                              title: 'Road Access',
                              description: 'Property has road access',
                              icon: Icons.add_road,
                              isActive: _roadAccess,
                              onToggle: (value) {
                                setState(() {
                                  _roadAccess = value;
                                });
                              },
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: _buildFeatureToggleCard(
                              title: 'Utilities',
                              description: 'Water, electricity, and other utilities',
                              icon: Icons.electrical_services,
                              isActive: _utilities,
                              onToggle: (value) {
                                setState(() {
                                  _utilities = value;
                                });
                              },
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          _buildFeatureToggleCard(
                            title: 'Water Access',
                            description: 'Property is near a body of water',
                            icon: Icons.water,
                            isActive: _nearWater,
                            onToggle: (value) {
                              setState(() {
                                _nearWater = value;
                              });
                            },
                          ),
                          SizedBox(height: 12),
                          _buildFeatureToggleCard(
                            title: 'Road Access',
                            description: 'Property has road access',
                            icon: Icons.add_road,
                            isActive: _roadAccess,
                            onToggle: (value) {
                              setState(() {
                                _roadAccess = value;
                              });
                            },
                          ),
                          SizedBox(height: 12),
                          _buildFeatureToggleCard(
                            title: 'Utilities',
                            description: 'Water, electricity, and other utilities',
                            icon: Icons.electrical_services,
                            isActive: _utilities,
                            onToggle: (value) {
                              setState(() {
                                _utilities = value;
                              });
                            },
                          ),
                        ],
                      ),
              ],
            ),
            
            SizedBox(height: 32),
            
            // Calculate button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _calculateLandValue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  disabledBackgroundColor: primaryColor.withOpacity(0.5),
                  foregroundColor: Colors.white,
                  textStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calculate, size: 20),
                          SizedBox(width: 10),
                          Text('Calculate Property Value'),
                        ],
                      ),
              ),
            ),
            
            if (_ethPriceData != null)
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.currency_exchange, size: 16, color: Colors.blue.shade700),
                    SizedBox(width: 8),
                    Text(
                      'Current ETH: ${_ethPriceData!["ethPriceTND"].toStringAsFixed(2)} TND',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTwoColumnInputs() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left column - Area input
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Land Area',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _areaController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter area in square feet',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: primaryColor, width: 2),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  suffixText: 'sq ft',
                  prefixIcon: Icon(Icons.area_chart),
                ),
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
        
        SizedBox(width: 24),
        
        // Right column - Zoning dropdown
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Zoning Type',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              SizedBox(height: 8),
              Container(
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedZoning,
                    isExpanded: true,
                    icon: Icon(Icons.arrow_drop_down, color: primaryColor),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade800,
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'residential',
                        child: _buildZoningDropdownItem(
                          'Residential',
                          Icons.home,
                          Colors.blue.shade700,
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'commercial',
                        child: _buildZoningDropdownItem(
                          'Commercial',
                          Icons.storefront,
                          Colors.amber.shade700,
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'agricultural',
                        child: _buildZoningDropdownItem(
                          'Agricultural',
                          Icons.grass,
                          Colors.green.shade700,
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'industrial',
                        child: _buildZoningDropdownItem(
                          'Industrial',
                          Icons.factory,
                          Colors.red.shade700,
                        ),
                      ),
                    ],
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedZoning = newValue;
                        });
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildSingleColumnInputs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Land Area',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: _areaController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Enter area in square feet',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: primaryColor, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            suffixText: 'sq ft',
            prefixIcon: Icon(Icons.area_chart),
          ),
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 16),
        Text(
          'Zoning Type',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedZoning,
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down, color: primaryColor),
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade800,
              ),
              items: [
                DropdownMenuItem(
                  value: 'residential',
                  child: _buildZoningDropdownItem(
                    'Residential',
                    Icons.home,
                    Colors.blue.shade700,
                  ),
                ),
                DropdownMenuItem(
                  value: 'commercial',
                  child: _buildZoningDropdownItem(
                    'Commercial',
                    Icons.storefront,
                    Colors.amber.shade700,
                  ),
                ),
                DropdownMenuItem(
                  value: 'agricultural',
                  child: _buildZoningDropdownItem(
                    'Agricultural',
                    Icons.grass,
                    Colors.green.shade700,
                  ),
                ),
                DropdownMenuItem(
                  value: 'industrial',
                  child: _buildZoningDropdownItem(
                    'Industrial',
                    Icons.factory,
                    Colors.red.shade700,
                  ),
                ),
              ],
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedZoning = newValue;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildZoningDropdownItem(String text, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        SizedBox(width: 12),
        Text(text),
      ],
    );
  }
  
  Widget _buildFeatureToggleCard({
    required String title,
    required String description,
    required IconData icon,
    required bool isActive,
    required Function(bool) onToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? primaryColor.withOpacity(0.7) : Colors.grey.shade300,
          width: isActive ? 2 : 1,
        ),
        color: isActive ? primaryColor.withOpacity(0.1) : Colors.white,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            onToggle(!isActive);
          },
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive ? primaryColor.withOpacity(0.2) : Colors.grey.shade100,
                  ),
                  child: Icon(
                    icon,
                    color: isActive ? primaryColor : Colors.grey.shade600,
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isActive ? primaryColor : Colors.grey.shade800,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: isActive,
                  onChanged: onToggle,
                  activeColor: primaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildValuationResult(ValuationResult result, bool isLargeScreen, bool isMediumScreen) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            primaryColor.withOpacity(0.7),
            primaryColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with currency selection
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.real_estate_agent,
                    color: primaryColor,
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Property Value Estimate',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Based on ${result.comparables.length} comparable properties',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Currency toggle
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: ToggleButtons(
                    constraints: BoxConstraints(minWidth: 60, minHeight: 36),
                    direction: Axis.horizontal,
                    borderRadius: BorderRadius.circular(30),
                    selectedColor: primaryColor,
                    fillColor: Colors.white,
                    textStyle: TextStyle(fontWeight: FontWeight.w600),
                    color: Colors.white.withOpacity(0.9),
                    selectedBorderColor: Colors.transparent,
                    borderColor: Colors.transparent,
                    children: [
                      Text('ETH'),
                      Text('TND'),
                      Text('USD'),
                    ],
                    isSelected: [
                      _selectedCurrency == 'ETH',
                      _selectedCurrency == 'TND',
                      _selectedCurrency == 'USD',
                    ],
                    onPressed: (index) {
                      setState(() {
                        _selectedCurrency = ['ETH', 'TND', 'USD'][index];
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Value display
          Container(
            padding: EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            child: Column(
              children: [
                _buildValueDisplay(result),
                SizedBox(height: 24),
                
                // Property info summary
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildPropertyInfoTile(
                              'Location',
                              result.location.address,
                              Icons.location_on,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: _buildPropertyInfoTile(
                              'Land Area',
                              '${result.valuation.areaInSqFt.toStringAsFixed(0)} sq ft',
                              Icons.crop_square,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildPropertyInfoTile(
                              'Price/sq ft',
                              _formatPricePerSqFt(result.valuation),
                              Icons.price_change,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: _buildPropertyInfoTile(
                              'Zoning',
                              StringUtils.capitalizeFirst(result.valuation.zoning),
                              Icons.app_registration,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Bottom action buttons
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton.icon(
                  icon: Icon(Icons.refresh),
                  label: Text('New Valuation'),
                  onPressed: _resetForm,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white.withOpacity(0.5)),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.share),
                  label: Text('Share Results'),
                  onPressed: () {
                    _showInfoSnackBar('Share functionality would be implemented here');
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: primaryColor,
                    backgroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyInfoTile(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 16,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildValueDisplay(ValuationResult result) {
    Widget mainValue;
    Widget secondaryValue;
    
    switch (_selectedCurrency) {
      case 'ETH':
        mainValue = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/ethereum_logo.png',
              width: 40,
              height: 40,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.currency_bitcoin,
                size: 40,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 12),
            Text(
              '${result.valuation.currentEthValue?.toStringAsFixed(4) ?? result.valuation.estimatedValueETH?.toStringAsFixed(4) ?? "N/A"}',
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        );
        secondaryValue = Text(
          '${result.valuation.estimatedValue.toStringAsFixed(0)} TND',
          style: TextStyle(
            fontSize: 22,
            color: Colors.white.withOpacity(0.9),
          ),
        );
        break;
        
      case 'TND':
        mainValue = Text(
          '${result.valuation.estimatedValue.toStringAsFixed(0)} TND',
          style: TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        );
        secondaryValue = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/ethereum_logo.png',
              width: 24,
              height: 24,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.currency_bitcoin,
                size: 24,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            SizedBox(width: 8),
            Text(
              '${result.valuation.currentEthValue?.toStringAsFixed(4) ?? result.valuation.estimatedValueETH?.toStringAsFixed(4) ?? "N/A"} ETH',
              style: TextStyle(
                fontSize: 22,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        );
        break;
        
      case 'USD':
        final ethValue = result.valuation.currentEthValue ?? result.valuation.estimatedValueETH;
        final ethUsdRate = _ethPriceData != null ? _ethPriceData!["ethPriceUSD"] ?? 2400 : 2400;
        final usdValue = ethValue != null ? ethValue * ethUsdRate : null;
        
        mainValue = Text(
          usdValue != null ? '\$${usdValue.toStringAsFixed(2)}' : 'N/A',
          style: TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        );
        secondaryValue = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/ethereum_logo.png',
              width: 24,
              height: 24,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.currency_bitcoin,
                size: 24,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            SizedBox(width: 8),
            Text(
              '${result.valuation.currentEthValue?.toStringAsFixed(4) ?? result.valuation.estimatedValueETH?.toStringAsFixed(4) ?? "N/A"} ETH',
              style: TextStyle(
                fontSize: 22,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        );
        break;
        
      default:
        mainValue = Text('Invalid currency');
        secondaryValue = Text('');
    }
    
    return Column(
      children: [
        mainValue,
        SizedBox(height: 8),
        secondaryValue,
      ],
    );
  }
  
  String _formatPricePerSqFt(ValuationInfo valuation) {
    switch (_selectedCurrency) {
      case 'ETH':
        return '${valuation.avgPricePerSqFtETH?.toStringAsFixed(6) ?? "N/A"} ETH';
      case 'TND':
        return '${valuation.avgPricePerSqFt.toStringAsFixed(2)} TND';
      case 'USD':
        final ethPricePerSqFt = valuation.avgPricePerSqFtETH;
        final ethUsdRate = _ethPriceData != null ? _ethPriceData!["ethPriceUSD"] ?? 2400 : 2400;
        final usdPricePerSqFt = ethPricePerSqFt != null ? ethPricePerSqFt * ethUsdRate : null;
        return usdPricePerSqFt != null ? '\$${usdPricePerSqFt.toStringAsFixed(2)}' : 'N/A';
      default:
        return 'N/A';
    }
  }
}