import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user.dart';
import '../bloc/login_bloc.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  final User user; // ✅ Receive user data

  const HomeScreen({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome, ${user.username}"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // ✅ Logout and go back to login screen
             // context.read<LoginBloc>().add(LogoutRequested());
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.home, size: 80, color: Colors.blue),
            SizedBox(height: 20),
            Text("Hello, ${user.username}!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("Email: ${user.email}", style: TextStyle(fontSize: 18, color: Colors.grey[700])),
            SizedBox(height: 10),
            Text("Role: ${user.role}", style: TextStyle(fontSize: 18, color: Colors.grey[700])),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()), // ✅ Redirect to login
                );
              },
              child: Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }
}
