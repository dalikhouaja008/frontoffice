import 'package:the_boost/features/auth/data/models/land_model.dart';

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
    
    return MockData.properties.where((land) {
      // Filter by category if specified
      if (category != null && category != 'All' && land.type.toString() != category) {
        return false;
      }
      
      // Filter by price range
      if (minPrice != null && land.price < minPrice) {
        return false;
      }
      if (maxPrice != null && land.price > maxPrice) {
        return false;
      }
      
      // Filter by return range (assuming projectedReturn is a property of Land)
      if (minReturn != null && land.price < minReturn) { // Adjust this condition based on actual property
        return false;
      }
      if (maxReturn != null && land.price > maxReturn) { // Adjust this condition based on actual property
        return false;
      }
      
      // Filter by risk levels (assuming riskLevel is a property of Land)
      if (riskLevels != null && riskLevels.isNotEmpty && !riskLevels.contains(land.status.toString())) { // Adjust this condition based on actual property
        return false;
      }
      
      return true;
    }).map((land) => Property(
      id: land.id,
      title: land.title ?? land.name,
      location: land.location,
      category: land.type.toString(),
      minInvestment: land.price, // Adjust this based on actual property
      tokenPrice: land.price, // Adjust this based on actual property
      totalValue: land.price, // Adjust this based on actual property
      projectedReturn: land.price, // Adjust this based on actual property
      riskLevel: land.status.toString(), // Adjust this based on actual property
      availableTokens: 100, // Placeholder value, adjust based on actual property
      fundingPercentage: 50.0, // Placeholder value, adjust based on actual property
      imageUrl: land.imageUrl,
      isFeatured: false, // Placeholder value, adjust based on actual property
    )).toList();
  }

  @override
  Future<Property> getPropertyById(String id) async {
    await Future.delayed(Duration(milliseconds: 300)); // Simulate network delay
    
    final land = MockData.properties.firstWhere(
      (land) => land.id == id,
      orElse: () => throw Exception('Property not found'),
    );
    
    return Property(
      id: land.id,
      title: land.title ?? land.name,
      location: land.location,
      category: land.type.toString(),
      minInvestment: land.price, // Adjust this based on actual property
      tokenPrice: land.price, // Adjust this based on actual property
      totalValue: land.price, // Adjust this based on actual property
      projectedReturn: land.price, // Adjust this based on actual property
      riskLevel: land.status.toString(), // Adjust this based on actual property
      availableTokens: 100, // Placeholder value, adjust based on actual property
      fundingPercentage: 50.0, // Placeholder value, adjust based on actual property
      imageUrl: land.imageUrl,
      isFeatured: false, // Placeholder value, adjust based on actual property
    );
  }

  @override
  Future<List<Property>> getFeaturedProperties() async {
    await Future.delayed(Duration(milliseconds: 500)); // Simulate network delay
    
    return MockData.properties.where((land) => land.status == LandStatus.AVAILABLE).map((land) => Property(
      id: land.id,
      title: land.title ?? land.name,
      location: land.location,
      category: land.type.toString(),
      minInvestment: land.price, // Adjust this based on actual property
      tokenPrice: land.price, // Adjust this based on actual property
      totalValue: land.price, // Adjust this based on actual property
      projectedReturn: land.price, // Adjust this based on actual property
      riskLevel: land.status.toString(), // Adjust this based on actual property
      availableTokens: 100, // Placeholder value, adjust based on actual property
      fundingPercentage: 50.0, // Placeholder value, adjust based on actual property
      imageUrl: land.imageUrl,
      isFeatured: true, // Placeholder value, adjust based on actual property
    )).toList();
  }
}