import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:the_boost/core/services/prop_service.dart';
import 'dart:async';

import 'package:the_boost/features/auth/presentation/widgets/app_nav_bar.dart';
import 'package:the_boost/core/constants/colors.dart';
import 'package:the_boost/core/constants/dimensions.dart';
import 'map_screen.dart';
import 'property_list_screen.dart';
import 'valuation_screen.dart';

class LandValuationHomeScreen extends StatefulWidget {
  final ApiService? apiService;
  
  const LandValuationHomeScreen({
    Key? key,
    this.apiService,
  }) : super(key: key);

  @override
  _LandValuationHomeScreenState createState() => _LandValuationHomeScreenState();
}

class _LandValuationHomeScreenState extends State<LandValuationHomeScreen> {
  int _selectedIndex = 0;
  late final ApiService apiService;
  Position? _currentPosition;
  bool _isLoading = true;
  String _errorMessage = '';
  Map<String, dynamic>? _ethPriceData;
  bool _isInitialized = false;
  bool _isSidebarOpen = true;
  bool _isMapExpanded = false;
  bool _isEthBannerVisible = true;

  late List<Widget Function(bool)> _screenBuilders;

  @override
  void initState() {
    super.initState();
    apiService = widget.apiService ?? ApiService();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _determinePosition();
    if (_currentPosition != null) {
      await _fetchEthPrice();
      _initializeScreenBuilders();
    }
  }

  void _initializeScreenBuilders() {
    if (_currentPosition == null) return;
    
    setState(() {
      // Use function builders to pass the expanded state to each screen
      _screenBuilders = [
        (isExpanded) => MapScreen(
          initialPosition: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          apiService: apiService,
          isExpanded: isExpanded,
        ),
        (isExpanded) => PropertyListScreen(
          apiService: apiService,
          initialPosition: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        ),
        (isExpanded) => ValuationScreen(
          apiService: apiService,
          initialPosition: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        ),
      ];
      _isInitialized = true;
    });
  }
  
  Future<void> _fetchEthPrice() async {
    try {
      final priceData = await apiService.getEthPrice();
      if (mounted) {
        setState(() {
          _ethPriceData = priceData;
        });
      }
    } catch (e) {
      print('Error fetching ETH price: $e');
    }
  }

