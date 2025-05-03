import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:the_boost/core/di/dependency_injection.dart';
import 'package:the_boost/features/auth/data/repositories/two_factor_auth_repository.dart';
import 'package:the_boost/features/auth/presentation/bloc/2FA/two_factor_auth_bloc.dart';
import 'package:the_boost/features/auth/presentation/bloc/2FA/two_factor_auth_state.dart';
import 'package:the_boost/features/auth/presentation/bloc/login/login_bloc.dart';
import 'package:the_boost/features/auth/presentation/bloc/login/login_state.dart';
import 'package:the_boost/features/auth/presentation/pages/sign_up_screen.dart';
import 'package:the_boost/features/auth/presentation/widgets/dialogs/otp_dialog.dart';
import '../widgets/buttons/custom_button.dart';
import '../widgets/textfields/custom_text_field.dart';
import '../widgets/dialogs/error_popup.dart';
import '../bloc/routes.dart';
import 'dart:developer' as developer;

class LoginScreen extends StatefulWidget {
  final Function? updateView;

  const LoginScreen({super.key, this.updateView});

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
  void initState() {
    super.initState();
    developer.log('LoginScreen: 🎬 Initializing login screen');
  }

  void _showErrorDialog(BuildContext context, String error) {
    final formattedError = _formatErrorMessage(error);
    developer.log('LoginScreen: ❌ Showing error dialog'
        '\n└─ Error: $formattedError');

    showDialog(
      context: context,
      builder: (context) => ErrorPopup(message: formattedError),
    );
  }

  void _handleLoginStateChanges(BuildContext context, LoginState state) {
    print('LoginScreen: 📣 Login state changed: ${state.runtimeType}');

    if (state is LoginSuccess) {
      print('LoginScreen: ✅ Login successful'
          '\n└─ User: ${state.user.username}'
          '\n└─ Role: ${state.user.role}');

      // IMPORTANT: Plutôt que de naviguer immédiatement,
      // attendez que l'état ait eu le temps de se propager
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Force une mise à jour de l'UI pour s'assurer que tous les widgets reçoivent l'état
        final bloc = context.read<LoginBloc>();

        // Cette ligne force un "rebuild" en réémettant le même état
        bloc.emit(LoginSuccess(user: state.user));

        // Puis naviguez après un court délai
        Future.delayed(Duration(milliseconds: 300), () {
          Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
        });
      });
    } else if (state is LoginRequires2FA) {
      print('LoginScreen: 🔐 2FA required'
          '\n└─ Email: ${state.user.email}');

      _show2FADialog(context, state);
    } else if (state is LoginFailure) {
      print('LoginScreen: ❌ Login failed'
          '\n└─ Error: ${state.error}');

      _showErrorDialog(context, state.error);
    } else if (state is LoginLoading) {
      print('LoginScreen: ⏳ Authentication in progress...');
    } else if (state is LoginInitial) {
      print('LoginScreen: 🔄 Login view initialized');
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    bool isMobile = size.width < 800;
    developer.log('LoginScreen: 🔄 Building login screen (mobile: $isMobile)');

    return BlocConsumer<LoginBloc, LoginState>(
      listenWhen: (previous, current) {
        developer.log(
            'LoginScreen: 🔍 State change: ${previous.runtimeType} -> ${current.runtimeType}');
        return previous.runtimeType != current.runtimeType;
      },
      listener: _handleLoginStateChanges,
      builder: (context, state) {
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
                      ? _buildMobileLayout(context, state)
                      : _buildWebLayout(context, state),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _show2FADialog(BuildContext context, LoginRequires2FA state) {
    developer.log('LoginScreen: 🔐 Showing 2FA dialog'
        '\n└─ User: ${state.user.username}'
        '\n└─ Email: ${state.user.email}');

    // Utilisez getIt pour obtenir le repository
    final twoFactorAuthRepository = getIt<TwoFactorAuthRepository>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BlocProvider<TwoFactorAuthBloc>(
        // Utilisez getIt ou créez une nouvelle instance avec le repository obtenu
        create: (context) => TwoFactorAuthBloc(
          repository: twoFactorAuthRepository,
        ),
        child: BlocListener<TwoFactorAuthBloc, TwoFactorAuthState>(
          listener: (context, twoFactorState) {
            if (twoFactorState is TwoFactorAuthLoginSuccess) {
              developer.log('LoginScreen: ✅ 2FA verification successful'
                  '\n└─ User: ${state.user.username}'
                  '\n└─ Email: ${twoFactorState.user.email}');

              Navigator.of(dialogContext).pop();

              // Important: Push replacement avec nommé
              Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
            } else if (twoFactorState is TwoFactorAuthError) {
              developer.log('LoginScreen: ❌ 2FA verification failed'
                  '\n└─ User: ${state.user.username}'
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

  String _formatErrorMessage(String error) {
    if (error.contains('type \'Null\' is not a subtype of type \'String\'')) {
      return 'Unable to process login information. Please try again.';
    }
    return error.replaceAll('Exception:', '').trim();
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
                const SizedBox(height: 10),
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
                    const Text("Remember Me"),
                    const Spacer(),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        "Forgot Password?",
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                CustomButton(
                  text: "Login",
                  isLoading: state is LoginLoading,
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      developer.log('LoginScreen: 🚀 Login button pressed'
                          '\n└─ Email: ${_emailController.text.trim()}');

                      context.read<LoginBloc>().add(
                            LoginRequested(
                              _emailController.text.trim(),
                              _passwordController.text.trim(),
                            ),
                          );
                    }
                  },
                ),
                const SizedBox(height: 20),
                // Nouvelle section pour le lien d'inscription
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(color: Colors.grey),
                    ),
                    TextButton(
                      onPressed: () {
                        developer.log('LoginScreen: 📝 Navigate to signup');

                        // Si widget.updateView est fourni, utilisez-le
                        if (widget.updateView != null) {
                          widget.updateView!();
                        } else {
                          // Sinon, utilisez la navigation standard
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => SignUpScreen(),
                            ),
                          );
                        }
                      },
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
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
