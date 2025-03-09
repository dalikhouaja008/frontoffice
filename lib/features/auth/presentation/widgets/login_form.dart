// lib/features/auth/presentation/widgets/login_form.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_boost/core/di/dependency_injection.dart';
import 'package:the_boost/features/auth/data/repositories/two_factor_auth_repository.dart';
import 'package:the_boost/features/auth/presentation/bloc/2FA/two_factor_auth_bloc.dart';
import 'package:the_boost/features/auth/presentation/bloc/2FA/two_factor_auth_state.dart';
import 'package:the_boost/features/auth/presentation/bloc/login/login_bloc.dart';
import 'package:the_boost/features/auth/presentation/bloc/login/login_state.dart';
import 'package:the_boost/features/auth/presentation/bloc/routes.dart';
import 'package:the_boost/features/auth/presentation/widgets/buttons/app_button.dart';
import 'package:the_boost/features/auth/presentation/widgets/dialogs/error_popup.dart';
import 'package:the_boost/features/auth/presentation/widgets/dialogs/otp_dialog.dart';
import 'package:the_boost/features/auth/presentation/widgets/textfields/app_text_field.dart';
import 'package:the_boost/core/constants/colors.dart';
import 'package:the_boost/core/constants/dimensions.dart';
import 'package:the_boost/core/constants/text_styles.dart';
import 'package:the_boost/core/utils/input_validators.dart';

class LoginForm extends StatefulWidget {
  final Function updateView;

  const LoginForm({
    Key? key,
    required this.updateView,
  }) : super(key: key);

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool obscurePassword = true;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showErrorDialog(BuildContext context, String error) {
    final formattedError = _formatErrorMessage(error);
    print('[2025-03-02 15:58:06] LoginForm: ❌ Showing error dialog'
        '\n└─ User: raednas'
        '\n└─ Error: $formattedError');

    showDialog(
      context: context,
      builder: (context) => ErrorPopup(message: formattedError),
    );
  }

  String _formatErrorMessage(String error) {
    if (error.contains('type \'Null\' is not a subtype of type \'String\'')) {
      return 'Unable to process login information. Please try again.';
    }
    return error.replaceAll('Exception:', '').trim();
  }

