import 'package:graphql_flutter/graphql_flutter.dart';

class GraphQLService {
  static const String _graphqlEndpoint = 'http://localhost:3000/graphql';

  // Initialize a client with authentication token
  static GraphQLClient initializeClient(String token) {
    final AuthLink authLink = AuthLink(
      getToken: () => token.isNotEmpty ? 'Bearer $token' : '',
    );

    final HttpLink httpLink = HttpLink(
      _graphqlEndpoint,
      defaultHeaders: {
        'User-Agent': 'Flutter/Web',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );

    final Link link = authLink.concat(httpLink);

    return GraphQLClient(
      link: link,
      cache: GraphQLCache(),
      defaultPolicies: DefaultPolicies(
        query: Policies(
          fetch: FetchPolicy.noCache,
        ),
        mutate: Policies(
          fetch: FetchPolicy.noCache,
        ),
      ),
    );
  }

  // Get an unauthenticated client for public operations
  static GraphQLClient get client {
    final HttpLink httpLink = HttpLink(
      _graphqlEndpoint,
      defaultHeaders: {
        'User-Agent': 'Flutter/Web',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );

    return GraphQLClient(
      link: httpLink,
      cache: GraphQLCache(),
      defaultPolicies: DefaultPolicies(
        query: Policies(
          fetch: FetchPolicy.noCache,
        ),
        mutate: Policies(
          fetch: FetchPolicy.noCache,
        ),
      ),
    );
  }
}