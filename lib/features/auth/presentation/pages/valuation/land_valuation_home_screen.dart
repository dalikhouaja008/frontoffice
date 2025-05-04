// lib/features/auth/presentation/pages/valuation/land_valuation_home_screen.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:the_boost/core/services/prop_service.dart';
import 'dart:async';

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

  List<Widget> _screens = [];
  
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
      _initializeScreens();
    }
  }

  void _initializeScreens() {
    if (_currentPosition == null) return;
    
    setState(() {
      _screens = [
        MapScreen(
          initialPosition: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          apiService: apiService,
        ),
        PropertyListScreen(
          apiService: apiService,
          initialPosition: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        ),
        ValuationScreen(
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
  
  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    
    // Show loading screen while initializing
    if (_isLoading || (!_isInitialized && _currentPosition != null)) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primaryColor.withOpacity(0.1), 
                primaryColor.withOpacity(0.2)
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.map,
                    size: 48,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Land Value Estimator',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: primaryColor.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: 200,
                  child: Column(
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Loading your location...',
                        style: TextStyle(
                          color: primaryColor.withOpacity(0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    // Show error screen if there's an error
    if (_errorMessage.isNotEmpty || _currentPosition == null) {
      return Scaffold(
        body: Container(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.location_off,
                    size: 64,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Location Access Required',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade800,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    _errorMessage.isEmpty ? 
                      'We need access to your location to show nearby properties and provide accurate valuations.' :
                      _errorMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: _initializeApp,
                  icon: Icon(Icons.refresh),
                  label: Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                if (_errorMessage.contains('permanently denied'))
                  TextButton(
                    onPressed: () {
                      Geolocator.openAppSettings();
                    },
                    child: Text('Open Settings'),
                  ),
              ],
            ),
          ),
        ),
      );
    }
    
    // Main screen with navigation
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Land Value Estimator'),
            const Spacer(),
            if (_ethPriceData != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.currency_exchange, size: 16, color: Colors.blue.shade700),
                    const SizedBox(width: 4),
                    Text(
                      '1 ETH = ${_ethPriceData!['ethPriceTND'].toStringAsFixed(2)} TND',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchEthPrice,
            tooltip: 'Refresh ETH Price',
          ),
        ],
      ),
      body: _isInitialized && _screens.isNotEmpty
    ? Expanded(  // Wrap in Expanded
        child: IndexedStack(
          index: _selectedIndex,
          children: _screens,
        ),
      )
    : Center(
        child: CircularProgressIndicator(),
      ),
      bottomNavigationBar: Container(
        height: 60,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.map),
                label: 'Map',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.list),
                label: 'Properties',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calculate),
                label: 'Valuation',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: primaryColor,
            unselectedItemColor: Colors.grey.shade600,
            showUnselectedLabels: true,
            backgroundColor: Colors.white,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    super.dispose();
  }
}