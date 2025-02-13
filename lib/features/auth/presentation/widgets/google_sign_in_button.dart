/*import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class GoogleSignInButton extends StatelessWidget {
  final AuthService authService;

  const GoogleSignInButton({
    Key? key,
    required this.authService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        final token = await authService.signInWithGoogle();
        if (token != null) {
          // Handle successful sign in
          print('Signed in successfully');
        } else {
          // Handle sign in failure
          print('Sign in failed');
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/google_logo.png',
            height: 24.0,
          ),
          const SizedBox(width: 12.0),
          const Text('Sign in with Google'),
        ],
      ),
    );
  }
}
*/