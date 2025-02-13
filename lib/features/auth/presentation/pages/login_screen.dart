import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:the_boost/features/auth/domain/entities/user.dart';
import 'package:the_boost/features/auth/presentation/bloc/login/login_state.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../bloc/login/login_bloc.dart';
import '../../domain/use_cases/login_use_case.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/error_popup.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool rememberMe = false;
  bool _obscureText = true;


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    bool isMobile = size.width < 800;
    String formatErrorMessage(String error) {
      if (error.contains('type \'Null\' is not a subtype of type \'String\'')) {
        return 'Unable to process login information. Please try again.';
      }
      return error.replaceAll('Exception:', '').trim();
    }

    String getDetailedError(String error) {
      if (error.contains('TypeError')) {
        return 'Null value received where string was expected';
      }
      return 'See error message above';
    }

    return Scaffold(
      body: BlocProvider(
        create: (context) => LoginBloc(
          loginUseCase: context.read<LoginUseCase>(),
          secureStorage: context
              .read<SecureStorageService>(), // Ajout du paramètre manquant
        ),
        child: BlocConsumer<LoginBloc, LoginState>(
          listener: (context, state) {
            if (state is LoginSuccess) {
              print('[${DateTime.now().toIso8601String()}] 🎉 Login successful'
                  '\n└─ User: ${state.user.username}'
                  '\n└─ Email: ${state.user.email}'
                  '\n└─ Role: ${state.user.role}');

              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => HomeScreen(user: state.user),
                ),
              );
            } else if (state is LoginFailure) {
              final errorMessage =
                  state.error.toString();
              print('[${DateTime.now().toIso8601String()}] ❌ Login failed'
                  '\n└─ Error: $errorMessage'
                  '\n└─ Details: ${getDetailedError(errorMessage)}');

              showDialog(
                context: context,
                builder: (context) => ErrorPopup(
                  message: formatErrorMessage(errorMessage),
                ),
              );
            } else if (state is LoginLoading) {
              print(
                  '[${DateTime.now().toIso8601String()}] ⏳ Authentication in progress...');
            } else if (state is LoginInitial) {
              print(
                  '[${DateTime.now().toIso8601String()}] 🔄 Login view initialized');
            }
          },
          builder: (context, state) {
            return SafeArea(
              child: Container(
                width: size.width,
                height: size.height,
                decoration: const BoxDecoration(
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
          const SizedBox(height: 30),
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
          child: Center(
            child: Container(
              width: 500,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: _buildLoginForm(context, state),
            ),
          ),
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
        const CircleAvatar(
            radius: 60,
            backgroundColor: Colors.white,
            backgroundImage: AssetImage('assets/logo.png')),
        const SizedBox(height: 20),
        Text(
          "Welcome to TheBoost",
          style: GoogleFonts.poppins(
              fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Lottie.asset('assets/animations/auth.json', height: 150),
         const SizedBox(height: 20),
          Text(
            "Login to TheBoost",
            style:
                GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Form(
            key: _formKey,
            child: Column(
              children: [
                CustomTextField(
                  controller: _emailController,
                  label: "Email",
                  icon: Icons.email,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your email";
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return "Please enter a valid email address";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _passwordController,
                  label: "Password",
                  icon: Icons.lock,
                  obscureText: _obscureText,
                  suffixIcon: IconButton(
                    icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your password";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Checkbox(
                      value: rememberMe,
                      onChanged: (value) {
                        setState(() {
                          rememberMe = value!;
                        });
                      },
                    ),
                    Text("Remember Me"),
                    Spacer(),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        "Forgot Password?",
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                CustomButton(
                  text: "Login",
                  isLoading: state is LoginLoading,
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // 🔹 LOGIN LOGIC HERE
                      context.read<LoginBloc>().add(
                            LoginRequested(
                              _emailController.text.trim(),
                              _passwordController.text.trim(),
                            ),
                          );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ❌ **Show Error Dialog for Login Failure**
  void _showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Login Failed"),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }
}
