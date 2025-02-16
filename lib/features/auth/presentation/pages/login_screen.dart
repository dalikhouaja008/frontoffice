import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../bloc/login_bloc.dart';
import '../../domain/use_cases/login_use_case.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/error_popup.dart';
import '../widgets/social_button.dart';
import 'home_screen.dart';
import 'sign_up_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  bool _rememberMe = false;
  bool _obscureText = true;
  bool _isLoading = false;

  String get _currentTimestamp => 
      DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now().toUtc());

  void _navigateToSignUp(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => SignUpScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
        transitionDuration: Duration(milliseconds: 500),
      ),
    );
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          'Reset Password',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.blue,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter your email address to receive password reset instructions.',
              style: GoogleFonts.poppins(),
            ),
            SizedBox(height: 20),
            CustomTextField(
              controller: TextEditingController(),
              label: "Email",
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value?.isEmpty ?? true) return "Enter your email";
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                  return "Enter a valid email";
                }
                return null;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement password reset
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Password reset link sent to your email'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Send Reset Link',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

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
                SnackBar(
                  content: Text("Welcome back, ${state.user.email}!"),
                  backgroundColor: Colors.green,
                ),
              );
              Future.delayed(Duration(seconds: 1), () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen(user: state.user)),
                );
              });
            } else if (state is LoginFailure) {
              showDialog(
                context: context,
                builder: (context) => ErrorPopup(message: state.error),
              );
            }
          },
          builder: (context, state) {
            return _buildMainContent(context, state, size, isMobile);
          },
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, LoginState state, Size size, bool isMobile) {
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
  }

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

  Widget _buildWebLayout(BuildContext context, LoginState state) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: _buildWelcomeSection(),
        ),
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            child: Container(
              width: 500,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: _buildLoginForm(context, state),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: Colors.white,
          backgroundImage: AssetImage('assets/logo.png'),
        ),
        SizedBox(height: 20),
        Text(
          "Welcome Back to TheBoost",
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 10),
        Text(
          "Login to access your investment portfolio",
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.white70,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginForm(BuildContext context, LoginState state) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Lottie.asset('assets/animations/auth.json', height: 150),
          SizedBox(height: 20),
          Text(
            "Login to Your Account",
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          _buildLoginFields(context, state),
        ],
      ),
    );
  }

  Widget _buildLoginFields(BuildContext context, LoginState state) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          CustomTextField(
            controller: _emailController,
            label: "Email",
            icon: Icons.email,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value?.isEmpty ?? true) return "Please enter your email";
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                return "Please enter a valid email address";
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
              onPressed: () => setState(() => _obscureText = !_obscureText),
            ),
            validator: (value) => value?.isEmpty ?? true ? "Please enter your password" : null,
          ),
          SizedBox(height: 10),
          _buildRememberForgotRow(),
          SizedBox(height: 20),
          _buildLoginButton(context, state),
          SizedBox(height: 20),
          _buildSocialLogin(),
          SizedBox(height: 20),
          _buildSignUpSection(context),
        ],
      ),
    );
  }

  Widget _buildRememberForgotRow() {
    return Row(
      children: [
        Checkbox(
          value: _rememberMe,
          onChanged: (value) => setState(() => _rememberMe = value!),
          activeColor: Colors.blue,
        ),
        Text(
          "Remember Me",
          style: GoogleFonts.poppins(
            color: Colors.grey[700],
            fontSize: 14,
          ),
        ),
        Spacer(),
        TextButton(
          onPressed: _showForgotPasswordDialog,
          child: Text(
            "Forgot Password?",
            style: GoogleFonts.poppins(
              color: Colors.blue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton(BuildContext context, LoginState state) {
    return CustomButton(
      text: "Login",
      isLoading: state is LoginLoading,
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          context.read<LoginBloc>().add(
            LoginRequested(
              _emailController.text.trim(),
              _passwordController.text.trim(),
             // rememberMe: _rememberMe,
            ),
          );
        }
      },
    );
  }

  Widget _buildSocialLogin() {
    return Column(
      children: [
        Text(
          "Or login with",
          style: GoogleFonts.poppins(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: [
            SocialButton(
              icon: FontAwesomeIcons.google,
              color: Colors.red,
              onPressed: () {
                // TODO: Implement Google login
              },
            ),
            SocialButton(
              icon: FontAwesomeIcons.apple,
              color: Colors.black,
              onPressed: () {
                // TODO: Implement Apple login
              },
            ),
            SocialButton(
              icon: FontAwesomeIcons.facebook,
              color: Colors.blue,
              onPressed: () {
                // TODO: Implement Facebook login
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSignUpSection(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Don't have an account? ",
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            TextButton(
              onPressed: () => _navigateToSignUp(context),
              child: Text(
                "Sign Up",
                style: GoogleFonts.poppins(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Text(
            "By logging in, you agree to our Terms of Service and Privacy Policy",
            style: GoogleFonts.poppins(
              color: Colors.grey[500],
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}