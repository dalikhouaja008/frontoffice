// lib/features/auth/presentation/pages/auth/auth_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_boost/core/constants/colors.dart';
import 'package:the_boost/core/constants/dimensions.dart';
import 'package:the_boost/core/utils/responsive_helper.dart';
import 'package:the_boost/features/auth/presentation/bloc/login/login_bloc.dart';
import 'package:the_boost/features/auth/presentation/bloc/login/login_state.dart';
import 'package:the_boost/features/auth/presentation/bloc/signup/sign_up_bloc.dart';
import 'package:the_boost/features/auth/presentation/widgets/app_nav_bar.dart';
import 'package:the_boost/features/auth/presentation/widgets/login_form.dart';
import 'package:the_boost/features/auth/presentation/widgets/signup_form.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with SingleTickerProviderStateMixin {
  bool isLogin = true;
  late AnimationController _animationController;
  late Animation<double> _animationTextRotate;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _animationTextRotate = Tween<double>(
      begin: 0,
      end: 90,
    ).animate(_animationController);
    
    print('[2025-03-09 12:00:02] AuthPage: 🔄 Initializing'
          '\n└─ User: raednas');
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void updateView() {
    setState(() {
      isLogin = !isLogin;
    });
    isLogin ? _animationController.reverse() : _animationController.forward();
    
    print('[2025-03-09 12:00:02] AuthPage: 🔄 Switching view'
          '\n└─ User: raednas'
          '\n└─ Current view: ${isLogin ? 'Login' : 'Signup'}');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = ResponsiveHelper.isMobile(context);
    
    // Use BlocBuilder to ensure the page rebuilds when auth state changes
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, loginState) {
        print('[2025-03-09 12:00:02] AuthPage: 🔄 Building with state: ${loginState.runtimeType}');
        
        // Redirect to dashboard if already logged in
        if (loginState is LoginSuccess) {
          print('[2025-03-09 12:00:02] AuthPage: 🔄 User already logged in, redirecting to dashboard');
          
          // Delay navigation to allow build to complete
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          });
        }
        
        return Scaffold(
          key: const ValueKey('AuthPage'),
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(70),
            child: AppNavBar(
              currentRoute: '/auth',
            ),
          ),
          endDrawer: isMobile ? _buildDrawer(context) : null,
          body: SafeArea(
            child: Container(
              width: size.width,
              height: size.height,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage("assets/images/auth_background.jpg"),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.5),
                    BlendMode.darken,
                  ),
                ),
              ),
              child: Center(
                child: Container(
                  width: isMobile ? size.width * 0.9 : size.width * 0.8,
                  height: isMobile ? null : size.height * 0.8,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusXXL),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 5,
                        blurRadius: 15,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: isMobile
                      ? SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildLogo(),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 500),
                                child: isLogin
                                    ? LoginForm(
                                        updateView: updateView,
                                      )
                                    : BlocProvider.value(
                                        value: context.read<SignUpBloc>(),
                                        child: SignUpForm(
                                          updateView: updateView,
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(32),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(AppDimensions.radiusXXL),
                                    bottomLeft: Radius.circular(AppDimensions.radiusXXL),
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildLogo(isWhite: true),
                                    const SizedBox(height: 30),
                                    SizedBox(
                                      width: 280,
                                      child: AnimatedBuilder(
                                        animation: _animationController,
                                        builder: (context, child) {
                                          return Transform(
                                            alignment: Alignment.center,
                                            transform: Matrix4.rotationY(
                                                _animationTextRotate.value * (3.1415927 / 180)),
                                            child: Text(
                                              isLogin
                                                  ? "Welcome back to TheBoost, where your land investment journey continues."
                                                  : "Join TheBoost and start investing in tokenized land assets today.",
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.w300,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 50),
                                    _buildIllustration(),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 500),
                                child: isLogin
                                    ? LoginForm(
                                        updateView: updateView,
                                      )
                                    : BlocProvider.value(
                                        value: context.read<SignUpBloc>(),
                                        child: SignUpForm(
                                          updateView: updateView,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppColors.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLogo(isWhite: true, isSmall: true),
                const SizedBox(height: 10),
                const Text(
                  'Land Investment via Tokenization',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/');
              print('[2025-03-09 12:00:02] AuthPage: 🏠 Navigating to Home'
                    '\n└─ User: raednas');
            },
          ),
          ListTile(
            leading: const Icon(Icons.auto_awesome),
            title: const Text('Features'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/features');
              print('[2025-03-09 12:00:02] AuthPage: 🚀 Navigating to Features'
                    '\n└─ User: raednas');
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('How It Works'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/how-it-works');
              print('[2025-03-09 12:00:02] AuthPage: ❓ Navigating to How It Works'
                    '\n└─ User: raednas');
            },
          ),
          ListTile(
            leading: const Icon(Icons.attach_money),
            title: const Text('Invest'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/invest');
              print('[2025-03-09 12:00:02] AuthPage: 💰 Navigating to Invest'
                    '\n└─ User: raednas');
            },
          ),
          ListTile(
            leading: const Icon(Icons.school),
            title: const Text('Learn More'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/learn-more');
              print('[2025-03-09 12:00:02] AuthPage: 📚 Navigating to Learn More'
                    '\n└─ User: raednas');
            },
          ),
          const Divider(),
          if (isLogin)
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('Create Account'),
              onTap: () {
                Navigator.pop(context);
                updateView();
                print('[2025-03-09 12:00:02] AuthPage: 👤 Switching to Sign Up'
                      '\n└─ User: raednas');
              },
            )
          else
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Login'),
              onTap: () {
                Navigator.pop(context);
                updateView();
                print('[2025-03-09 12:00:02] AuthPage: 🔑 Switching to Login'
                      '\n└─ User: raednas');
              },
            ),
        ],
      ),
    );
  }

  Widget _buildLogo({bool isWhite = false, bool isSmall = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.landscape,
          color: isWhite ? Colors.white : AppColors.primary,
          size: isSmall ? 30 : 40,
        ),
        const SizedBox(width: 10),
        Text(
          'TheBoost',
          style: TextStyle(
            fontSize: isSmall ? 24 : 32,
            fontWeight: FontWeight.bold,
            color: isWhite ? Colors.white : AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildIllustration() {
    return SizedBox(
      height: 250,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 200,
            width: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationY(
                    _animationTextRotate.value * (3.1415927 / 180)),
                child: Icon(
                  isLogin ? Icons.account_balance : Icons.token,
                  color: Colors.white,
                  size: 100,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}