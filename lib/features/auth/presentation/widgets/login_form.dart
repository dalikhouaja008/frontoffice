// lib/features/auth/presentation/widgets/login_form.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
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
import 'dart:developer' as developer;

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
  void initState() {
    super.initState();
    developer.log('LoginForm: 🎬 Initializing login form');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showErrorDialog(BuildContext context, String error) {
    final formattedError = _formatErrorMessage(error);
    developer.log('LoginForm: ❌ Showing error dialog'
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
    developer.log('LoginForm: 🔐 Showing 2FA dialog'
        '\n└─ User: ${state.user.username}'
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
              developer.log('LoginForm: ✅ 2FA verification successful'
                  '\n└─ Email: ${twoFactorState.user.email}');

              Navigator.of(dialogContext).pop();

              // Use the route constant for navigation and ensure we use pushReplacementNamed
              Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
            } else if (twoFactorState is TwoFactorAuthError) {
              developer.log('LoginForm: ❌ 2FA verification failed'
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

  void _onLoginSuccess(LoginSuccess state) {
    developer.log('LoginForm: ✅ Login successful'
        '\n└─ User: ${state.user.username}'
        '\n└─ Email: ${state.user.email}'
        '\n└─ Session ID: ${state.sessionId}');

    // Naviguer vers le dashboard
    Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    // Debug print to track form builds
    developer.log('LoginForm: 🔄 Building login form');
    
    return BlocListener<LoginBloc, LoginState>(
      listenWhen: (previous, current) {
        developer.log('LoginForm: 🔍 State change: ${previous.runtimeType} -> ${current.runtimeType}');
        return previous.runtimeType != current.runtimeType;
      },
      listener: (context, state) {
        // Debug print to track state changes
        developer.log('LoginForm: 📣 Login state changed: ${state.runtimeType}');
        
        if (state is LoginSuccess) {
          developer.log('LoginForm: ✅ Login successful'
              '\n└─ User: ${state.user.username}'
              '\n└─ Email: ${state.user.email}');

          _onLoginSuccess(state);
        } else if (state is LoginRequires2FA) {
          developer.log('LoginForm: 🔐 2FA required'
              '\n└─ Email: ${state.user.email}');

          _show2FADialog(context, state);
        } else if (state is LoginFailure) {
          developer.log('LoginForm: ❌ Login failed'
              '\n└─ Error: ${state.error}');

          _showErrorDialog(context, state.error);
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingXL),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MediaQuery.of(context).size.width < 768
                    ? const SizedBox(height: AppDimensions.paddingL)
                    : const SizedBox(height: 0),
                Center(
                  child: Text(
                    "Log In",
                    style: AppTextStyles.h2,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingXL),

                // Email field
                AppTextField(
                  label: "Email",
                  prefixIcon: Icons.email_outlined,
                  validator: InputValidators.validateEmail,
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailController,
                ),
                const SizedBox(height: AppDimensions.paddingL),

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
                const SizedBox(height: AppDimensions.paddingS),

                // Forgot password link
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/forgot-password');
                    },
                    child: const Text(
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
                  buildWhen: (previous, current) {
                    return current is LoginFailure || previous is LoginFailure;
                  },
                  builder: (context, state) {
                    if (state is LoginFailure) {
                      return Container(
                        padding: const EdgeInsets.all(AppDimensions.paddingM),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusS),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red),
                            const SizedBox(width: AppDimensions.paddingS),
                            Expanded(
                              child: Text(
                                state.error,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return SizedBox(height: AppDimensions.paddingS);
                  },
                ),
                const SizedBox(height: AppDimensions.paddingM),

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
                  buildWhen: (previous, current) {
                    return current is LoginLoading || previous is LoginLoading;
                  },
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
    developer.log('LoginForm: 🚀 Login button pressed'
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