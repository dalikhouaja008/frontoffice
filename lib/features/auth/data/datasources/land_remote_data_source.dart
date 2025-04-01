import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:the_boost/core/services/api_service.dart';
import 'package:the_boost/features/auth/data/models/land_model.dart';

/// Abstract class defining the contract for fetching lands remotely
abstract class LandRemoteDataSource {
  Future<List<Land>> fetchLands({
    int page = 1,
    int limit = 20,
    Map<String, dynamic>? filters,
  });
}

/// Implementation of the LandRemoteDataSource using ApiService
class LandRemoteDataSourceImpl implements LandRemoteDataSource {
  final ApiService _apiService;

  LandRemoteDataSourceImpl({required ApiService apiService})
      : _apiService = apiService;

  @override
  Future<List<Land>> fetchLands({
    int page = 1,
    int limit = 20,
    Map<String, dynamic>? filters,
  }) async {
    try {
      // Get the GraphQL client with authentication headers
      final authLink = await _apiService.getAuthLink();
      final httpLink = HttpLink('https://your-backend-api.com/graphql');
      final link = authLink.concat(httpLink);

      final GraphQLClient client = GraphQLClient(
        cache: GraphQLCache(),
        link: link,
      );

      // Build the GraphQL query for fetching lands
      const String query = r'''
        query FetchLands($page: Int, $limit: Int, $filters: LandFilterInput) {
          lands(page: $page, limit: $limit, filters: $filters) {
            id
            title
            description
            location
            type
            status
            price
            ownerId
            latitude
            longitude
            ipfsCIDs
            imageCIDs
            createdAt
          }
        }
      ''';

      // Define query variables (pagination and filters)
      final variables = {
        'page': page,
        'limit': limit,
        if (filters != null) 'filters': filters,
      };

      // Execute the query
      final QueryResult result = await client.query(
        QueryOptions(
          document: gql(query),
          variables: variables,
        ),
      );

      // Handle errors
      if (result.hasException) {
        throw Exception(
            'GraphQL Error: ${result.exception?.graphqlErrors.map((e) => e.message).join(", ")}');
      }

      // Parse the response into a list of Land objects
      final List<dynamic> data = result.data?['lands'] as List<dynamic>;
      return data.map((json) => Land.fromJson(json)).toList();
    } catch (e) {
      print('[${DateTime.now()}] LandRemoteDataSource: ❌ Error fetching lands: $e');
      rethrow; // Re-throw the exception for higher-level error handling
    }
  }
}