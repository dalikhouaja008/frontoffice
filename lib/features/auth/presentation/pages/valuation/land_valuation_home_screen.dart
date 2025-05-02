// lib/features/land_valuation/presentation/pages/land_valuation_home_screen.dart
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
  
  /// If you want to provide a custom API service, pass it here.
  /// Otherwise, a default one will be created.
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

  final List<Widget> _screens = [];
  
  @override
  void initState() {
    super.initState();
    apiService = widget.apiService ?? ApiService();
    _determinePosition();
  }
  
  Future<void> _determinePosition() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _errorMessage = 'Location services are disabled.';
          _isLoading = false;
        });
        return;
      }
      
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _errorMessage = 'Location permissions are denied.';
            _isLoading = false;
          });
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage = 'Location permissions are permanently denied.';
          _isLoading = false;
        });
        return;
      }
      
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
        _isLoading = false;
        
        // Initialize screens with current position
        _screens.clear();
        _screens.addAll([
          MapScreen(
            initialPosition: LatLng(position.latitude, position.longitude),
            apiService: apiService,
          ),
          PropertyListScreen(
            apiService: apiService,
            initialPosition: LatLng(position.latitude, position.longitude),
          ),
          ValuationScreen(
            apiService: apiService,
            initialPosition: LatLng(position.latitude, position.longitude),
          ),
        ]);
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error determining position: $e';
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // Get theme from context - this allows the component to use the theme from the parent app
    final primaryColor = Theme.of(context).colorScheme.primary;
    
    // Enhanced loading screen
    if (_isLoading) {
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
                // Logo
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
                // Feature name
                Text(
                  'Land Value Estimator',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: primaryColor.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 40),
                // Loading indicator
                SizedBox(
                  width: 200,
                  child: Column(
                    children: [
                      LinearProgressIndicator(
                        backgroundColor: primaryColor.withOpacity(0.2),
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
    
    // Enhanced error screen
    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        body: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
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
                    Icons.error_outline,
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
                ElevatedButton(
                  onPressed: _determinePosition,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Text(
                      'Grant Permission',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    // Enhanced main screen with bottom navigation
    return Scaffold(
      body: _screens.isNotEmpty && _selectedIndex < _screens.length 
          ? _screens[_selectedIndex] 
          : Container(),
      bottomNavigationBar: Container(
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
            currentIndex: _selectedIndex < _screens.length ? _selectedIndex : 0,
            selectedItemColor: primaryColor,
            unselectedItemColor: Colors.grey.shade600,
            showUnselectedLabels: true,
            backgroundColor: Colors.white,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            onTap: (index) {
              if (index < _screens.length) {
                setState(() {
                  _selectedIndex = index;
                });
              }
            },
          ),
        ),
      ),
    );
  }
}