  void _show2FADialog(BuildContext context, LoginRequires2FA state) {
    print('[2025-03-02 16:20:01] LoginForm: 🔐 Showing 2FA dialog'
        '\n└─ User: raednas'
        '\n└─ Email: ${state.user.email}');

    // Get the repository from getIt
    final twoFactorAuthRepository = getIt<TwoFactorAuthRepository>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BlocProvider<TwoFactorAuthBloc>(
        create: (context) => TwoFactorAuthBloc(
          repository: twoFactorAuthRepository,
        ),
        child: BlocListener<TwoFactorAuthBloc, TwoFactorAuthState>(
          listener: (context, twoFactorState) {
            if (twoFactorState is TwoFactorAuthLoginSuccess) {
              print(
                  '[2025-03-02 16:20:01] LoginForm: ✅ 2FA verification successful'
                  '\n└─ Email: ${twoFactorState.user.email}');

              Navigator.of(dialogContext).pop();

              // Use the route constant for navigation and add a small delay to ensure the
              // login state is properly updated before navigation
              Future.delayed(Duration(milliseconds: 100), () {
                Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);

                print(
                    '[2025-03-02 16:20:01] LoginForm: 🔄 Navigating to dashboard'
                    '\n└─ User: raednas'
                    '\n└─ Email: ${twoFactorState.user.email}');
              });
            } else if (twoFactorState is TwoFactorAuthError) {
              print('[2025-03-02 16:20:01] LoginForm: ❌ 2FA verification failed'
                  '\n└─ User: raednas'
                  '\n└─ Error: ${twoFactorState.message}');

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(twoFactorState.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: OtpDialog(
            tempToken: state.tempToken,
            email: state.user.email,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Debug print to track form builds
    print('[2025-03-02 15:58:06] LoginForm: 🔄 Building login form');
    
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        // Debug print to track state changes
        print('[2025-03-02 15:58:06] LoginForm: 📣 Login state changed: ${state.runtimeType}');
        
        if (state is LoginSuccess) {
          print('[2025-03-02 16:20:01] LoginForm: ✅ Login successful'
              '\n└─ User: raednas'
              '\n└─ Email: ${state.user.email}');

          // Use a small delay to ensure state is properly propagated
          Future.delayed(Duration(milliseconds: 100), () {
            Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
            
            print('[2025-03-02 16:20:01] LoginForm: 🔄 Navigating to dashboard'
                '\n└─ User: raednas'
                '\n└─ Email: ${state.user.email}');
          });
        } else if (state is LoginRequires2FA) {
          print('[2025-03-02 16:20:01] LoginForm: 🔐 2FA required'
              '\n└─ User: raednas'
              '\n└─ Email: ${state.user.email}');

          _show2FADialog(context, state);
        } else if (state is LoginFailure) {
          print('[2025-03-02 16:20:01] LoginForm: ❌ Login failed'
              '\n└─ User: raednas'
              '\n└─ Error: ${state.error}');

          _showErrorDialog(context, state.error);
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
                    : const SizedBox(height: 0),
                Center(
                  child: Text(
                    "Log In",
                    style: AppTextStyles.h2,
                  ),
                ),
                SizedBox(height: AppDimensions.paddingXL),

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
                SizedBox(height: AppDimensions.paddingS),

                // Forgot password link
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/forgot-password');
                    },
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                // Error message
                BlocBuilder<LoginBloc, LoginState>(
                  builder: (context, state) {
                    if (state is LoginFailure) {
                      return Container(
                        padding: EdgeInsets.all(AppDimensions.paddingM),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusS),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red),
                            SizedBox(width: AppDimensions.paddingS),
                            Expanded(
                              child: Text(
                                state.error,
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return SizedBox(height: AppDimensions.paddingS);
                  },
                ),
                SizedBox(height: AppDimensions.paddingL),

                // Remember me checkbox
                Row(
                  children: [
                    Transform.scale(
                      scale: 0.8,
                      child: Checkbox(
                        value: false,
                        onChanged: (value) {},
                        activeColor: AppColors.primary,
                      ),
                    ),
                    const Text(
                      "Remember Me",
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.paddingM),

                // Login button
                BlocBuilder<LoginBloc, LoginState>(
                  builder: (context, state) {
                    return AppButton(
                      text: "Log In",
                      onPressed: _handleLogin,
                      isFullWidth: true,
                      isLoading: state is LoginLoading,
                    );
                  },
                ),
                const SizedBox(height: AppDimensions.paddingL),

                // Sign up link
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account?",
                        style: TextStyle(color: Colors.black54),
                      ),
                      TextButton(
                        onPressed: () {
                          widget.updateView();
                        },
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppDimensions.paddingXL),

                // Social login
                Center(
                  child: Text(
                    "Or log in with",
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
                SizedBox(height: AppDimensions.paddingL),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _SocialButton(icon: Icons.g_mobiledata, onTap: () {}),
                    SizedBox(width: AppDimensions.paddingL),
                    _SocialButton(icon: Icons.facebook, onTap: () {}),
                    SizedBox(width: AppDimensions.paddingL),
                    _SocialButton(icon: Icons.apple, onTap: () {}),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleLogin() {
    print('[2025-03-02 15:58:06] LoginForm: 🚀 Login button pressed'
        '\n└─ User: raednas'
        '\n└─ Email: ${_emailController.text.trim()}');

    // Don't proceed if already authenticating
    final state = context.read<LoginBloc>().state;
    if (state is LoginLoading) {
      return;
    }

    if (_formKey.currentState!.validate()) {
      // Dispatching the login event with the provided credentials
      context.read<LoginBloc>().add(
            LoginRequested(
              _emailController.text.trim(),
              _passwordController.text,
            ),
          );
    }
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _SocialButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300),
          color: Colors.white,
        ),
        child: Icon(
          icon,
          size: 30,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }
}