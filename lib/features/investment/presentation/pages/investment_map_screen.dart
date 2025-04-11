// lib/features/investment/presentation/pages/investment_map_screen.dart
import 'package:flutter/material.dart';
import 'package:the_boost/core/constants/colors.dart';
import 'package:the_boost/core/constants/dimensions.dart';
import 'package:the_boost/features/auth/data/datasources/static_lands.dart';
import 'package:the_boost/features/auth/data/models/land_model.dart';
import 'package:the_boost/features/auth/presentation/pages/base_page.dart';
import 'package:the_boost/features/investment/presentation/widgets/investment_map.dart';

class InvestmentMapScreen extends StatefulWidget {
  const InvestmentMapScreen({Key? key}) : super(key: key);

  @override
  _InvestmentMapScreenState createState() => _InvestmentMapScreenState();
}

class _InvestmentMapScreenState extends State<InvestmentMapScreen> {
  List<Land> _lands = [];
  Land? _selectedLand;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLands();
  }

  Future<void> _loadLands() async {
    try {
      // Simulate API delay
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _lands = StaticLandsData.getLands();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading lands: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onLandSelected(Land land) {
    setState(() {
      _selectedLand = land;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    
    return BasePage(
      title: 'Investment Map',
      currentRoute: '/investment-map',
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: AppDimensions.paddingL),
            // Explicit LayoutBuilder to handle height constraints properly
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : isMobile
                          ? _buildMobileLayout(constraints)
                          : _buildDesktopLayout(constraints);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BoxConstraints constraints) {
    // Calculate available height for map
    final mapHeight = _selectedLand != null 
        ? constraints.maxHeight * 0.6  // 60% for map if property selected
        : constraints.maxHeight;       // Full height otherwise
    
    return Column(
      children: [
        SizedBox(
          height: mapHeight,
          width: constraints.maxWidth,
          child: InvestmentMap(
            lands: _lands,
            onLandSelected: _onLandSelected,
          ),
        ),
        if (_selectedLand != null) ...[
          const SizedBox(height: AppDimensions.paddingM),
          Expanded(
            child: SingleChildScrollView(
              child: _buildPropertyDetails(_selectedLand!),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDesktopLayout(BoxConstraints constraints) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 7,
          child: SizedBox(
            height: constraints.maxHeight,
            child: InvestmentMap(
              lands: _lands,
              onLandSelected: _onLandSelected,
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.paddingL),
        Expanded(
          flex: 3,
          child: _selectedLand != null
              ? SingleChildScrollView(
                  child: _buildPropertyDetails(_selectedLand!),
                )
              : _buildNoSelectionMessage(),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Explore Investment Opportunities',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingS),
        Text(
          'Browse available properties on the map and discover investment hotspots',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildNoSelectionMessage() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
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
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.map,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: AppDimensions.paddingM),
          Text(
            'Select a property on the map to view details',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyDetails(Land land) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              image: land.imageUrl.isNotEmpty
                  ? DecorationImage(
                      image: AssetImage(land.imageUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: land.imageUrl.isEmpty
                ? Center(
                    child: Icon(
                      Icons.image,
                      color: Colors.grey[400],
                      size: 48,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: AppDimensions.paddingM),
          Text(
            land.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingS),
          Row(
            children: [
              const Icon(
                Icons.location_on,
                color: Colors.grey,
                size: 16,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  land.location,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingM),
          _buildPropertyStat(
            label: 'Type',
            value: _getLandTypeName(land.type),
            icon: _getIconForLandType(land.type),
          ),
          _buildPropertyStat(
            label: 'Price',
            value: '\$${land.price.toStringAsFixed(0)}',
            icon: Icons.attach_money,
          ),
          _buildPropertyStat(
            label: 'Surface',
            value: '${land.surface.toStringAsFixed(0)} m²',
            icon: Icons.straighten,
          ),
          _buildPropertyStat(
            label: 'Status',
            value: _getLandStatusName(land.status),
            icon: _getIconForLandStatus(land.status),
          ),
          const SizedBox(height: AppDimensions.paddingL),
          ElevatedButton(
            onPressed: () {
              // Navigate to property details
              // Navigator.pushNamed(context, '/property-details', arguments: land.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 44),
            ),
            child: const Text('View Details'),
          ),
          const SizedBox(height: AppDimensions.paddingS),
          OutlinedButton(
            onPressed: () {
              // Add to watchlist or bookmark
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              minimumSize: const Size(double.infinity, 44),
            ),
            child: const Text('Add to Watchlist'),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyStat({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingS),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
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

  String _getLandStatusName(LandStatus status) {
    switch (status) {
      case LandStatus.AVAILABLE:
        return 'Available';
      case LandStatus.PENDING:
        return 'Pending';
      case LandStatus.SOLD:
        return 'Sold';
      default:
        return 'Unknown';
    }
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

  IconData _getIconForLandStatus(LandStatus status) {
    switch (status) {
      case LandStatus.AVAILABLE:
        return Icons.check_circle;
      case LandStatus.PENDING:
        return Icons.hourglass_empty;
      case LandStatus.SOLD:
        return Icons.money_off;
      default:
        return Icons.help;
    }
  }
}