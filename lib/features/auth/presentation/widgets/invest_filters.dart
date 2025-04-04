import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_boost/core/constants/colors.dart';
import 'package:the_boost/core/constants/dimensions.dart';
import 'package:the_boost/features/auth/data/models/land_model.dart';
import 'package:the_boost/features/auth/presentation/bloc/lands/land_bloc.dart';

// Ajout de la définition de la classe InvestFilters
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
  Set<LandType> selectedTypes = {};
  Set<LandStatus> selectedStatuses = {};
  RangeValues priceRange = const RangeValues(0, 1000000);
  String searchQuery = '';
  String sortBy = 'newest';

  @override
void initState() {
  super.initState();
  // Assurez-vous que les ensembles sont vides au démarrage
  selectedTypes = <LandType>{};
  selectedStatuses = <LandStatus>{};
  
  // Appliquer les filtres initiaux (vides) après le build
  WidgetsBinding.instance.addPostFrameCallback((_) {
    print('[${DateTime.now()}] Initializing filters');
    print('Initial selected types: $selectedTypes');
    print('Initial selected statuses: $selectedStatuses');
    _applyFilters();
  });
}


  void _applyFilters() {
  print('[${DateTime.now()}] Applying filters in widget');
  print('Selected types: ${selectedTypes.map((t) => t.toString()).join(', ')}');
  print('Selected statuses: ${selectedStatuses.map((s) => s.toString()).join(', ')}');
  print('Price range: $priceRange');
  print('Search query: $searchQuery');
  print('Sort by: $sortBy');

  // Assurez-vous que les ensembles sont bien vides si aucun filtre n'est sélectionné
  final types = selectedTypes.isEmpty ? <LandType>{} : selectedTypes;
  final statuses = selectedStatuses.isEmpty ? <LandStatus>{} : selectedStatuses;

  context.read<LandBloc>().add(
    ApplyFilters(
      selectedTypes: types,
      selectedStatuses: statuses,
      priceRange: priceRange,
      searchQuery: searchQuery,
      sortBy: sortBy,
    ),
  );
}

  String _getTypeLabel(LandType type) {
    switch (type) {
      case LandType.RESIDENTIAL:
        return 'Residential';
      case LandType.COMMERCIAL:
        return 'Commercial';
      case LandType.INDUSTRIAL:
        return 'Industrial';
      case LandType.AGRICULTURAL:
        return 'Agricultural';
      default:
        return 'Unknown';
    }
  }

  String _getStatusLabel(LandStatus status) {
    switch (status) {
      case LandStatus.AVAILABLE:
        return 'Available';
      case LandStatus.SOLD:
        return 'Sold';
      case LandStatus.RESERVED:
        return 'Reserved';
      default:
        return 'Unknown';
    }
  }

  Color _getStatusColor(LandStatus status) {
    switch (status) {
      case LandStatus.AVAILABLE:
        return Colors.green;
      case LandStatus.SOLD:
        return Colors.red;
      case LandStatus.RESERVED:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(),
            const SizedBox(height: 16),
            _buildTypeFilter(),
            const SizedBox(height: 16),
            _buildStatusFilter(),
            const SizedBox(height: 16),
            _buildPriceFilter(),
            const SizedBox(height: 16),
            _buildSortingFilter(),
            const SizedBox(height: 16),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
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
          'Type',
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
            bool isSelected = selectedTypes.contains(type);
            return FilterChip(
              label: Text(_getTypeLabel(type)),
              selected: isSelected,
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
              selectedColor: AppColors.primary.withOpacity(0.2),
              checkmarkColor: AppColors.primary,
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
            bool isSelected = selectedStatuses.contains(status);
            return FilterChip(
              label: Text(_getStatusLabel(status)),
              selected: isSelected,
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
              selectedColor: _getStatusColor(status).withOpacity(0.2),
              checkmarkColor: _getStatusColor(status),
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
        const SizedBox(height: 8),
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
          'Sort By',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButton<String>(
          value: sortBy,
          isExpanded: true,
          items: [
            DropdownMenuItem(value: 'newest', child: Text('Most Recent')),
            DropdownMenuItem(value: 'price_asc', child: Text('Price: Low to High')),
            DropdownMenuItem(value: 'price_desc', child: Text('Price: High to Low')),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                sortBy = value;
              });
              _applyFilters();
            }
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Reset'),
            onPressed: () {
              setState(() {
                selectedTypes.clear();
                selectedStatuses.clear();
                priceRange = const RangeValues(0, 1000000);
                searchQuery = '';
                sortBy = 'newest';
              });
              _applyFilters();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[300],
              foregroundColor: Colors.black87,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.filter_list),
            label: const Text('Apply'),
            onPressed: _applyFilters,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}