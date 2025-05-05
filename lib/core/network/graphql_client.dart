import 'package:graphql_flutter/graphql_flutter.dart';

class GraphQLService {
  static const String _timestamp = '2025-02-17 11:55:47';
  static const String _user = 'raednas';

  static GraphQLClient getClientWithToken(String token) {
    print('[$_timestamp] GraphQLService: 🔑 Creating authenticated client'
          '\n└─ User: $_user'
          '\n└─ Has token: ${token.isNotEmpty}');

    final authLink = AuthLink(
      getToken: () => 'Bearer $token',
    );

    final httpLink = HttpLink('http://localhost:4000/graphql');
    
    print('[$_timestamp] GraphQLService: 🔗 Setting up GraphQL link'
          '\n└─ User: $_user'
          '\n└─ Authorization: Bearer ${token.length > 10 ? "${token.substring(0, 10)}..." : token}');

    final link = authLink.concat(httpLink);

    return GraphQLClient(
      link: link,
      cache: GraphQLCache(),
    );
  }

  static GraphQLClient get client {
    final httpLink = HttpLink('http://localhost:4000/graphql');
    return GraphQLClient(
      link: httpLink,
      cache: GraphQLCache(),
    );
  }
}