import '../entities/property.dart';

abstract class PropertyRepository {
  Future<List<Property>> getProperties({
    String? category,
    double? minPrice,
    double? maxPrice,
    double? minReturn,
    double? maxReturn,
    List<String>? riskLevels,
  });
  
  Future<Property> getPropertyById(String id);
  Future<List<Property>> getFeaturedProperties();
}