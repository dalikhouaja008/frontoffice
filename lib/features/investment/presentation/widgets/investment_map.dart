// lib/features/investment/presentation/widgets/investment_map.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:the_boost/core/constants/colors.dart';
import 'package:the_boost/core/constants/dimensions.dart';
import 'package:the_boost/features/auth/data/models/land_model.dart';
import 'package:the_boost/features/auth/data/models/land_model_extension.dart';

class InvestmentMap extends StatefulWidget {
  final List<Land> lands;
  final Function(Land) onLandSelected;
  
  const InvestmentMap({
    Key? key,
    required this.lands,
    required this.onLandSelected,
  }) : super(key: key);

  @override
  _InvestmentMapState createState() => _InvestmentMapState();
}

class _InvestmentMapState extends State<InvestmentMap> {
  // Filter state
  double _minPrice = 0;
  double _maxPrice = 1200000;
  LandType? _selectedType;
  
  // Create a MapController to interact with the map
  final MapController _mapController = MapController();
  
  @override
  Widget build(BuildContext context) {
    // Filter lands based on current filters
    final filteredLands = widget.lands.where((land) {
      if (_selectedType != null && land.type != _selectedType) {
        return false;
      }
      
      if (land.price < _minPrice || land.price > _maxPrice) {
        return false;
      }
      
      return true;
    }).toList();
    
    return LayoutBuilder(
      builder: (context, constraints) {
        // Using LayoutBuilder to get the exact available space
        return Column(
          children: [
            _buildFilters(),
            const SizedBox(height: AppDimensions.paddingM),
            // Calculate the remaining height for the map
            SizedBox(
              height: constraints.maxHeight - 110, // Approximate filter height + padding
              width: constraints.maxWidth,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      // Center on California by default
                      center: const LatLng(36.7783, -119.4179),
                      zoom: 6.0,
                      maxZoom: 18.0,
                      minZoom: 3.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.the_boost',
                      ),
                      MarkerLayer(
                        markers: filteredLands.map((land) {
                          final coordinates = land.coordinates;
                          
                          return Marker(
                            point: coordinates,
                            width: 40.0,
                            height: 40.0,
                            child: GestureDetector(
                              onTap: () => widget.onLandSelected(land),
                              child: _buildMapMarker(land),
                            ),
                          );
                        }).toList(),
                      ),
                      // Heat map layer
                      CircleLayer(
                        circles: filteredLands.map((land) {
                          final coordinates = land.coordinates;
                          
                          return CircleMarker(
                            point: coordinates,
                            color: land.heatMapColor.withOpacity(0.3),
                            borderColor: Colors.transparent,
                            borderStrokeWidth: 0,
                            radius: 1000.0 * (land.price / 1000000), // Radius based on price
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.paddingM),
            _buildLegend(),
          ],
        );
      }
    );
  }
  
  Widget _buildMapMarker(Land land) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          _getIconForLandType(land.type),
          color: Colors.white,
          size: 16,
        ),
      ),
    );
  }
  
  IconData _getIconForLandType(LandType type) {
    switch (type) {
      case LandType.AGRICULTURAL:
        return Icons.grass;
      case LandType.RESIDENTIAL:
        return Icons.home;
      case LandType.INDUSTRIAL:
        return Icons.factory;
      case LandType.COMMERCIAL:
        return Icons.store;
      default:
        return Icons.landscape;
    }
  }
  
  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter Properties',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingM),
          LayoutBuilder(
            builder: (context, constraints) {
              // Responsive layout for filter options
              final isMobile = constraints.maxWidth < 500;
              
              if (isMobile) {
                return Column(
                  children: [
                    _buildPriceRangeSlider(),
                    const SizedBox(height: AppDimensions.paddingS),
                    Center(child: _buildTypeDropdown()),
                  ],
                );
              } else {
                return Row(
                  children: [
                    Expanded(child: _buildPriceRangeSlider()),
                    const SizedBox(width: AppDimensions.paddingM),
                    _buildTypeDropdown(),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildPriceRangeSlider() {
    // Format currency values
    final minPriceText = '\$${_formatCurrency(_minPrice)}';
    final maxPriceText = '\$${_formatCurrency(_maxPrice)}';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Price Range'),
        RangeSlider(
          values: RangeValues(_minPrice, _maxPrice),
          min: 0,
          max: 1500000,
          divisions: 15,
          labels: RangeLabels(minPriceText, maxPriceText),
          onChanged: (values) {
            setState(() {
              _minPrice = values.start;
              _maxPrice = values.end;
            });
          },
          activeColor: AppColors.primary,
        ),
      ],
    );
  }
  
  Widget _buildTypeDropdown() {
    return DropdownButton<LandType?>(
      value: _selectedType,
      hint: const Text('All Types'),
      onChanged: (value) {
        setState(() {
          _selectedType = value;
        });
      },
      items: [
        const DropdownMenuItem<LandType?>(
          value: null,
          child: Text('All Types'),
        ),
        ...LandType.values.map((type) {
          return DropdownMenuItem<LandType>(
            value: type,
            child: Text(_getLandTypeName(type)),
          );
        }).toList(),
      ],
    );
  }
  
  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: AppDimensions.paddingS,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Investment Heat: ', style: TextStyle(fontWeight: FontWeight.bold)),
            _buildLegendItem(Colors.green, 'Low'),
            _buildLegendItem(Colors.yellow, 'Medium'),
            _buildLegendItem(Colors.orange, 'High'),
            _buildLegendItem(Colors.red, 'Very High'),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.7),
            shape: BoxShape.circle,
          ),
        ),
        Text(label),
        const SizedBox(width: 8),
      ],
    );
  }
  
  String _getLandTypeName(LandType type) {
    switch (type) {
      case LandType.AGRICULTURAL:
        return 'Agricultural';
      case LandType.RESIDENTIAL:
        return 'Residential';
      case LandType.INDUSTRIAL:
        return 'Industrial';
      case LandType.COMMERCIAL:
        return 'Commercial';
      default:
        return 'Unknown';
    }
  }
  
  String _formatCurrency(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}K';
    } else {
      return value.toStringAsFixed(0);
    }
  }
}