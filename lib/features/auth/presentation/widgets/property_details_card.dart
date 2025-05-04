// lib/features/auth/presentation/widgets/property_details_card.dart
import 'package:flutter/material.dart';
import 'package:the_boost/features/auth/data/models/property/property.dart';

import 'currency_toggle.dart';

class PropertyDetailsCard extends StatefulWidget {
  final Property property;
  final Map<String, dynamic>? ethPriceData;

  const PropertyDetailsCard({
    Key? key,
    required this.property,
    this.ethPriceData,
  }) : super(key: key);

  @override
  State<PropertyDetailsCard> createState() => _PropertyDetailsCardState();
}

class _PropertyDetailsCardState extends State<PropertyDetailsCard> {
  String _selectedCurrency = 'ETH';

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with currency toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Property Value',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                CurrencyToggle(
                  selectedCurrency: _selectedCurrency,
                  onCurrencyChanged: (currency) {
                    setState(() {
                      _selectedCurrency = currency;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 16),
            
            // Price display based on selected currency
            _buildPriceDisplay(),
            
            SizedBox(height: 20),
            Divider(),
            SizedBox(height: 20),
            
            // Property details
            _buildPropertyDetail(
              'Address',
              widget.property.address,
              Icons.location_on,
            ),
            SizedBox(height: 12),
            _buildPropertyDetail(
              'Area',
              widget.property.area != null 
                ? '${widget.property.area!.toStringAsFixed(0)} sq ft' 
                : 'Unknown',
              Icons.straighten,
            ),
            SizedBox(height: 12),
            _buildPropertyDetail(
              'Price per sq ft',
              _getPricePerSqFt(),
              Icons.attach_money,
            ),
            SizedBox(height: 12),
            _buildPropertyDetail(
              'Zoning',
              widget.property.zoning ?? 'Unknown',
              Icons.category,
            ),
            
            // Features section
            SizedBox(height: 20),
            Text(
              'Features',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildFeatureChip(
                  'Water Access',
                  widget.property.features.nearWater,
                  Icons.water,
                ),
                _buildFeatureChip(
                  'Road Access',
                  widget.property.features.roadAccess,
                  Icons.directions_car,
                ),
                _buildFeatureChip(
                  'Utilities',
                  widget.property.features.utilities,
                  Icons.electrical_services,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceDisplay() {
    String priceText;
    Color priceColor;
    String subtitleText = '';

    switch (_selectedCurrency) {
      case 'ETH':
        priceText = widget.property.formatPriceETH();
        priceColor = Colors.blue.shade700;
        subtitleText = '${widget.property.price.toStringAsFixed(0)} TND';
        break;
      case 'TND':
        priceText = '${widget.property.price.toStringAsFixed(0)} TND';
        priceColor = Colors.green.shade700;
        subtitleText = widget.property.formatPriceETH();
        break;
      case 'USD':
        final ethPrice = widget.property.currentPriceInETH ?? widget.property.priceInETH;
        final ethUsdRate = widget.ethPriceData?['ethPriceUSD'] ?? 2400;
        final usdPrice = ethPrice != null ? ethPrice * ethUsdRate : null;
        priceText = usdPrice != null ? '\$${usdPrice.toStringAsFixed(2)}' : 'N/A';
        priceColor = Colors.green;
        subtitleText = widget.property.formatPriceETH();
        break;
      default:
        priceText = widget.property.formatPriceETH();
        priceColor = Colors.blue.shade700;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          priceText,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: priceColor,
          ),
        ),
        if (subtitleText.isNotEmpty)
          Text(
            subtitleText,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
      ],
    );
  }

  String _getPricePerSqFt() {
    switch (_selectedCurrency) {
      case 'ETH':
        return widget.property.currentPricePerSqFtETH != null 
          ? '${widget.property.currentPricePerSqFtETH!.toStringAsFixed(6)} ETH/sq ft'
          : 'N/A';
      case 'TND':
        return widget.property.pricePerSqFt != null 
          ? '${widget.property.pricePerSqFt!.toStringAsFixed(2)} TND/sq ft'
          : 'N/A';
      case 'USD':
        final ethPricePerSqFt = widget.property.currentPricePerSqFtETH;
        final ethUsdRate = widget.ethPriceData?['ethPriceUSD'] ?? 2400;
        final usdPricePerSqFt = ethPricePerSqFt != null ? ethPricePerSqFt * ethUsdRate : null;
        return usdPricePerSqFt != null 
          ? '\$${usdPricePerSqFt.toStringAsFixed(2)}/sq ft'
          : 'N/A';
      default:
        return 'N/A';
    }
  }

  Widget _buildPropertyDetail(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade700),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureChip(String label, bool available, IconData icon) {
    return Chip(
      avatar: Icon(
        icon,
        size: 18,
        color: available ? Colors.green : Colors.red,
      ),
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: available ? Colors.green.shade700 : Colors.red.shade700,
        ),
      ),
      backgroundColor: available ? Colors.green.shade50 : Colors.red.shade50,
    );
  }
}