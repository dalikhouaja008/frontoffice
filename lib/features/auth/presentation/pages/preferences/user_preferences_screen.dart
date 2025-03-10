import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_boost/core/constants/colors.dart';
import 'package:the_boost/core/constants/dimensions.dart';
import 'package:the_boost/core/constants/text_styles.dart';
import 'package:the_boost/core/di/dependency_injection.dart';
import 'package:the_boost/core/services/notification_service.dart';
import 'package:the_boost/core/services/preferences_service.dart';
import 'package:the_boost/core/services/secure_storage_service.dart';
import 'package:the_boost/core/utils/responsive_helper.dart';
import 'package:the_boost/features/auth/data/models/land_model.dart';
import 'package:the_boost/features/auth/domain/entities/user.dart';
import 'package:the_boost/features/auth/domain/entities/user_preferences.dart';
import 'package:the_boost/features/auth/presentation/bloc/preferences/preferences_bloc.dart';
import 'package:the_boost/features/auth/presentation/widgets/buttons/app_button.dart';
import 'dart:convert';
import 'dart:math';

class UserPreferencesScreen extends StatefulWidget {
  final User user;
  
  const UserPreferencesScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<UserPreferencesScreen> createState() => _UserPreferencesScreenState();
}

class _UserPreferencesScreenState extends State<UserPreferencesScreen> {
  UserPreferences? _preferences;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _hasChanges = false;
  final PreferencesService _preferencesService = PreferencesService();
  
  // Selected values for UI
   List<LandType> _selectedLandTypes = [];
   List<String> _selectedLocations = [];
  double _minPrice = 0;
  double _maxPrice = 1000000;
  double _maxDistance = 50;
  bool _notificationsEnabled = true;
  
  // Controllers for adding new locations
  final TextEditingController _locationController = TextEditingController();
  final FocusNode _locationFocusNode = FocusNode();
  
  // For web accessibility
  final _formKey = GlobalKey<FormState>();
  
  @override
  void initState() {
    super.initState();
    _loadPreferences();
    
    // Initialize the preferences bloc
    final preferencesBloc = BlocProvider.of<PreferencesBloc>(context, listen: false);
    preferencesBloc.add(LoadPreferences());
    preferencesBloc.add(LoadLandTypes());
  }
  
  @override
  void dispose() {
    _locationController.dispose();
    _locationFocusNode.dispose();
    super.dispose();
  }
  
  Future<void> _loadPreferences() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Use the PreferencesService instead of direct storage access
      final prefs = await _preferencesService.getPreferences(widget.user.id);
      
