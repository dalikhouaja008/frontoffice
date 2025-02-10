import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import '../bloc/sign_up_bloc.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset('assets/animations/auth.json', height: 150), // 🎨 Animation
                  SizedBox(height: 20),
                  Text(
                    "Create Your Account",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        CustomTextField(
                          controller: _usernameController,
                          label: "Username",
                          icon: Icons.person,
                          validator: (value) => value!.isEmpty ? "Enter your username" : null,
                        ),
                        SizedBox(height: 16),
                        CustomTextField(
                          controller: _emailController,
                          label: "Email",
                          icon: Icons.email,
                          validator: (value) {
                            if (value!.isEmpty) return "Enter your email";
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                              return "Enter a valid email";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        CustomTextField(
                          controller: _passwordController,
                          label: "Password",
                          icon: Icons.lock,
                          obscureText: _obscureText,
                          suffixIcon: IconButton(
                            icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
                            onPressed: () {
                              setState(() => _obscureText = !_obscureText);
                            },
                          ),
                          validator: (value) => value!.length < 6 ? "Password too short" : null,
                        ),
                        SizedBox(height: 16),
                        CustomTextField(
                          controller: _confirmPasswordController,
                          label: "Confirm Password",
                          icon: Icons.lock_outline,
                          obscureText: true,
                          validator: (value) {
                            if (value != _passwordController.text) {
                              return "Passwords do not match";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        BlocConsumer<SignUpBloc, SignUpState>(
                          listener: (context, state) {
                            if (state is SignUpFailure) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(state.error), backgroundColor: Colors.red),
                              );
                            } else if (state is SignUpSuccess) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Sign-Up Successful!"), backgroundColor: Colors.green),
                              );
                              // TODO: Navigate to login or home screen
                            }
                          },
                          builder: (context, state) {
                            return CustomButton(
                              text: "Sign Up",
                              isLoading: state is SignUpLoading,
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  context.read<SignUpBloc>().add(SignUpRequested(
                                    username: _usernameController.text.trim(),
                                    email: _emailController.text.trim(),
                                    password: _passwordController.text.trim(),
                                    role: "user",
                                  ));
                                }
                              },
                            );
                          },
                        ),
                        SizedBox(height: 20),
                        TextButton(
                          onPressed: () {
                            
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => LoginScreen()), // ✅ Navigate to Login
                            );
                          },
                          child: Text("Already have an account? Log in"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
