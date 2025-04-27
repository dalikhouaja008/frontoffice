// lib/features/auth/data/repositories/property_repository_impl.dart
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:the_boost/core/di/dependency_injection.dart';
import 'package:the_boost/core/network/graphql_client.dart'; // Assuming you use GraphQL for API calls
import 'package:the_boost/features/auth/data/models/property_model.dart';
import '../../domain/entities/property.dart';
import '../../domain/repositories/property_repository.dart';

class PropertyRepositoryImpl implements PropertyRepository {
  final GraphQLClient _graphQLClient;

  PropertyRepositoryImpl({GraphQLClient? graphQLClient})
      : _graphQLClient = graphQLClient ?? getIt<GraphQLClient>();

  @override
  Future<List<Property>> getProperties({
    String? category,
    double? minPrice,
    double? maxPrice,
    double? minReturn,
    double? maxReturn,
    List<String>? riskLevels,
  }) async {
    try {
      // Define the GraphQL query
      const String query = '''
        query GetProperties {
          properties {
            id
            title
            location
            category
            minInvestment
            tokenPrice
            totalValue
            projectedReturn
            riskLevel
            availableTokens
            fundingPercentage
            image
            featured
          }
        }
      ''';

      // Execute the query
      final QueryOptions options = QueryOptions(document: gql(query));
      final QueryResult result = await _graphQLClient.query(options);

      // Handle errors
      if (result.hasException) {
        throw Exception('Failed to fetch properties: ${result.exception.toString()}');
      }

      // Parse the response into a list of Property objects
      final List<dynamic> propertyData = result.data?['properties'] as List<dynamic>;
      final List<Property> properties = propertyData.map((data) => PropertyModel.fromJson(data)).toList();

      // Apply filters
      return properties.where((property) {
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
        if (riskLevels != null &&
            riskLevels.isNotEmpty &&
            !riskLevels.contains(property.riskLevel)) {
          return false;
        }

        return true;
      }).toList();
    } catch (e) {
      print('[${DateTime.now()}] PropertyRepositoryImpl: ❌ Error fetching properties'
          '\n└─ Error: $e');
      rethrow; // Re-throw for UI handling
    }
  }

  @override
  Future<Property> getPropertyById(String id) async {
    try {
      // Define the GraphQL query
      const String query = '''
        query GetPropertyById(\$id: ID!) {
          property(id: \$id) {
            id
            title
            location
            category
            minInvestment
            tokenPrice
            totalValue
            projectedReturn
            riskLevel
            availableTokens
            fundingPercentage
            image
            featured
          }
        }
      ''';

      // Execute the query with variables
      final QueryOptions options = QueryOptions(
        document: gql(query),
        variables: {'id': id},
      );
      final QueryResult result = await _graphQLClient.query(options);

      // Handle errors
      if (result.hasException) {
        throw Exception('Failed to fetch property by ID: ${result.exception.toString()}');
      }

      // Parse the response into a Property object
      final Map<String, dynamic> propertyData = result.data?['property'];
      return PropertyModel.fromJson(propertyData);
    } catch (e) {
      print('[${DateTime.now()}] PropertyRepositoryImpl: ❌ Error fetching property by ID'
          '\n└─ Property ID: $id'
          '\n└─ Error: $e');
      rethrow; // Re-throw for UI handling
    }
  }

  @override
  Future<List<Property>> getFeaturedProperties() async {
    try {
      // Define the GraphQL query
      const String query = '''
        query GetFeaturedProperties {
          properties(filter: {featured: true}) {
            id
            title
            location
            category
            minInvestment
            tokenPrice
            totalValue
            projectedReturn
            riskLevel
            availableTokens
            fundingPercentage
            image
            featured
          }
        }
      ''';

      // Execute the query
      final QueryOptions options = QueryOptions(document: gql(query));
      final QueryResult result = await _graphQLClient.query(options);

      // Handle errors
      if (result.hasException) {
        throw Exception('Failed to fetch featured properties: ${result.exception.toString()}');
      }

      // Parse the response into a list of Property objects
      final List<dynamic> propertyData = result.data?['properties'] as List<dynamic>;
      return propertyData.map((data) => PropertyModel.fromJson(data)).toList();
    } catch (e) {
      print('[${DateTime.now()}] PropertyRepositoryImpl: ❌ Error fetching featured properties'
          '\n└─ Error: $e');
      rethrow; // Re-throw for UI handling
    }
  }
}