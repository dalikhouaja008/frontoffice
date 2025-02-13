import 'package:graphql_flutter/graphql_flutter.dart';

class GraphQLService {
  static final HttpLink httpLink = HttpLink("http://localhost:3000/graphql");

  static final AuthLink authLink = AuthLink(
    getToken: () async => 'Bearer YOUR_ACCESS_TOKEN',
  );

  static final Link link = authLink.concat(httpLink);

  static final GraphQLClient client = GraphQLClient(
    link: link,
    cache: GraphQLCache(),
  );
}
