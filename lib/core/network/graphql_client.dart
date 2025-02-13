import 'package:graphql_flutter/graphql_flutter.dart';

class GraphQLService {
  static final HttpLink httpLink = HttpLink("http://localhost:3000/graphql");

  // Créer un AuthLink qui obtient le token de SecureStorage
  static AuthLink getAuthLink(String? token) {
    return AuthLink(
      getToken: () async => token != null ? 'Bearer $token' : null,
    );
  }

  // Méthode pour obtenir un client authentifié
  static GraphQLClient getClientWithToken(String? token) {
    final Link link = getAuthLink(token).concat(httpLink);
    return GraphQLClient(
      link: link,
      cache: GraphQLCache(),
    );
  }

  // Client par défaut pour les requêtes non authentifiées
  static final GraphQLClient client = GraphQLClient(
    link: httpLink,
    cache: GraphQLCache(),
  );
}