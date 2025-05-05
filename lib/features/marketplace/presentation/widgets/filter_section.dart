import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/colors.dart';

class FilterSection extends StatefulWidget {
  final Function(String?) onCategoryChanged;
  final Function(String?) onSortByChanged;
  final Function(double?, double?) onPriceRangeChanged;
  final Function(String?) onSearchQueryChanged;

  const FilterSection({
    Key? key,
    required this.onCategoryChanged,
    required this.onSortByChanged,
    required this.onPriceRangeChanged,
    required this.onSearchQueryChanged,
  }) : super(key: key);

  @override
  State<FilterSection> createState() => _FilterSectionState();
}

class _FilterSectionState extends State<FilterSection> {
  String? _selectedCategory;
  String? _selectedSortOption;

  // FIXED: Use proper range values with small steps
  // Using fixed small values to avoid range errors
  final double _minPriceValue = 0.01;
  final double _maxPriceValue = 0.9;
  late RangeValues _priceRange;

  final TextEditingController _searchController = TextEditingController();

  // Land token categories
  final List<String> _categories = [
    'All Categories',
    'Residential',
    'Commercial',
    'Agricultural',
    'Industrial',
    'Mixed Use'
  ];

  // Sort options
  final List<String> _sortOptions = [
    'Price: Low to High',
    'Price: High to Low',
    'Newest First',
    'Highest ROI',
    'Surface Area'
  ];

  @override
  void initState() {
    super.initState();
    // Initialize price range with safe values
    _priceRange = RangeValues(_minPriceValue, _maxPriceValue);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            style: GoogleFonts.poppins(),
            decoration: InputDecoration(
              hintText: 'Search tokens by location or ID',
              hintStyle: GoogleFonts.poppins(color: AppColors.textSecondary),
              prefixIcon: const Icon(Icons.search, color: AppColors.primary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onChanged: (value) {
              widget.onSearchQueryChanged(value.isEmpty ? null : value);
            },
          ),
          const SizedBox(height: 16),

          // Category filter
          Text(
            'Category',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category ||
                    (_selectedCategory == null && category == 'All Categories');
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedCategory =
                            category == 'All Categories' ? null : category;
                      });
                      widget.onCategoryChanged(_selectedCategory);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? AppColors.primary : Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.grey[300]!,
                        ),
                      ),
                      child: Text(
                        category,
                        style: GoogleFonts.poppins(
                          color: isSelected ? Colors.white : Colors.grey[800],
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Price range slider - FIXED to avoid index errors
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Price Range (ETH)',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${_priceRange.start.toStringAsFixed(3)} - ${_priceRange.end.toStringAsFixed(3)} ETH',
                style: GoogleFonts.poppins(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              rangeThumbShape:
                  const RoundRangeSliderThumbShape(enabledThumbRadius: 7),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
            ),
            child: RangeSlider(
              values: _priceRange,
              min: _minPriceValue,
              max: _maxPriceValue,
              // Reduced divisions to avoid range errors - only 9 steps
              divisions: 9,
              activeColor: AppColors.primary,
              inactiveColor: Colors.grey[300],
              labels: RangeLabels(
                '${_priceRange.start.toStringAsFixed(3)}',
                '${_priceRange.end.toStringAsFixed(3)}',
              ),
              onChanged: (RangeValues values) {
                // Safety check to make sure values are within range
                if (values.start >= _minPriceValue &&
                    values.end <= _maxPriceValue) {
                  setState(() {
                    _priceRange = values;
                  });
                }
              },
              onChangeEnd: (RangeValues values) {
                widget.onPriceRangeChanged(values.start, values.end);
              },
            ),
          ),
          const SizedBox(height: 16),

          // Sort options
          Text(
            'Sort By',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedSortOption,
            style: GoogleFonts.poppins(),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            hint: Text('Select sort option', style: GoogleFonts.poppins()),
            items: _sortOptions.map((option) {
              return DropdownMenuItem(
                value: option,
                child: Text(option, style: GoogleFonts.poppins()),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedSortOption = value;
              });
              widget.onSortByChanged(value);
            },
          ),
          const SizedBox(height: 16),

          // Apply/Clear filters
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.onSearchQueryChanged(_searchController.text.isEmpty
                        ? null
                        : _searchController.text);
                    widget.onCategoryChanged(_selectedCategory);
                    widget.onPriceRangeChanged(
                        _priceRange.start, _priceRange.end);
                    widget.onSortByChanged(_selectedSortOption);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    textStyle: GoogleFonts.poppins(),
                  ),
                  child: const Text('Apply Filters'),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _selectedCategory = null;
                    _selectedSortOption = null;
                    _priceRange = RangeValues(_minPriceValue, _maxPriceValue);
                    _searchController.clear();
                  });
                  widget.onSearchQueryChanged(null);
                  widget.onCategoryChanged(null);
                  widget.onPriceRangeChanged(null, null);
                  widget.onSortByChanged(null);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey[700],
                  side: BorderSide(color: Colors.grey[300]!),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  textStyle: GoogleFonts.poppins(),
                ),
                child: const Text('Clear All'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
