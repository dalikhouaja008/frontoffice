import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_boost/features/auth/domain/entities/grpd_consent.dart';
import 'package:the_boost/features/auth/presentation/bloc/signup/sign_up_bloc.dart';
import 'package:the_boost/features/auth/presentation/widgets/buttons/app_button.dart';
import 'package:the_boost/features/auth/presentation/widgets/textfields/app_text_field.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/utils/input_validators.dart';
import '../pages/auth/auth_page.dart'; // Make sure this import exists

class SignUpForm extends StatefulWidget {
  final Function updateView;

  const SignUpForm({super.key, 
    required this.updateView,
  });

  @override
  // ignore: library_private_types_in_public_api
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _acceptTerms = false;
  bool _acceptMarketing = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    color: AppColors.success,
                    size: 50,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "Account Created Successfully!",
                  style: AppTextStyles.h3,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  "Your account has been created. You can now login with your credentials.",
                  style: AppTextStyles.body2,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                      widget.updateView(); // Switch to login view
                    },
                    child: const Text(
                      "Proceed to Login",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper method to show user-friendly error messages
  String _getUserFriendlyErrorMessage(String error) {
    if (error.contains("Email already in use")) {
      return "This email address is already registered. Please use a different email or login to your existing account.";
    } else if (error.contains("password") || error.contains("Password")) {
      return "Please check your password. It must be at least 8 characters long and include letters and numbers.";
    } else if (error.contains("network") || error.contains("connection")) {
      return "We're having trouble connecting to our servers. Please check your internet connection and try again.";
    } else {
      return "We couldn't create your account. Please check your information and try again.";
    }
  }
  
  // Method to show error dialog with user-friendly message
  void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 50,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "Unable to Create Account",
                  style: AppTextStyles.h3,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  _getUserFriendlyErrorMessage(errorMessage),
                  style: AppTextStyles.body2,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                    },
                    child: const Text(
                      "Try Again",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignUpBloc, SignUpState>(
      listener: (context, state) {
        if (state is SignUpSuccess && mounted) {
          _showSuccessDialog();
        } else if (state is SignUpFailure) {
          _showErrorDialog(state.error);
        }
      },
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.paddingXL),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MediaQuery.of(context).size.width < 768
                    ? SizedBox(height: AppDimensions.paddingL)
                    : SizedBox(height: 0),
                Center(
                  child: Text(
                    "Create Account",
                    style: AppTextStyles.h2,
                  ),
                ),
                SizedBox(height: AppDimensions.paddingXL),
                
                // Name field
                AppTextField(
                  label: "Full Name",
                  prefixIcon: Icons.person_outline,
                  validator: InputValidators.validateName,
                  controller: _nameController,
                ),
                SizedBox(height: AppDimensions.paddingL),
                
                // Email field
                AppTextField(
                  label: "Email",
                  prefixIcon: Icons.email_outlined,
                  validator: InputValidators.validateEmail,
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailController,
                ),
                SizedBox(height: AppDimensions.paddingL),
                
                // Password field
                AppTextField(
                  label: "Password",
                  prefixIcon: Icons.lock_outline,
                  obscureText: obscurePassword,
                  validator: InputValidators.validatePassword,
                  controller: _passwordController,
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                    icon: Icon(
                      obscurePassword ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                  ),
                ),
                SizedBox(height: AppDimensions.paddingL),
                
                // Confirm password field
                AppTextField(
                  label: "Confirm Password",
                  prefixIcon: Icons.lock_outline,
                  obscureText: obscureConfirmPassword,
                  validator: (value) => InputValidators.validateConfirmPassword(
                    value,
                    _passwordController.text,
                  ),
                  controller: _confirmPasswordController,
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        obscureConfirmPassword = !obscureConfirmPassword;
                      });
                    },
                    icon: Icon(
                      obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                  ),
                ),
                SizedBox(height: AppDimensions.paddingL),
                
                // Terms and conditions
                Row(
                  children: [
                    Checkbox(
                      value: _acceptTerms,
                      onChanged: (value) {
                        setState(() {
                          _acceptTerms = value ?? false;
                        });
                      },
                      activeColor: AppColors.primary,
                    ),
                    Expanded(
                      child: Text(
                        "I agree to the Terms of Service and Privacy Policy",
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ),
                  ],
                ),
                
                // Marketing consent
                Row(
                  children: [
                    Checkbox(
                      value: _acceptMarketing,
                      onChanged: (value) {
                        setState(() {
                          _acceptMarketing = value ?? false;
                        });
                      },
                      activeColor: AppColors.primary,
                    ),
                    Expanded(
                      child: Text(
                        "I agree to receive marketing communications",
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ),
                  ],
                ),
                
                // We're no longer showing inline error messages as they're presented in a dialog
                // for better web app UX
                SizedBox(height: AppDimensions.paddingXL),
                
                // Sign up button
                BlocBuilder<SignUpBloc, SignUpState>(
                  builder: (context, state) {
                    return AppButton(
                      text: "Sign Up",
                      onPressed: _handleSignUp,
                      isFullWidth: true,
                      isLoading: state is SignUpLoading,
                    );
                  },
                ),
                SizedBox(height: AppDimensions.paddingL),
                
                // Login link
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account?",
                        style: TextStyle(color: Colors.black54),
                      ),
                      TextButton(
                        onPressed: () {
                          widget.updateView();
                        },
                        child: Text(
                          "Log In",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleSignUp() {
    // Check if already loading
    final currentState = context.read<SignUpBloc>().state;
    if (currentState is SignUpLoading) {
      return;
    }

    if (!_acceptTerms) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.info_outline,
                      color: Colors.orange,
                      size: 50,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Terms Agreement Required",
                    style: AppTextStyles.h3,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Please accept the Terms of Service and Privacy Policy to create your account.",
                    style: AppTextStyles.body2,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(); // Close dialog
                      },
                      child: const Text(
                        "Got It",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      // Créer l'objet GDPRConsent avec la structure que vous avez définie
      final gdprConsent = GDPRConsent(
        acceptedTerms: _acceptTerms,
        acceptedPrivacyPolicy: _acceptTerms,
        acceptedDataProcessing: _acceptTerms,
        acceptedMarketing: _acceptMarketing,
      );
      
      context.read<SignUpBloc>().add(
        SignUpRequested(
          username: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          role: 'user', // Vous pouvez ajouter une sélection de rôle si nécessaire
          publicKey: null, // Peut être ajouté plus tard si nécessaire
          gdprConsent: gdprConsent,
        ),
      );
    }
  }
}