  Future<void> _determinePosition() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Location services are disabled. Please enable them to use this feature.';
            _isLoading = false;
          });
        }
        return;
      }
      
      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            setState(() {
              _errorMessage = 'Location permissions are denied. Please allow location access to use this feature.';
              _isLoading = false;
            });
          }
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Location permissions are permanently denied. Please enable them in your device settings.';
            _isLoading = false;
          });
        }
        return;
      }
      
      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      );
      
      if (mounted) {
        setState(() {
          _currentPosition = position;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error determining position: $e';
          _isLoading = false;
        });
      }
    }
  }

  // Method to toggle sidebar
  void _toggleSidebar() {
    setState(() {
      _isSidebarOpen = !_isSidebarOpen;
    });
  }
  
  // Method to toggle map expansion
  void _toggleMapExpansion() {
    setState(() {
      _isMapExpanded = !_isMapExpanded;
      // If map is expanding to full screen, temporarily hide the ETH price banner
      if (_isMapExpanded) {
        _isEthBannerVisible = false;
      } else {
        _isEthBannerVisible = true;
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColors.primary;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Show loading screen while initializing
    if (_isLoading || (!_isInitialized && _currentPosition != null)) {
      return _buildLoadingScreen(primaryColor);
    }
    
    // Show error screen if there's an error
    if (_errorMessage.isNotEmpty || _currentPosition == null) {
      return _buildErrorScreen(primaryColor);
    }
    
    // Main screen with navigation
    return Scaffold(
      appBar: PreferredSize(
        // Ensure navbar is always large enough regardless of sign-in state
        preferredSize: Size.fromHeight(70),
        child: _buildFixedSizeNavBar(),
      ),
      body: Column(
        children: [
          // ETH Price Banner
          if (_ethPriceData != null && _isEthBannerVisible)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade50, Colors.blue.shade100.withOpacity(0.4)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                border: Border(bottom: BorderSide(color: Colors.blue.shade100, width: 1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.shade200.withOpacity(0.5),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(Icons.currency_bitcoin, size: 20, color: Colors.blue.shade700),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Current ETH Price: ${_ethPriceData!['ethPriceTND'].toStringAsFixed(2)} TND',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _fetchEthPrice,
                    icon: Icon(Icons.refresh, size: 16),
                    label: Text('Refresh'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade50,
                      foregroundColor: Colors.blue.shade700,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      minimumSize: Size.zero,
                      textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          
          // Main content with sidebar
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Web sidebar
                AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  width: _isSidebarOpen ? 280 : 80,
                  child: _buildSidebar(primaryColor),
                ),
                
                // Main content area
                Expanded(
                  child: Stack(
                    children: [
                      // If map is selected, show the dynamic map container
                      if (_selectedIndex == 0)
                        _buildDynamicMapContainer(primaryColor)
                      else
                        // For other screens, show them normally
                        Container(
                          height: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            border: Border(
                              left: BorderSide(color: Colors.grey.shade200),
                            ),
                          ),
                          child: _screenBuilders[_selectedIndex](false),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      
      // Floating button for sidebar toggle
      floatingActionButton: FloatingActionButton(
        mini: false,
        onPressed: _toggleSidebar,
        backgroundColor: Colors.white,
        elevation: 4,
        child: Icon(
          _isSidebarOpen ? Icons.chevron_left : Icons.chevron_right,
          color: primaryColor,
          size: 28,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  // Custom AppNavBar with fixed height to prevent size issues when signed in
  Widget _buildFixedSizeNavBar() {
    return Container(
      height: 70, // Fixed height regardless of sign-in state
      child: AppNavBar(
        currentRoute: '/land-valuation',
      ),
    );
  }

  // Dynamic map container that changes size on interaction
  Widget _buildDynamicMapContainer(Color primaryColor) {
    return Container(
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          left: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Stack(
        children: [
          // The actual map content
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: _isMapExpanded ? double.infinity : 400,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: _isMapExpanded 
                ? BorderRadius.zero 
                : BorderRadius.circular(12),
              boxShadow: _isMapExpanded ? [] : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
              border: _isMapExpanded 
                ? null 
                : Border.all(color: Colors.grey.shade300),
            ),
            margin: _isMapExpanded 
              ? EdgeInsets.zero 
              : EdgeInsets.all(24),
            child: ClipRRect(
              borderRadius: _isMapExpanded 
                ? BorderRadius.zero 
                : BorderRadius.circular(12),
              child: Stack(
                children: [
                  // Map screen
                  MapScreen(
                    initialPosition: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                    apiService: apiService,
                    isExpanded: _isMapExpanded,
                  ),

                  // Overlay for non-expanded state with instructions
                  if (!_isMapExpanded)
                    Positioned.fill(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _toggleMapExpansion,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.center,
                                colors: [
                                  Colors.black.withOpacity(0.5),
                                  Colors.transparent,
                                ],
                                stops: [0.0, 0.5],
                              ),
                            ),
                            alignment: Alignment.bottomCenter,
                            padding: EdgeInsets.all(16),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(30),
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
                                    Icons.touch_app,
                                    color: primaryColor,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "Click to expand map",
                                    style: TextStyle(
                                      color: primaryColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Collapse button for expanded state
                  if (_isMapExpanded)
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        elevation: 4,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(30),
                          onTap: _toggleMapExpansion,
                          child: Container(
                            padding: EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.close_fullscreen,
                                  color: primaryColor,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "Collapse Map",
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Additional content below the map when not expanded
          if (!_isMapExpanded)
            Positioned(
              top: 448, // Just below the map
              left: 0,
              right: 0,
              bottom: 0,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Land valuation summary card
                    Container(
                      padding: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            spreadRadius: 0,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.location_city, color: primaryColor),
                              SizedBox(width: 12),
                              Text(
                                "Land Value Overview",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 24),
                          
                          // Recent valuations or nearby properties
                          Text(
                            "Recent Property Estimates",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          SizedBox(height: 16),
                          
                          // Property cards
                          _buildPropertyCard(
                            "Commercial Land",
                            "Ariana, Tunisia",
                            "350,000 TND",
                            "1.2 ETH",
                            Colors.blue.shade100,
                          ),
                          SizedBox(height: 12),
                          _buildPropertyCard(
                            "Residential Plot",
                            "Tunis, Tunisia",
                            "520,000 TND",
                            "1.8 ETH",
                            Colors.green.shade100,
                          ),
                          SizedBox(height: 12),
                          _buildPropertyCard(
                            "Agricultural Land",
                            "Sousse, Tunisia",
                            "180,000 TND",
                            "0.62 ETH",
                            Colors.amber.shade100,
                          ),
                          
                          SizedBox(height: 24),
                          Center(
                            child: TextButton.icon(
                              onPressed: _toggleMapExpansion,
                              icon: Icon(Icons.fullscreen),
                              label: Text("View Full Map"),
                              style: TextButton.styleFrom(
                                foregroundColor: primaryColor,
                                textStyle: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
                    
                    // Market trends
                    Container(
                      padding: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            spreadRadius: 0,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.trending_up, color: primaryColor),
                              SizedBox(width: 12),
                              Text(
                                "Market Trends",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          
                          _buildTrendItem(
                            "Residential", 
                            "↑ 4.2%", 
                            "Increasing demand in urban areas",
                            true,
                          ),
                          SizedBox(height: 12),
                          _buildTrendItem(
                            "Commercial", 
                            "↑ 2.8%", 
                            "Stable growth in business districts",
                            true,
                          ),
                          SizedBox(height: 12),
                          _buildTrendItem(
                            "Agricultural", 
                            "↓ 1.5%", 
                            "Slight decrease due to seasonal factors",
                            false,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPropertyCard(String title, String location, String price, String ethPrice, Color bgColor) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.home_work_outlined,
              color: bgColor == Colors.blue.shade100 
                ? Colors.blue.shade700
                : bgColor == Colors.green.shade100
                  ? Colors.green.shade700
                  : Colors.amber.shade700,
              size: 30,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.grey.shade800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  location,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.grey.shade800,
                ),
              ),
              SizedBox(height: 4),
              Text(
                ethPrice,
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrendItem(String category, String change, String description, bool isPositive) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPositive ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isPositive ? Colors.green.shade200 : Colors.red.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isPositive ? Colors.green.shade100 : Colors.red.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPositive ? Icons.trending_up : Icons.trending_down,
              color: isPositive ? Colors.green.shade700 : Colors.red.shade700,
              size: 20,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Text(
            change,
            style: TextStyle(
              color: isPositive ? Colors.green.shade700 : Colors.red.shade700,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(Color primaryColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(height: 24),
          
          // Title for Land Valuation Tool
          if (_isSidebarOpen)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.terrain,
                        size: 28, 
                        color: primaryColor,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Land Valuation',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Blockchain-powered property estimator',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            )
          else
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Icon(
                Icons.terrain,
                size: 28, 
                color: primaryColor,
              ),
            ),
          
          SizedBox(height: 20),
          Divider(height: 1),
          SizedBox(height: 20),
          
          // Navigation items
          for (int i = 0; i < 3; i++)
            _buildSidebarItem(i, primaryColor),
          
          Spacer(),
          
          Divider(height: 1),
          SizedBox(height: 16),
          
          // Bottom sidebar items
          if (_isSidebarOpen) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.location_on, size: 18, color: Colors.grey.shade600),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Location',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          _currentPosition != null ? 
                            '${_currentPosition!.latitude.toStringAsFixed(4)}, ${_currentPosition!.longitude.toStringAsFixed(4)}' : 
                            'Unknown',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: ElevatedButton.icon(
                onPressed: () {
                  // Action for help/support
                },
                icon: Icon(Icons.support_agent, size: 20),
                label: Text("Support Center"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  minimumSize: Size(double.infinity, 50),
                  textStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ] else
            Padding(
              padding: EdgeInsets.all(16),
              child: IconButton(
                icon: Icon(Icons.support_agent, size: 24, color: primaryColor),
                onPressed: () {
                  // Action for help/support
                },
                tooltip: 'Support',
              ),
            ),
          
          SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(int index, Color primaryColor) {
    final bool isSelected = _selectedIndex == index;
    final List<Map<String, dynamic>> navItems = [
      {'icon': Icons.map, 'label': 'Map View', 'tooltip': 'View properties on the map'},
      {'icon': Icons.list_alt, 'label': 'Property List', 'tooltip': 'Browse all properties'},
      {'icon': Icons.calculate, 'label': 'Valuation Tool', 'tooltip': 'Calculate land value'},
    ];
    
    final navItem = navItems[index];
    
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6, horizontal: _isSidebarOpen ? 24 : 8),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            setState(() {
              _selectedIndex = index;
              // Reset map expansion when changing tabs
              if (_isMapExpanded && index != 0) {
                _isMapExpanded = false;
              }
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: 16, 
              horizontal: _isSidebarOpen ? 20 : 12,
            ),
            decoration: BoxDecoration(
              color: isSelected 
                ? primaryColor.withOpacity(0.15) 
                : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: isSelected 
                ? Border.all(color: primaryColor.withOpacity(0.5), width: 1.5)
                : null,
            ),
            child: Row(
              mainAxisAlignment: _isSidebarOpen 
                ? MainAxisAlignment.start 
                : MainAxisAlignment.center,
              children: [
                Icon(
                  navItem['icon'], 
                  color: isSelected ? primaryColor : Colors.grey.shade700,
                  size: 24,
                ),
                if (_isSidebarOpen) ...[
                  SizedBox(width: 16),
                  Text(
                    navItem['label'],
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? primaryColor : Colors.grey.shade800,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingScreen(Color primaryColor) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: _buildFixedSizeNavBar(),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              primaryColor.withOpacity(0.02),
              primaryColor.withOpacity(0.1),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(36),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                Icons.terrain,
                size: 80,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 50),
            Text(
              'Land Value Estimator',
              style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Accurate property valuations using blockchain technology',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 70),
            Container(
              width: 400,
              padding: EdgeInsets.symmetric(vertical: 24, horizontal: 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                children: [
                  LinearProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    backgroundColor: primaryColor.withOpacity(0.1),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_searching,
                        color: primaryColor.withOpacity(0.8),
                        size: 24,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Accessing your location data...',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
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
    );
  }

  Widget _buildErrorScreen(Color primaryColor) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: _buildFixedSizeNavBar(),
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(36),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                Icons.location_off,
                size: 80,
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 50),
            Text(
              'Location Access Required',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade800,
              ),
            ),
            const SizedBox(height: 30),
            Container(
              constraints: BoxConstraints(maxWidth: 700),
              child: Text(
                _errorMessage.isEmpty ? 
                  'We need access to your location to show nearby properties and provide accurate valuations.' :
                  _errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey.shade700,
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _initializeApp,
                  icon: Icon(Icons.refresh, size: 24),
                  label: Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                    textStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(width: 24),
                if (_errorMessage.contains('permanently denied'))
                  OutlinedButton.icon(
                    onPressed: () {
                      Geolocator.openAppSettings();
                    },
                    icon: Icon(Icons.settings, size: 24),
                    label: Text('Open Settings'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                      side: BorderSide(color: primaryColor, width: 2),
                      textStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    super.dispose();
  }
}