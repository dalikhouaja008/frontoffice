// lib/features/auth/presentation/widgets/invest_filters.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_boost/core/constants/colors.dart';
import 'package:the_boost/core/constants/dimensions.dart';
import 'package:the_boost/features/auth/presentation/bloc/lands/land_bloc.dart';

class InvestFilters extends StatefulWidget {
  final Function(Map<String, dynamic>)? onFiltersChanged;

  const InvestFilters({Key? key, this.onFiltersChanged}) : super(key: key);

  @override
  State<InvestFilters> createState() => _InvestFiltersState();
}

class _InvestFiltersState extends State<InvestFilters> {
  RangeValues priceRange = const RangeValues(0, 1000000);
  String searchQuery = '';
  String sortBy = 'newest';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('[${DateTime.now()}] Initializing filters');
      _applyFilters();
    });
  }

  void _applyFilters() {
    print('[${DateTime.now()}] Applying filters');
    print('Price range: $priceRange');
    print('Search query: $searchQuery');
    print('Sort by: $sortBy');

    context.read<LandBloc>().add(
          ApplyFilters(
            priceRange: priceRange,
            searchQuery: searchQuery,
            sortBy: sortBy,
          ),
        );
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
        hintText: 'Search by title...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onChanged: (value) {
        setState(() => searchQuery = value);
        _applyFilters();
      },
    );
  }

  Widget _buildPriceFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Price Range', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        RangeSlider(
          values: priceRange,
          min: 0,
          max: 1000000,
          divisions: 100,
          labels: RangeLabels('${priceRange.start.round()} TND', '${priceRange.end.round()} TND'),
          onChanged: (values) {
            setState(() => priceRange = values);
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
        const Text('Sort By', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButton<String>(
          value: sortBy,
          isExpanded: true,
          items: [
            const DropdownMenuItem(value: 'newest', child: Text('Most Recent')),
            const DropdownMenuItem(value: 'price_asc', child: Text('Price: Low to High')),
            const DropdownMenuItem(value: 'price_desc', child: Text('Price: High to Low')),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() => sortBy = value);
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
                priceRange = const RangeValues(0, 1000000);
                searchQuery = '';
                sortBy = 'newest';
              });
              _applyFilters();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[300], foregroundColor: Colors.black87),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.filter_list),
            label: const Text('Apply'),
            onPressed: _applyFilters,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
          ),
        ),
      ],
    );
  }
}