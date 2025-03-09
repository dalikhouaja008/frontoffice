// lib/features/auth/presentation/pages/preferences/user_preferences_screen.dart
import 'package:flutter/material.dart';
import 'package:the_boost/core/constants/colors.dart';
import 'package:the_boost/core/constants/dimensions.dart';
import 'package:the_boost/core/constants/text_styles.dart';
import 'package:the_boost/core/services/notification_service.dart';
import 'package:the_boost/core/services/secure_storage_service.dart';
import 'package:the_boost/features/auth/data/models/land_model.dart';
import 'package:the_boost/features/auth/domain/entities/user.dart';
import 'package:the_boost/features/auth/domain/entities/user_preferences.dart';
import 'package:the_boost/features/auth/presentation/widgets/buttons/app_button.dart';
import 'dart:convert';

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
  final SecureStorageService _storageService = SecureStorageService();
  final NotificationService _notificationService = NotificationService();
  
  // Selected values for UI
   List<LandType> _selectedLandTypes = [];
   List<String> _selectedLocations = [];
  double _minPrice = 0;
  double _maxPrice = 1000000;
  double _maxDistance = 50;
  bool _notificationsEnabled = true;
  
  // Controllers for adding new locations
  final TextEditingController _locationController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }
  
  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }
  
  Future<void> _loadPreferences() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Try to load existing preferences
      final prefsJson = await _storageService.read(key: 'user_preferences_${widget.user.id}');
      
      if (prefsJson != null) {
        final prefs = UserPreferences.fromJson(jsonDecode(prefsJson));
        setState(() {
          _preferences = prefs;
          _selectedLandTypes = List.from(prefs.preferredLandTypes);
          _selectedLocations = List.from(prefs.preferredLocations);
          _minPrice = prefs.minPrice;
          _maxPrice = prefs.maxPrice == double.infinity ? 1000000 : prefs.maxPrice;
          _maxDistance = prefs.maxDistanceKm;
          _notificationsEnabled = prefs.notificationsEnabled;
        });
      } else {
        // Use default preferences
        setState(() {
          _preferences = UserPreferences.defaultPreferences();
          _selectedLandTypes = List.from(_preferences!.preferredLandTypes);
          _selectedLocations = List.from(_preferences!.preferredLocations);
          _minPrice = _preferences!.minPrice;
          _maxPrice = _preferences!.maxPrice == double.infinity ? 1000000 : _preferences!.maxPrice;
          _maxDistance = _preferences!.maxDistanceKm;
          _notificationsEnabled = _preferences!.notificationsEnabled;
        });
      }
    } catch (e) {
      print('Error loading preferences: $e');
      // Use default preferences in case of error
      setState(() {
        _preferences = UserPreferences.defaultPreferences();
        _selectedLandTypes = List.from(_preferences!.preferredLandTypes);
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _savePreferences() async {
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
      
      // Save to secure storage
      final jsonData = jsonEncode(updatedPreferences.toJson());
      await _storageService.write(
        key: 'user_preferences_${widget.user.id}',
        value: jsonData,
      );
      
      setState(() {
        _preferences = updatedPreferences;
      });
      
      // Show success feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Preferences saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error saving preferences: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving preferences: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }
  
  void _toggleLandType(LandType type) {
    setState(() {
      if (_selectedLandTypes.contains(type)) {
        _selectedLandTypes.remove(type);
      } else {
        _selectedLandTypes.add(type);
      }
    });
  }
  
  void _addLocation() {
    final location = _locationController.text.trim();
    if (location.isNotEmpty && !_selectedLocations.contains(location)) {
      setState(() {
        _selectedLocations.add(location);
        _locationController.clear();
      });
    }
  }
  
  void _removeLocation(String location) {
    setState(() {
      _selectedLocations.remove(location);
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Investment Preferences'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
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
    );
  }
  
  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: AppColors.backgroundGreen,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Land Types',
          style: AppTextStyles.h4,
        ),
        const SizedBox(height: 8),
        const Text(
          'Select the types of land you\'re interested in',
          style: TextStyle(
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingM),
        Wrap(
          spacing: AppDimensions.paddingS,
          runSpacing: AppDimensions.paddingS,
          children: LandType.values.map((type) {
            final isSelected = _selectedLandTypes.contains(type);
            return FilterChip(
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
            );
          }).toList(),
        ),
      ],
    );
  }
  
  Widget _buildPriceRangeSection() {
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
              '\${_minPrice.toInt()}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '\${_maxPrice.toInt()}',
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
            '\${_minPrice.toInt()}',
            '\${_maxPrice.toInt()}',
          ),
          onChanged: (values) {
            setState(() {
              _minPrice = values.start;
              _maxPrice = values.end;
            });
          },
          activeColor: AppColors.primary,
          inactiveColor: Colors.grey.shade300,
        ),
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
              child: TextField(
                controller: _locationController,
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
                onSubmitted: (_) => _addLocation(),
              ),
            ),
            const SizedBox(width: AppDimensions.paddingM),
            ElevatedButton(
              onPressed: _addLocation,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                minimumSize: const Size(48, 48),
              ),
              child: const Icon(Icons.add),
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
          Wrap(
            spacing: AppDimensions.paddingS,
            runSpacing: AppDimensions.paddingS,
            children: _selectedLocations.map((location) {
              return Chip(
                label: Text(location),
                onDeleted: () => _removeLocation(location),
                deleteIconColor: Colors.grey,
                backgroundColor: Colors.grey.shade200,
              );
            }).toList(),
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
            });
          },
          activeColor: AppColors.primary,
          inactiveColor: Colors.grey.shade300,
        ),
      ],
    );
  }
  
  Widget _buildNotificationsSection() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
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
          });
        },
        activeColor: AppColors.primary,
      ),
    );
  }
  
  Widget _buildSaveButton() {
    return AppButton(
      text: 'Save Preferences',
      onPressed: _savePreferences,
      isLoading: _isSaving,
      isFullWidth: true,
      type: ButtonType.primary,
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