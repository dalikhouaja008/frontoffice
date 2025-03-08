import 'package:flutter/material.dart';
import '../../domain/entities/property.dart';


enum PropertyLoadingStatus { initial, loading, loaded, error }

class PropertyController with ChangeNotifier {
  PropertyLoadingStatus _status = PropertyLoadingStatus.initial;
  List<Property> _properties = [];
  String? _errorMessage;
  
  // Filter state
  String _selectedCategory = 'All';
  RangeValues _priceRange = RangeValues(100, 50000);
  RangeValues _returnRange = RangeValues(5, 20);
  List<String> _selectedRiskLevels = ['Low', 'Medium', 'Medium-High', 'High'];


  PropertyLoadingStatus get status => _status;
  List<Property> get properties => _properties;
  String? get errorMessage => _errorMessage;
  
  String get selectedCategory => _selectedCategory;
  RangeValues get priceRange => _priceRange;
  RangeValues get returnRange => _returnRange;
  List<String> get selectedRiskLevels => _selectedRiskLevels;

  List<Property> get filteredProperties {
    return _properties.where((property) {
      // Filter by category
      if (_selectedCategory != 'All' && property.category != _selectedCategory) {
        return false;
      }
      
      // Filter by price range
      if (property.minInvestment < _priceRange.start || 
          property.minInvestment > _priceRange.end) {
        return false;
      }
      
      // Filter by return range
      if (property.projectedReturn < _returnRange.start || 
          property.projectedReturn > _returnRange.end) {
        return false;
      }
      
      // Filter by risk level
      if (!_selectedRiskLevels.contains(property.riskLevel)) {
        return false;
      }
      
      return true;
    }).toList();
  }

  Future<void> loadProperties() async {
    _status = PropertyLoadingStatus.loading;
    _errorMessage = null;
    notifyListeners();

    
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setPriceRange(RangeValues range) {
    _priceRange = range;
    notifyListeners();
  }

  void setReturnRange(RangeValues range) {
    _returnRange = range;
    notifyListeners();
  }

  void toggleRiskLevel(String riskLevel) {
    if (_selectedRiskLevels.contains(riskLevel)) {
      _selectedRiskLevels.remove(riskLevel);
    } else {
      _selectedRiskLevels.add(riskLevel);
    }
    notifyListeners();
  }

  void resetFilters() {
    _selectedCategory = 'All';
    _priceRange = RangeValues(100, 50000);
    _returnRange = RangeValues(5, 20);
    _selectedRiskLevels = ['Low', 'Medium', 'Medium-High', 'High'];
    notifyListeners();
  }
}