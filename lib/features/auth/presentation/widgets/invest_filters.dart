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
  String? _selectedAvailability;
  String? _selectedValidationStatus; // New field for validation status
  final Map<String, bool> _amenities = {
    'electricity': false,
    'water_access': false,
    'road_access': false,
    'building_permit': false,
  };
  String? _sortBy;
  String _searchQuery = '';

  void _applyFilters() {
    final filters = {
      'priceRange': {
        'min': _priceRange.start,
        'max': _priceRange.end,
      },
      'landType': _selectedLandType?.name,
      'validationStatus': _selectedValidationStatus, // Added validation status
      'availability': _selectedAvailability,
      'amenities': _amenities,
      'sortBy': _sortBy,
      'searchQuery': _searchQuery,
    };
    widget.onFiltersChanged(filters);
    widget.onClose();
  }

  void _clearFilters() {
    setState(() {
      _priceRange = const RangeValues(0, 1000000);
      _selectedLandType = null;
      _selectedAvailability = null;
      _selectedValidationStatus = null;
      _amenities.updateAll((key, value) => false);
      _sortBy = null;
      _searchQuery = '';
    });
    final filters = {
      'priceRange': {'min': 0, 'max': 1000000},
      'landType': null,
      'validationStatus': null,
      'availability': null,
      'amenities': _amenities..updateAll((key, value) => false),
      'sortBy': null,
      'searchQuery': '',
    };
    widget.onFiltersChanged(filters);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey[200],
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filters',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: widget.onClose,
                    tooltip: 'Close Filters',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Search',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search by title...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Price Range (DT)',
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
              Text(
                'Min: ${_priceRange.start.round()} DT - Max: ${_priceRange.end.round()} DT',
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 16),
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
              const Text(
                'Availability',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              DropdownButton<String>(
                isExpanded: true,
                value: _selectedAvailability,
                hint: const Text('Select Availability'),
                items: const [
                  DropdownMenuItem(value: 'AVAILABLE', child: Text('Available')),
                  DropdownMenuItem(value: 'RESERVED', child: Text('Reserved')),
                  DropdownMenuItem(value: 'SOLD', child: Text('Sold')),
                ],
                onChanged: (String? value) {
                  setState(() {
                    _selectedAvailability = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Validation Status',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              DropdownButton<String>(
                isExpanded: true,
                value: _selectedValidationStatus,
                hint: const Text('Select Validation Status'),
                items: const [
                  DropdownMenuItem(value: 'PENDING_VALIDATION', child: Text('Pending Validation')),
                  DropdownMenuItem(value: 'VALIDATED', child: Text('Validated')),
                  DropdownMenuItem(value: 'REJECTED', child: Text('Rejected')),
                ],
                onChanged: (String? value) {
                  setState(() {
                    _selectedValidationStatus = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Amenities',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              ..._amenities.keys.map((String key) {
                return CheckboxListTile(
                  title: Text(key.replaceAll('_', ' ').split(' ').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ')),
                  value: _amenities[key],
                  onChanged: (bool? value) {
                    setState(() {
                      _amenities[key] = value ?? false;
                    });
                  },
                );
              }).toList(),
              const SizedBox(height: 16),
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
                  DropdownMenuItem(value: 'newest', child: Text('Newest First')),
                ],
                onChanged: (String? value) {
                  setState(() {
                    _sortBy = value;
                  });
                },
              ),
              const SizedBox(height: 24),
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
      ),
    );
  }
}