import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:the_boost/features/auth/domain/entities/grpd_consent.dart';
import '../bloc/signup/sign_up_bloc.dart';
import '../widgets/buttons/custom_button.dart';
import '../widgets/textfields/custom_text_field.dart';
import '../widgets/buttons/social_button.dart';
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
  bool _obscureConfirmText = true;
  bool _acceptedTerms = false;
  bool _acceptedPrivacyPolicy = false;
  bool _acceptedDataProcessing = false;
  bool _acceptedMarketing = false;

  String get _currentTimestamp => 
      DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now().toUtc());


  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          'Privacy Policy',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.blue,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Last Updated: $_currentTimestamp',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 16),
              _buildPolicySection(
                'Data Collection and Usage',
                '• Personal Information Collection\n'
                '• Account Registration Data\n'
                '• Usage Analytics\n'
                '• Communication Preferences',
              ),
              _buildPolicySection(
                'Your Rights (GDPR Compliance)',
                '• Access your personal data\n'
                '• Request data modification\n'
                '• Request data deletion\n'
                '• Export your data\n'
                '• Withdraw consent',
              ),
              _buildPolicySection(
                'Data Protection',
                '• Encryption standards\n'
                '• Secure storage\n'
                '• Third-party compliance\n'
                '• Regular security audits',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: GoogleFonts.poppins(
                color: Colors.blue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTermsAndConditions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          'Terms and Conditions',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.blue,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Last Updated: $_currentTimestamp',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              _buildPolicySection(
                'Account Terms',
                '• Accurate information provision\n'
                '• Password security\n'
                '• Account responsibility\n'
                '• Age restrictions',
              ),
              _buildPolicySection(
                'Usage Guidelines',
                '• Acceptable use policy\n'
                '• Content restrictions\n'
                '• User conduct\n'
                '• Service limitations',
              ),
              _buildPolicySection(
                'Legal Compliance',
                '• GDPR compliance\n'
                '• Data protection laws\n'
                '• Industry standards\n'
                '• User rights',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: GoogleFonts.poppins(
                color: Colors.blue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicySection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        Text(
          content,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.black54,
            height: 1.5,
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildConsentCheckbox({
    required bool value,
    required ValueChanged<bool?> onChanged,
    required String text,
    required bool isRequired,
    VoidCallback? onTapLink,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(!value),
              child: Text.rich(
                TextSpan(
                  children: [
                    if (isRequired)
                      TextSpan(
                        text: '* ',
                        style: TextStyle(color: Colors.red),
                      ),
                    TextSpan(text: text),
                    if (onTapLink != null)
                      TextSpan(
                        text: ' View',
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()..onTap = onTapLink,
                      ),
                  ],
                ),
                style: GoogleFonts.poppins(fontSize: 14),
              ),
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
      body: SafeArea(
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
                  ? _buildMobileLayout()
                  : _buildWebLayout(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildWelcomeSection(),
          SizedBox(height: 30),
          _buildSignUpForm(),
        ],
      ),
    );
  }

  Widget _buildWebLayout() {
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
              child: _buildSignUpForm(),
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
          "Join TheBoost Today",
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 10),
        Text(
          "Start your journey in land investment with us",
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.white70,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSignUpForm() {
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
            "Create Your Account",
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          Form(
            key: _formKey,
            child: Column(
              children: [
                _buildFormFields(),
                SizedBox(height: 30),
                _buildGDPRSection(),
                SizedBox(height: 20),
                _buildSignUpButton(),
                SizedBox(height: 20),
                _buildSocialSection(),
                SizedBox(height: 20),
                _buildLoginLink(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
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
        keyboardType: TextInputType.emailAddress, // This will now work
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
            onPressed: () => setState(() => _obscureText = !_obscureText),
          ),
          validator: (value) => value!.length < 6 ? "Password too short" : null,
        ),
        SizedBox(height: 16),
        CustomTextField(
          controller: _confirmPasswordController,
          label: "Confirm Password",
          icon: Icons.lock_outline,
          obscureText: _obscureConfirmText,
          suffixIcon: IconButton(
            icon: Icon(_obscureConfirmText ? Icons.visibility : Icons.visibility_off),
            onPressed: () => setState(() => _obscureConfirmText = !_obscureConfirmText),
          ),
          validator: (value) {
            if (value != _passwordController.text) {
              return "Passwords do not match";
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildGDPRSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Data Protection and Privacy',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        SizedBox(height: 10),
        _buildConsentCheckbox(
          value: _acceptedTerms,
          onChanged: (value) => setState(() => _acceptedTerms = value!),
          text: 'I accept the Terms and Conditions',
          isRequired: true,
          onTapLink: _showTermsAndConditions,
        ),
        _buildConsentCheckbox(
          value: _acceptedPrivacyPolicy,
          onChanged: (value) => setState(() => _acceptedPrivacyPolicy = value!),
          text: 'I accept the Privacy Policy',
          isRequired: true,
          onTapLink: _showPrivacyPolicy,
        ),
        _buildConsentCheckbox(
          value: _acceptedDataProcessing,
          onChanged: (value) => setState(() => _acceptedDataProcessing = value!),
          text: 'I consent to the processing of my personal data as described in the Privacy Policy',
          isRequired: true,
        ),
        _buildConsentCheckbox(
          value: _acceptedMarketing,
          onChanged: (value) => setState(() => _acceptedMarketing = value!),
          text: 'I would like to receive marketing communications (optional)',
          isRequired: false,
        ),
        SizedBox(height: 10),
        Text(
          '* Required fields',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpButton() {
    return BlocConsumer<SignUpBloc, SignUpState>(
      listener: (context, state) {
        if (state is SignUpFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              action: SnackBarAction(
                label: 'Dismiss',
                textColor: Colors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
            ),
          );
        } else if (state is SignUpSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    "Account created successfully!",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.all(16),
              duration: Duration(seconds: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
          
          // Navigate to login page after short delay
          Future.delayed(Duration(seconds: 2), () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => LoginScreen(),
              ),
              (route) => false, // This removes all previous routes
            );
          });
        }
      },
      builder: (context, state) {
        return Column(
          children: [
            CustomButton(
              text: "Sign Up",
              isLoading: state is SignUpLoading,
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  if (!_acceptedTerms || !_acceptedPrivacyPolicy || !_acceptedDataProcessing) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Icon(Icons.warning, color: Colors.white),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Please accept the mandatory terms and conditions',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                        margin: EdgeInsets.all(16),
                        duration: Duration(seconds: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        action: SnackBarAction(
                          label: 'OK',
                          textColor: Colors.white,
                          onPressed: () {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          },
                        ),
                      ),
                    );
                    return;
                  }

                  final gdprConsent = GDPRConsent(
                    acceptedTerms: _acceptedTerms,
                    acceptedPrivacyPolicy: _acceptedPrivacyPolicy,
                    acceptedDataProcessing: _acceptedDataProcessing,
                    acceptedMarketing: _acceptedMarketing,
                    consentTimestamp: DateTime.now().toUtc(),
                  );

                  context.read<SignUpBloc>().add(
                    SignUpRequested(
                      username: _usernameController.text.trim(),
                      email: _emailController.text.trim(),
                      password: _passwordController.text.trim(),
                      role: "user",
                      gdprConsent: gdprConsent,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildSocialSection() {
    return Column(
      children: [
        Text(
          "Or sign up with",
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
              },
            ),
            SocialButton(
              icon: FontAwesomeIcons.apple,
              color: Colors.black,
              onPressed: () {
              },
            ),
            SocialButton(
              icon: FontAwesomeIcons.facebook,
              color: Colors.blue,
              onPressed: () {
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoginLink() {
  return Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Already have an account? ",
            style: GoogleFonts.poppins(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginScreen(),
                ),
                (route) => false,
              );
            },
            child: Text(
              "Login",
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
          "By signing up, you agree to our Terms of Service and Privacy Policy",
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
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
