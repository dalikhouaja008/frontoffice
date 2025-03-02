import '../../domain/entities/property.dart';
import '../../domain/repositories/property_repository.dart';
import '../datasources/mock_data.dart';

class PropertyRepositoryImpl implements PropertyRepository {
  @override
  Future<List<Property>> getProperties({
    String? category,
    double? minPrice,
    double? maxPrice,
    double? minReturn,
    double? maxReturn,
    List<String>? riskLevels,
  }) async {
    // For now, we'll use mock data but later this would fetch from a real API
    await Future.delayed(Duration(milliseconds: 800)); // Simulate network delay
    
    return MockData.properties.where((property) {
      // Filter by category if specified
      if (category != null && category != 'All' && property.category != category) {
        return false;
      }
      
      // Filter by price range
      if (minPrice != null && property.minInvestment < minPrice) {
        return false;
      }
      if (maxPrice != null && property.minInvestment > maxPrice) {
        return false;
      }
      
      // Filter by return range
      if (minReturn != null && property.projectedReturn < minReturn) {
        return false;
      }
      if (maxReturn != null && property.projectedReturn > maxReturn) {
        return false;
      }
      
      // Filter by risk levels
      if (riskLevels != null && riskLevels.isNotEmpty && !riskLevels.contains(property.riskLevel)) {
        return false;
      }
      
      return true;
    }).toList();
  }

  @override
  Future<Property> getPropertyById(String id) async {
    await Future.delayed(Duration(milliseconds: 300)); // Simulate network delay
    
    final property = MockData.properties.firstWhere(
      (property) => property.id == id,
      orElse: () => throw Exception('Property not found'),
    );
    
    return property;
  }

  @override
  Future<List<Property>> getFeaturedProperties() async {
    await Future.delayed(Duration(milliseconds: 500)); // Simulate network delay
    
    return MockData.properties.where((property) => property.isFeatured).toList();
  }
}