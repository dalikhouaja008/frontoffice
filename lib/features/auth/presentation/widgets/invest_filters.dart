// lib/features/auth/presentation/widgets/invest_filters.dart
import 'package:flutter/material.dart';
import 'package:the_boost/features/auth/data/models/land_model.dart';

class InvestFilters extends StatefulWidget {
  final Function(Map<String, dynamic>) onFiltersChanged;
  final VoidCallback onClose;

  const InvestFilters({
    Key? key,
    required this.onFiltersChanged,
    required this.onClose,
  }) : super(key: key);

  @override
  _InvestFiltersState createState() => _InvestFiltersState();
}

class _InvestFiltersState extends State<InvestFilters> {
  RangeValues _priceRange = const RangeValues(0, 1000000);
  LandType? _selectedLandType;
  LandValidationStatus? _selectedValidationStatus;
  final Map<String, bool> _amenities = {
    'electricity': false,
    'water': false,
    'roadAccess': false,
    'buildingPermit': false,
  };
  String? _sortBy;

  void _applyFilters() {
    final filters = {
      'priceRange': {
        'min': _priceRange.start,
        'max': _priceRange.end,
      },
      'landType': _selectedLandType?.name,
      'validationStatus': _selectedValidationStatus?.name,
      'amenities': _amenities,
      'sortBy': _sortBy,
    };
    widget.onFiltersChanged(filters);
    widget.onClose();
  }

  void _clearFilters() {
    setState(() {
      _priceRange = const RangeValues(0, 1000000);
      _selectedLandType = null;
      _selectedValidationStatus = null;
      _amenities.updateAll((key, value) => false);
      _sortBy = null;
    });
    final filters = {
      'priceRange': null,
      'landType': null,
      'validationStatus': null,
      'amenities': null,
      'sortBy': null,
    };
    widget.onFiltersChanged(filters);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300, // Fixed width for the sidebar
      color: Colors.grey[200], // Light grey background
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filters Header
            const Text(
              'Filters',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            // Price Range Filter
            const Text(
              'Price Range',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            RangeSlider(
              values: _priceRange,
              min: 0,
              max: 1000000,
              divisions: 100,
              labels: RangeLabels(
                _priceRange.start.round().toString(),
                _priceRange.end.round().toString(),
              ),
              onChanged: (RangeValues values) {
                setState(() {
                  _priceRange = values;
                });
              },
            ),
            const SizedBox(height: 16),

            // Land Type Filter
            const Text(
              'Land Type',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            DropdownButton<LandType>(
              isExpanded: true,
              value: _selectedLandType,
              hint: const Text('Select Land Type'),
              items: LandType.values.map((LandType type) {
                return DropdownMenuItem<LandType>(
                  value: type,
                  child: Text(type.displayName),
                );
              }).toList(),
              onChanged: (LandType? value) {
                setState(() {
                  _selectedLandType = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Validation Status Filter
            const Text(
              'Validation Status',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            DropdownButton<LandValidationStatus>(
              isExpanded: true,
              value: _selectedValidationStatus,
              hint: const Text('Select Validation Status'),
              items: LandValidationStatus.values.map((LandValidationStatus status) {
                return DropdownMenuItem<LandValidationStatus>(
                  value: status,
                  child: Text(status.displayName),
                );
              }).toList(),
              onChanged: (LandValidationStatus? value) {
                setState(() {
                  _selectedValidationStatus = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Amenities Filter
            const Text(
              'Amenities',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            ..._amenities.keys.map((String key) {
              return CheckboxListTile(
                title: Text(key.capitalize()),
                value: _amenities[key],
                onChanged: (bool? value) {
                  setState(() {
                    _amenities[key] = value ?? false;
                  });
                },
              );
            }).toList(),
            const SizedBox(height: 16),

            // Sort By Filter
            const Text(
              'Sort By',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            DropdownButton<String>(
              isExpanded: true,
              value: _sortBy,
              hint: const Text('Select Sort Option'),
              items: const [
                DropdownMenuItem(value: 'price_asc', child: Text('Price: Low to High')),
                DropdownMenuItem(value: 'price_desc', child: Text('Price: High to Low')),
                DropdownMenuItem(value: 'title_asc', child: Text('Title: A to Z')),
                DropdownMenuItem(value: 'title_desc', child: Text('Title: Z to A')),
              ],
              onChanged: (String? value) {
                setState(() {
                  _sortBy = value;
                });
              },
            ),
            const SizedBox(height: 24),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Apply Filters'),
                ),
                ElevatedButton(
                  onPressed: _clearFilters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Clear Filters'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}