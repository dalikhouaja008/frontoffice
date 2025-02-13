import 'package:google_sign_in/google_sign_in.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
  );

  final GraphQLClient _client; // Your GraphQL client instance

  AuthService(this._client);

  Future<String?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Send token to backend
      final QueryResult result = await _client.mutate(
        MutationOptions(
          document: gql('''
            mutation GoogleSignIn(\$token: String!) {
              googleSignIn(token: \$token) {
                accessToken
                user {
                  id
                  email
                  name
                }
              }
            }
          '''),
          variables: {
            'token': googleAuth.idToken,
          },
        ),
      );

      if (result.hasException) {
        throw result.exception!;
      }

      return result.data?['googleSignIn']['accessToken'];
    } catch (error) {
      print('Error signing in with Google: $error');
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}