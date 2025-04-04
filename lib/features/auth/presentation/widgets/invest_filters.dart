import 'package:flutter/material.dart';
import 'package:the_boost/core/constants/colors.dart';
import 'package:the_boost/core/constants/dimensions.dart';
import 'package:the_boost/features/auth/data/models/land_model.dart';
import 'package:the_boost/features/auth/presentation/bloc/lands/land_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InvestFilters extends StatefulWidget {
  final Function(Map<String, dynamic>) onFiltersChanged;

  const InvestFilters({
    Key? key,
    required this.onFiltersChanged,
  }) : super(key: key);

  @override
  State<InvestFilters> createState() => _InvestFiltersState();
}

class _InvestFiltersState extends State<InvestFilters> {
  // Filter states
  Set<LandType> selectedTypes = {};
  Set<LandStatus> selectedStatuses = {};
  RangeValues priceRange = const RangeValues(0, 1000000);
  String searchQuery = '';
  String sortBy = 'newest';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(),
            const SizedBox(height: 24),
            _buildTypeFilter(),
            const SizedBox(height: 24),
            _buildStatusFilter(),
            const SizedBox(height: 24),
            _buildPriceFilter(),
            const SizedBox(height: 24),
            _buildSortingFilter(),
            const SizedBox(height: 24),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search for land...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      onChanged: (value) {
        setState(() {
          searchQuery = value;
        });
        _applyFilters();
      },
    );
  }

  Widget _buildTypeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Land Type',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: LandType.values.map((type) {
            return FilterChip(
              label: Text(_getTypeLabel(type)),
              selected: selectedTypes.contains(type),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    selectedTypes.add(type);
                  } else {
                    selectedTypes.remove(type);
                  }
                });
                _applyFilters();
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStatusFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Status',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: LandStatus.values.map((status) {
            return FilterChip(
              label: Text(_getStatusLabel(status)),
              selected: selectedStatuses.contains(status),
              selectedColor: _getStatusColor(status).withOpacity(0.2),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    selectedStatuses.add(status);
                  } else {
                    selectedStatuses.remove(status);
                  }
                });
                _applyFilters();
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPriceFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Price Range',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        RangeSlider(
          values: priceRange,
          min: 0,
          max: 1000000,
          divisions: 100,
          labels: RangeLabels(
            '${priceRange.start.round()} TND',
            '${priceRange.end.round()} TND',
          ),
          onChanged: (values) {
            setState(() {
              priceRange = values;
            });
            _applyFilters();
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${priceRange.start.round()} TND'),
            Text('${priceRange.end.round()} TND'),
          ],
        ),
      ],
    );
  }

  Widget _buildSortingFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sort by',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButton<String>(
          value: sortBy,
          isExpanded: true,
          onChanged: (String? value) {
            if (value != null) {
              setState(() {
                sortBy = value;
              });
              _applyFilters();
            }
          },
          items: [
            DropdownMenuItem(value: 'newest', child: Text('Most Recent')),
            DropdownMenuItem(value: 'price_asc', child: Text('Price: Low to High')),
            DropdownMenuItem(value: 'price_desc', child: Text('Price: High to Low')),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 32, // Hauteur réduite pour les boutons
            child: ElevatedButton.icon(
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text(
                'Reset',
                style: TextStyle(fontSize: 8),
              ),
              onPressed: _resetFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SizedBox(
            height: 32,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.filter_list, size: 16),
              label: const Text(
                'Apply',
                style: TextStyle(fontSize: 8),
              ),
              onPressed: _applyFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  

  void _applyFilters() {
    print('[${DateTime.now()}] Applying filters in widget');
    print('Selected types: $selectedTypes');
    print('Selected statuses: $selectedStatuses');
    print('Price range: $priceRange');
    print('Search query: $searchQuery');
    print('Sort by: $sortBy');

    final landBloc = context.read<LandBloc>();
    landBloc.add(
      ApplyFilters(
        selectedTypes: selectedTypes,
        selectedStatuses: selectedStatuses,
        priceRange: priceRange,
        searchQuery: searchQuery,
        sortBy: sortBy,
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      selectedTypes.clear();
      selectedStatuses.clear();
      priceRange = const RangeValues(0, 1000000);
      searchQuery = '';
      sortBy = 'newest';
    });
    _applyFilters();
  }

  String _getTypeLabel(LandType type) {
    switch (type) {
      case LandType.AGRICULTURAL:
        return 'Agricultural';
      case LandType.RESIDENTIAL:
        return 'Residential';
      case LandType.INDUSTRIAL:
        return 'Industrial';
      case LandType.COMMERCIAL:
        return 'Commercial';
    }
  }

  String _getStatusLabel(LandStatus status) {
    switch (status) {
      case LandStatus.AVAILABLE:
        return 'Available';
      case LandStatus.PENDING:
        return 'Pending';
      case LandStatus.SOLD:
        return 'Sold';
    }
  }

  Color _getStatusColor(LandStatus status) {
    switch (status) {
      case LandStatus.AVAILABLE:
        return Colors.green;
      case LandStatus.PENDING:
        return Colors.orange;
      case LandStatus.SOLD:
        return Colors.red;
    }
  }
}