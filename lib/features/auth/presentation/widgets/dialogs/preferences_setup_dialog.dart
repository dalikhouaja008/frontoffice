// lib/features/auth/presentation/widgets/dialogs/preferences_setup_dialog.dart
import 'package:flutter/material.dart';
import 'package:the_boost/core/constants/colors.dart';
import 'package:the_boost/core/constants/dimensions.dart';
import 'package:the_boost/core/constants/text_styles.dart';
import 'package:the_boost/features/auth/domain/entities/user_preferences.dart';

class PreferencesSetupDialog extends StatefulWidget {
  final UserPreferences initialPreferences;
  final Function(UserPreferences) onSave;

  const PreferencesSetupDialog({
    Key? key,
    required this.initialPreferences,
    required this.onSave,
  }) : super(key: key);

  @override
  _PreferencesSetupDialogState createState() => _PreferencesSetupDialogState();
}

class _PreferencesSetupDialogState extends State<PreferencesSetupDialog> {
  late List<String> _selectedCategories;
  late RangeValues _priceRange;
  late RangeValues _returnRange;
  late List<String> _selectedRiskLevels;
  late List<String> _selectedLocations;
  late bool _notificationsEnabled;
  
  final List<String> _allCategories = [
    'Residential',
    'Commercial',
    'Agricultural',
    'Industrial',
    'Mixed-Use',
    'Conservation',
  ];
  
  final List<String> _allRiskLevels = [
    'Low',
    'Medium',
    'Medium-High',
    'High',
  ];
  
  final List<String> _allLocations = [
    'Phoenix, Arizona',
    'Austin, Texas',
    'Nashville, Tennessee',
    'Seattle, Washington',
    'Riverside, California',
    'Boulder, Colorado',
    'Miami, Florida',
    'New York, New York',
    'Chicago, Illinois',
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategories = List.from(widget.initialPreferences.preferredCategories);
    _priceRange = RangeValues(
      widget.initialPreferences.minPrice,
      widget.initialPreferences.maxPrice,
    );
    _returnRange = RangeValues(
      widget.initialPreferences.minReturn,
      widget.initialPreferences.maxReturn,
    );
    _selectedRiskLevels = List.from(widget.initialPreferences.preferredRiskLevels);
    _selectedLocations = List.from(widget.initialPreferences.preferredLocations);
    _notificationsEnabled = widget.initialPreferences.notificationsEnabled;
  }

  void _savePreferences() {
    final newPreferences = UserPreferences(
      preferredCategories: _selectedCategories,
      minPrice: _priceRange.start,
      maxPrice: _priceRange.end,
      minReturn: _returnRange.start,
      maxReturn: _returnRange.end,
      preferredRiskLevels: _selectedRiskLevels,
      preferredLocations: _selectedLocations,
      notificationsEnabled: _notificationsEnabled,
    );
    
    widget.onSave(newPreferences);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Investment Preferences',
                    style: AppTextStyles.h2,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.paddingM),
              Text(
                'Set your preferences to get personalized investment recommendations and notifications.',
                style: AppTextStyles.body2,
              ),
              const SizedBox(height: AppDimensions.paddingL),
              
              // Property Type Selection
              Text(
                'Property Types',
                style: AppTextStyles.h4,
              ),
              const SizedBox(height: AppDimensions.paddingS),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: _allCategories.map((category) {
                  final isSelected = _selectedCategories.contains(category);
                  return FilterChip(
                    label: Text(
                      category,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedCategories.add(category);
                        } else {
                          _selectedCategories.remove(category);
                        }
                      });
                    },
                    backgroundColor: Colors.grey.shade200,
                    selectedColor: AppColors.primary,
                  );
                }).toList(),
              ),
              const SizedBox(height: AppDimensions.paddingL),
              
              // Price Range Selection
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Investment Range',
                    style: AppTextStyles.h4,
                  ),
                  Text(
                    '\$${_priceRange.start.round()} - \$${_priceRange.end.round()}',
                    style: AppTextStyles.body3,
                  ),
                ],
              ),
              RangeSlider(
                min: 100,
                max: 50000,
                divisions: 100,
                values: _priceRange,
                activeColor: AppColors.primary,
                inactiveColor: Colors.grey.shade300,
                labels: RangeLabels(
                  '\$${_priceRange.start.round()}',
                  '\$${_priceRange.end.round()}',
                ),
                onChanged: (values) {
                  setState(() {
                    _priceRange = values;
                  });
                },
              ),
              const SizedBox(height: AppDimensions.paddingL),
              
              // Return Range Selection
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Projected Return',
                    style: AppTextStyles.h4,
                  ),
                  Text(
                    '${_returnRange.start.round()}% - ${_returnRange.end.round()}%',
                    style: AppTextStyles.body3,
                  ),
                ],
              ),
              RangeSlider(
                min: 5,
                max: 20,
                divisions: 15,
                values: _returnRange,
                activeColor: AppColors.primary,
                inactiveColor: Colors.grey.shade300,
                labels: RangeLabels(
                  '${_returnRange.start.round()}%',
                  '${_returnRange.end.round()}%',
                ),
                onChanged: (values) {
                  setState(() {
                    _returnRange = values;
                  });
                },
              ),
              const SizedBox(height: AppDimensions.paddingL),
              
              // Risk Level Selection
              Text(
                'Risk Level',
                style: AppTextStyles.h4,
              ),
              const SizedBox(height: AppDimensions.paddingS),
              Column(
                children: _allRiskLevels.map((level) {
                  final isSelected = _selectedRiskLevels.contains(level);
                  Color indicatorColor = Colors.green;
                  if (level == 'Medium') indicatorColor = Colors.orange;
                  if (level == 'Medium-High') indicatorColor = Colors.deepOrange;
                  if (level == 'High') indicatorColor = Colors.red;
                  
                  return CheckboxListTile(
                    title: Row(
                      children: [
                        Text(level),
                        const SizedBox(width: 8),
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: indicatorColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    value: isSelected,
                    activeColor: AppColors.primary,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    onChanged: (selected) {
                      setState(() {
                        if (selected == true) {
                          _selectedRiskLevels.add(level);
                        } else {
                          _selectedRiskLevels.remove(level);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: AppDimensions.paddingL),
              
              // Location Selection
              Text(
                'Preferred Locations',
                style: AppTextStyles.h4,
              ),
              const SizedBox(height: AppDimensions.paddingS),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: _allLocations.map((location) {
                  final isSelected = _selectedLocations.contains(location);
                  return FilterChip(
                    label: Text(
                      location,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedLocations.add(location);
                        } else {
                          _selectedLocations.remove(location);
                        }
                      });
                    },
                    backgroundColor: Colors.grey.shade200,
                    selectedColor: AppColors.primary,
                  );
                }).toList(),
              ),
              const SizedBox(height: AppDimensions.paddingL),
              
              // Notifications Toggle
              SwitchListTile(
                title: Text(
                  'Enable Notifications',
                  style: AppTextStyles.h4,
                ),
                subtitle: Text(
                  'Get notified about new investment opportunities matching your preferences',
                  style: AppTextStyles.body3,
                ),
                value: _notificationsEnabled,
                activeColor: AppColors.primary,
                contentPadding: EdgeInsets.zero,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
              ),
              const SizedBox(height: AppDimensions.paddingXL),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _savePreferences,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    ),
                  ),
                  child: const Text(
                    'Save Preferences',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
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
}