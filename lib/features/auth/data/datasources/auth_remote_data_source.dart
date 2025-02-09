import 'package:graphql_flutter/graphql_flutter.dart';
import '../../../../core/network/graphql_client.dart';
import '../models/user_model.dart';


abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  @override
  Future<UserModel> login(String email, String password) async {
    final GraphQLClient client = GraphQLService.client;

    const String loginMutation = """
      mutation Login(\$email: String!, \$password: String!) {
        login(email: \$email, password: \$password) {
          id
          email
          token
        }
      }
    """;

    final QueryResult result = await client.mutate(
      MutationOptions(
        document: gql(loginMutation),
        variables: {
          "email": email,
          "password": password,
        },
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final userData = result.data?["login"];
    if (userData == null) {
      throw Exception("Invalid response from server");
    }

    return UserModel.fromJson(userData);
  }
}