      if (prefs != null) {
        setState(() {
          _preferences = prefs;
          _selectedLandTypes.clear();
          _selectedLandTypes.addAll(prefs.preferredLandTypes);
          _selectedLocations.clear();
          _selectedLocations.addAll(prefs.preferredLocations);
          _minPrice = prefs.minPrice;
          _maxPrice = prefs.maxPrice == double.infinity ? 1000000 : prefs.maxPrice;
          _maxDistance = prefs.maxDistanceKm;
          _notificationsEnabled = prefs.notificationsEnabled;
        });
      } else {
        // Use default preferences
        final defaultPrefs = UserPreferences.defaultPreferences();
        setState(() {
          _preferences = defaultPrefs;
          _selectedLandTypes.clear();
          _selectedLandTypes.addAll(defaultPrefs.preferredLandTypes);
          _selectedLocations.clear();
          _selectedLocations.addAll(defaultPrefs.preferredLocations);
          _minPrice = defaultPrefs.minPrice;
          _maxPrice = defaultPrefs.maxPrice == double.infinity ? 1000000 : defaultPrefs.maxPrice;
          _maxDistance = defaultPrefs.maxDistanceKm;
          _notificationsEnabled = defaultPrefs.notificationsEnabled;
        });
      }
    } catch (e) {
      print('Error loading preferences: $e');
      // Use default preferences in case of error
      final defaultPrefs = UserPreferences.defaultPreferences();
      setState(() {
        _preferences = defaultPrefs;
        _selectedLandTypes.clear();
        _selectedLandTypes.addAll(defaultPrefs.preferredLandTypes);
        _selectedLocations.clear();
        _selectedLocations.addAll(defaultPrefs.preferredLocations);
      });
      
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not load preferences: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
        _hasChanges = false;
      });
    }
  }
  
  void _savePreferences() {
    // Validate form
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isSaving = true;
      });
      
      try {
        final updatedPreferences = UserPreferences(
          preferredLandTypes: _selectedLandTypes,
          minPrice: _minPrice,
          maxPrice: _maxPrice,
          preferredLocations: _selectedLocations,
          maxDistanceKm: _maxDistance,
          notificationsEnabled: _notificationsEnabled,
          lastUpdated: DateTime.now(),
        );
        
        // Use BLoC to save preferences to backend
        final preferencesBloc = BlocProvider.of<PreferencesBloc>(context, listen: false);
        preferencesBloc.add(SavePreferences(updatedPreferences));
        
        // Also update local cache via PreferencesService
        _preferencesService.savePreferences(widget.user.id, updatedPreferences)
          .then((_) {
            setState(() {
              _preferences = updatedPreferences;
              _hasChanges = false;
            });
          })
          .catchError((e) {
            print('Error saving local preferences: $e');
            // No need to show error as BLoC will handle it
          });
      } catch (e) {
        setState(() {
          _isSaving = false;
        });
        
        print('Error creating preferences: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error creating preferences: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      // Show validation error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please check the form for errors'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  void _toggleLandType(LandType type) {
    setState(() {
      if (_selectedLandTypes.contains(type)) {
        _selectedLandTypes.remove(type);
      } else {
        _selectedLandTypes.add(type);
      }
      _hasChanges = true;
    });
  }
  
  void _addLocation() {
    final location = _locationController.text.trim();
    if (location.isNotEmpty && !_selectedLocations.contains(location)) {
      setState(() {
        _selectedLocations.add(location);
        _locationController.clear();
        _hasChanges = true;
      });
      
      // Clear text field and set focus back for web usability
      _locationFocusNode.requestFocus();
    } else if (location.isEmpty) {
      // Show error for empty location
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a location'),
          backgroundColor: Colors.orange,
        ),
      );
    } else if (_selectedLocations.contains(location)) {
      // Show error for duplicate location
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This location is already in your list'),
          backgroundColor: Colors.orange,
        ),
      );
      _locationController.clear();
    }
  }
  
  void _removeLocation(String location) {
    setState(() {
      _selectedLocations.remove(location);
      _hasChanges = true;
    });
  }
  
  void _confirmDiscard() {
    if (_hasChanges) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Discard Changes?'),
          content: const Text('You have unsaved changes. Are you sure you want to discard them?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Discard'),
            ),
          ],
        ),
      );
    } else {
      Navigator.of(context).pop();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final isWeb = kIsWeb;
    final isMobile = ResponsiveHelper.isMobile(context);
    final screenWidth = MediaQuery.of(context).size.width;
    
    return WillPopScope(
      onWillPop: () async {
        if (_hasChanges) {
          _confirmDiscard();
          return false;
        }
        return true;
      },
      child: BlocProvider<PreferencesBloc>(
        create: (context) => getIt<PreferencesBloc>(),
        child: BlocConsumer<PreferencesBloc, PreferencesState>(
          listener: (context, state) {
            if (state is PreferencesSaved) {
              setState(() {
                _preferences = state.preferences;
                _hasChanges = false;
                _isSaving = false;
              });
              
              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Preferences saved successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state is PreferencesSaving) {
              setState(() {
                _isSaving = true;
              });
            } else if (state is PreferencesError) {
              setState(() {
                _isSaving = false;
              });
              
              // Show error message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is PreferencesLoaded) {
              // Only update UI if it's different from current state
              if (_preferences == null || 
                  !_arePreferencesEqual(_preferences!, state.preferences)) {
                setState(() {
                  _preferences = state.preferences;
                  _selectedLandTypes = List.from(state.preferences.preferredLandTypes);
                  _selectedLocations = List.from(state.preferences.preferredLocations);
                  _minPrice = state.preferences.minPrice;
                  _maxPrice = state.preferences.maxPrice == double.infinity ? 1000000 : state.preferences.maxPrice;
                  _maxDistance = state.preferences.maxDistanceKm;
                  _notificationsEnabled = state.preferences.notificationsEnabled;
                  _isLoading = false;
                  _hasChanges = false;
                });
              }
            }
          },
          builder: (context, state) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Investment Preferences'),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    if (_hasChanges) {
                      _confirmDiscard();
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                ),
                actions: [
                  if (_hasChanges)
                    TextButton.icon(
                      icon: const Icon(Icons.save, color: Colors.white),
                      label: const Text('Save', style: TextStyle(color: Colors.white)),
                      onPressed: !_isSaving ? () { _savePreferences(); } : null,
                    ),
                ],
              ),
              body: _isLoading || state is PreferencesLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SafeArea(
                      child: Form(
                        key: _formKey,
                        child: Center(
                          child: Container(
                            width: isWeb && !isMobile ? min(screenWidth * 0.8, 800) : null,
                            padding: EdgeInsets.symmetric(
                              horizontal: isWeb && !isMobile ? AppDimensions.paddingXXL : AppDimensions.paddingL,
                            ),
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(AppDimensions.paddingL),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildInfoCard(),
                                  const SizedBox(height: AppDimensions.paddingL),
                                  _buildLandTypeSection(),
                                  const SizedBox(height: AppDimensions.paddingXL),
                                  _buildPriceRangeSection(),
                                  const SizedBox(height: AppDimensions.paddingXL),
                                  _buildLocationsSection(),
                                  const SizedBox(height: AppDimensions.paddingXL),
                                  _buildDistanceSection(),
                                  const SizedBox(height: AppDimensions.paddingXL),
                                  _buildNotificationsSection(),
                                  const SizedBox(height: AppDimensions.paddingXXL),
                                  _buildSaveButton(),
                                  const SizedBox(height: AppDimensions.paddingL),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
            );
          },
        ),
      ),
    );
  }
  
  // Helper method to compare two preferences objects
  bool _arePreferencesEqual(UserPreferences a, UserPreferences b) {
    if (a.preferredLandTypes.length != b.preferredLandTypes.length) return false;
    if (a.preferredLocations.length != b.preferredLocations.length) return false;
    
    // Compare land types
    for (final type in a.preferredLandTypes) {
      if (!b.preferredLandTypes.contains(type)) return false;
    }
    
    // Compare locations
    for (final location in a.preferredLocations) {
      if (!b.preferredLocations.contains(location)) return false;
    }
    
    // Compare numeric values
    if (a.minPrice != b.minPrice) return false;
    if (a.maxPrice != b.maxPrice) return false;
    if (a.maxDistanceKm != b.maxDistanceKm) return false;
    if (a.notificationsEnabled != b.notificationsEnabled) return false;
    
    return true;
  }
  
  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: AppColors.backgroundGreen,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        boxShadow: kIsWeb ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ] : null,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            color: AppColors.primary,
            size: 32,
          ),
          const SizedBox(width: AppDimensions.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Set your investment preferences',
                  style: AppTextStyles.h4.copyWith(
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'We\'ll notify you when we find lands that match your criteria',
                  style: TextStyle(
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLandTypeSection() {
    // Validate land types selection
    bool isValid = _selectedLandTypes.isNotEmpty;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Land Types',
              style: AppTextStyles.h4,
            ),
            if (!isValid) ...[
              const SizedBox(width: 8),
              const Text(
                '* Required',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Select the types of land you\'re interested in',
          style: TextStyle(
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingM),
        FocusTraversalGroup(
          child: Wrap(
            spacing: AppDimensions.paddingS,
            runSpacing: AppDimensions.paddingS,
            children: LandType.values.map((type) {
              final isSelected = _selectedLandTypes.contains(type);
              return Tooltip(
                message: _getLandTypeName(type),
                child: FilterChip(
                  label: Text(_getLandTypeName(type)),
                  selected: isSelected,
                  onSelected: (selected) => _toggleLandType(type),
                  selectedColor: AppColors.primary.withOpacity(0.2),
                  checkmarkColor: AppColors.primary,
                  backgroundColor: Colors.grey.shade200,
                  avatar: Icon(
                    _getLandTypeIcon(type),
                    color: isSelected ? AppColors.primary : Colors.grey,
                    size: 18,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        if (!isValid) ...[
          const SizedBox(height: 8),
          const Text(
            'Please select at least one land type',
            style: TextStyle(
              color: Colors.red,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
  
  Widget _buildPriceRangeSection() {
    final formatCurrency = (double value) => '\$${value.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Price Range',
          style: AppTextStyles.h4,
        ),
        const SizedBox(height: 8),
        const Text(
          'Adjust your budget range',
          style: TextStyle(
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingL),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              formatCurrency(_minPrice),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              formatCurrency(_maxPrice),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        RangeSlider(
          values: RangeValues(_minPrice, _maxPrice),
          min: 0,
          max: 2000000,
          divisions: 40,
          labels: RangeLabels(
            formatCurrency(_minPrice),
            formatCurrency(_maxPrice),
          ),
          onChanged: (values) {
            setState(() {
              _minPrice = values.start;
              _maxPrice = values.end;
              _hasChanges = true;
            });
          },
          activeColor: AppColors.primary,
          inactiveColor: Colors.grey.shade300,
        ),
        
        // For web accessibility, add input fields
        if (kIsWeb) ...[
          const SizedBox(height: AppDimensions.paddingM),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: _minPrice.toInt().toString(),
                  decoration: const InputDecoration(
                    labelText: 'Min Price (\$)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      final newValue = double.tryParse(value) ?? _minPrice;
                      if (newValue <= _maxPrice) {
                        setState(() {
                          _minPrice = newValue;
                          _hasChanges = true;
                        });
                      }
                    }
                  },
                ),
              ),
              const SizedBox(width: AppDimensions.paddingM),
              Expanded(
                child: TextFormField(
                  initialValue: _maxPrice.toInt().toString(),
                  decoration: const InputDecoration(
                    labelText: 'Max Price (\$)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      final newValue = double.tryParse(value) ?? _maxPrice;
                      if (newValue >= _minPrice) {
                        setState(() {
                          _maxPrice = newValue;
                          _hasChanges = true;
                        });
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
  
  Widget _buildLocationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preferred Locations',
          style: AppTextStyles.h4,
        ),
        const SizedBox(height: 8),
        const Text(
          'Add locations you\'re interested in',
          style: TextStyle(
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingM),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _locationController,
                focusNode: _locationFocusNode,
                decoration: InputDecoration(
                  hintText: 'Enter location (city, region)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingM,
                    vertical: AppDimensions.paddingS,
                  ),
                ),
                onFieldSubmitted: (_) => _addLocation(),
                textInputAction: TextInputAction.done,
              ),
            ),
            const SizedBox(width: AppDimensions.paddingM),
            Tooltip(
              message: 'Add Location',
              child: ElevatedButton(
                onPressed: _addLocation,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(AppDimensions.paddingM),
                  minimumSize: const Size(48, 48),
                  backgroundColor: AppColors.primary,
                ),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.paddingM),
        if (_selectedLocations.isEmpty)
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Center(
              child: Text(
                'No locations added yet',
                style: TextStyle(
                  color: Colors.black54,
                ),
              ),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Wrap(
              spacing: AppDimensions.paddingS,
              runSpacing: AppDimensions.paddingS,
              children: _selectedLocations.map((location) {
                return Chip(
                  label: Text(location),
                  onDeleted: () => _removeLocation(location),
                  deleteIconColor: Colors.grey,
                  backgroundColor: Colors.grey.shade200,
                  elevation: kIsWeb ? 1 : 0,
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
  
  Widget _buildDistanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Maximum Distance',
          style: AppTextStyles.h4,
        ),
        const SizedBox(height: 8),
        const Text(
          'Maximum distance from preferred locations',
          style: TextStyle(
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingM),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('0 km'),
            Text('${_maxDistance.toInt()} km'),
            const Text('200 km'),
          ],
        ),
        Slider(
          value: _maxDistance,
          min: 0,
          max: 200,
          divisions: 20,
          label: '${_maxDistance.toInt()} km',
          onChanged: (value) {
            setState(() {
              _maxDistance = value;
              _hasChanges = true;
            });
          },
          activeColor: AppColors.primary,
          inactiveColor: Colors.grey.shade300,
        ),
        
        // For web accessibility, add input field
        if (kIsWeb) ...[
          const SizedBox(height: AppDimensions.paddingM),
          SizedBox(
            width: 200,
            child: TextFormField(
              initialValue: _maxDistance.toInt().toString(),
              decoration: const InputDecoration(
                labelText: 'Max Distance (km)',
                border: OutlineInputBorder(),
                suffixText: 'km',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                if (value.isNotEmpty) {
                  final newValue = double.tryParse(value) ?? _maxDistance;
                  if (newValue >= 0 && newValue <= 200) {
                    setState(() {
                      _maxDistance = newValue;
                      _hasChanges = true;
                    });
                  }
                }
              },
            ),
          ),
        ],
      ],
    );
  }
  
  Widget _buildNotificationsSection() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: kIsWeb ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ] : null,
      ),
      child: SwitchListTile(
        title: const Text(
          'Enable Notifications',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: const Text(
          'Get notified when new lands match your preferences',
          style: TextStyle(
            fontSize: 12,
          ),
        ),
        value: _notificationsEnabled,
        onChanged: (value) {
          setState(() {
            _notificationsEnabled = value;
            _hasChanges = true;
          });
        },
        activeColor: AppColors.primary,
        secondary: Icon(
          _notificationsEnabled ? Icons.notifications_active : Icons.notifications_off,
          color: _notificationsEnabled ? AppColors.primary : Colors.grey,
        ),
      ),
    );
  }
  
  Widget _buildSaveButton() {
    return ElevatedButton(
      child: Text(_isSaving ? 'Saving...' : 'Save Preferences'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: (_isSaving || !_validateForm()) 
          ? null 
          : () { _savePreferences(); },
    );
  }
  
  bool _validateForm() {
    // Basic validation for required fields
    return _selectedLandTypes.isNotEmpty;
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
    }
  }
  
  IconData _getLandTypeIcon(LandType type) {
    switch (type) {
      case LandType.AGRICULTURAL:
        return Icons.grass;
      case LandType.RESIDENTIAL:
        return Icons.home;
      case LandType.INDUSTRIAL:
        return Icons.factory;
      case LandType.COMMERCIAL:
        return Icons.store;
    }
  }
}