import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../bloc/login_bloc.dart';
import '../../domain/use_cases/login_use_case.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/social_button.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool rememberMe = false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    bool isMobile = size.width < 800;

    return Scaffold(
      body: BlocProvider(
        create: (context) => LoginBloc(context.read<LoginUseCase>()),
        child: BlocConsumer<LoginBloc, LoginState>(
          listener: (context, state) {
            if (state is LoginSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Login Successful! Welcome ${state.user.email}")),
              );
            } else if (state is LoginFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error)),
              );
            }
          },
          builder: (context, state) {
            return SafeArea(
              child: Container(
                width: size.width,
                height: size.height,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/background.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: isMobile
                        ? _buildMobileLayout(context, state)
                        : _buildWebLayout(context, state),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// 📱 **Mobile Layout: Single Column**
  Widget _buildMobileLayout(BuildContext context, LoginState state) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildWelcomeSection(),
          SizedBox(height: 30),
          _buildLoginForm(context, state),
        ],
      ),
    );
  }

  /// 🖥️ **Web Layout: Two Columns (Left: Welcome, Right: Login + Animation)**
  Widget _buildWebLayout(BuildContext context, LoginState state) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: _buildWelcomeSection(),
        ),
        Expanded(
          flex: 1,
          child: _buildLoginForm(context, state),
        ),
      ],
    );
  }

  /// ✨ **Left Section: Logo & Welcome Message**
  Widget _buildWelcomeSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(radius: 60, backgroundColor: Colors.white, backgroundImage: AssetImage('assets/logo.png')),
        SizedBox(height: 20),
        Text(
          "Welcome to TheBoost",
          style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 10),
        Text(
          "Invest in land through tokenized assets and grow your portfolio",
          style: GoogleFonts.poppins(fontSize: 16, color: Colors.white70),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// 🔐 **Right Section: Login Form + Animation**
  Widget _buildLoginForm(BuildContext context, LoginState state) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Lottie.asset('assets/animations/auth.json', height: 180), // Increased animation size for better visual effect
          SizedBox(height: 20),
          Text(
            "Login to TheBoost",
            style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Form(
            key: _formKey,
            child: Column(
              children: [
                CustomTextField(controller: _emailController, label: "Email", icon: Icons.email),
                SizedBox(height: 16),
                CustomTextField(controller: _passwordController, label: "Password", icon: Icons.lock, obscureText: true),
                SizedBox(height: 10),
                Row(
                  children: [
                    Checkbox(
                      value: rememberMe,
                      onChanged: (value) {
                        rememberMe = value!;
                      },
                    ),
                    Text("Remember Me"),
                  ],
                ),
                SizedBox(height: 20),
                CustomButton(
                  text: "Login",
                  isLoading: state is LoginLoading,
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      context.read<LoginBloc>().add(
                        LoginSubmitted(email: _emailController.text, password: _passwordController.text),
                      );
                    }
                  },
                ),
                SizedBox(height: 20),
                Text("Or sign up with"),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SocialButton(icon: FontAwesomeIcons.google, color: Colors.red, onPressed: () {}),
                    SizedBox(width: 16),
                    SocialButton(icon: FontAwesomeIcons.apple, color: Colors.black, onPressed: () {}),
                    SizedBox(width: 16),
                    SocialButton(icon: FontAwesomeIcons.facebook, color: Colors.blue, onPressed: () {}),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
