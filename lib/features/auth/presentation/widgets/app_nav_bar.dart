// lib/features/auth/presentation/widgets/app_nav_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_boost/core/constants/colors.dart';
import 'package:the_boost/core/constants/dimensions.dart';
import 'package:the_boost/core/utils/responsive_helper.dart';
import 'package:the_boost/features/auth/presentation/widgets/buttons/app_button.dart';
import 'package:the_boost/features/auth/domain/entities/user.dart';
import 'package:the_boost/features/auth/presentation/bloc/login/login_bloc.dart';
import 'package:the_boost/features/auth/presentation/bloc/login/login_state.dart';
import 'package:the_boost/features/auth/presentation/bloc/routes.dart';

class AppNavBar extends StatelessWidget {
  final VoidCallback? onLoginPressed;
  final VoidCallback? onSignUpPressed;
  final String? currentRoute;

  const AppNavBar({
    super.key,
    this.onLoginPressed,
    this.onSignUpPressed,
    this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    
    print('[2025-03-09 10:05:23] AppNavBar: 🔄 Building navbar'
          '\n└─ Current route: $currentRoute');
    
    // Use BlocBuilder to check authentication state
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        // Debug print to track state changes in the navbar
        print('[2025-03-09 10:05:23] AppNavBar: 🔎 Current auth state: ${state.runtimeType}'
              '\n└─ Is authenticated: ${state is LoginSuccess}');
        
        // The user is authenticated if the state is LoginSuccess
        final isAuthenticated = state is LoginSuccess;
        // Get the user if available
        final user = isAuthenticated ? state.user : null;
        
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? AppDimensions.paddingL : AppDimensions.paddingXXL,
            vertical: AppDimensions.paddingM,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: isMobile
              ? _buildMobileNavBar(context, isAuthenticated, user)
              : _buildDesktopNavBar(context, isAuthenticated, user),
        );
      },
    );
  }

  Widget _buildDesktopNavBar(BuildContext context, bool isAuthenticated, User? user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildLogo(),
        // Use Flexible with a FittedBox for the menu items
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Wrap(
                  spacing: AppDimensions.paddingM,
                  children: [
                    _NavLink('Home', route: '/', currentRoute: currentRoute),
                    _NavLink('Features', route: '/features', currentRoute: currentRoute),
                    _NavLink('How It Works', route: '/how-it-works', currentRoute: currentRoute),
                    _NavLink('Invest', route: '/invest', currentRoute: currentRoute),
                    _NavLink('Learn More', route: '/learn-more', currentRoute: currentRoute),
                  ],
                ),
                const SizedBox(width: AppDimensions.paddingM),
                
                if (isAuthenticated) 
                  _buildUserMenu(context, user)
                else 
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        onPressed: onLoginPressed ?? () {
                          Navigator.pushNamed(context, AppRoutes.auth);
                        },
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.paddingS),
                      AppButton(
                        text: 'Get Started',
                        onPressed: onSignUpPressed ?? () {
                          Navigator.pushNamed(context, AppRoutes.auth);
                        },
                        type: ButtonType.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.paddingL,
                          vertical: AppDimensions.paddingS,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileNavBar(BuildContext context, bool isAuthenticated, User? user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildLogo(),
        Row(
          children: [
            if (isAuthenticated)
              IconButton(
                icon: const Icon(Icons.dashboard),
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.dashboard);
                },
              ),
              
            if (isAuthenticated)
              _buildUserMenuMobile(context, user)
            else
              TextButton(
                onPressed: onLoginPressed ?? () {
                  Navigator.pushNamed(context, AppRoutes.auth);
                },
                child: const Text(
                  'Login',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLogo() {
    return InkWell(
      onTap: () {
        // Navigate to home
      },
      child: Row(
        children: [
          const Icon(Icons.landscape, color: AppColors.primary, size: 32),
          const SizedBox(width: 8),
          Text(
            'TheBoost',
            style: GoogleFonts.montserrat(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserMenu(BuildContext context, User? user) {
    final displayName = user?.username.split(' ')[0] ?? 'User';
    final firstLetter = user?.username.isNotEmpty == true ? user!.username[0].toUpperCase() : 'U';
    
    return PopupMenuButton<String>(
      offset: const Offset(0, 40),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingM,
          vertical: AppDimensions.paddingS,
        ),
        decoration: BoxDecoration(
          color: AppColors.backgroundGreen,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primary,
              radius: 16,
              child: Text(
                firstLetter,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.paddingS),
            Text(
              displayName,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: AppDimensions.paddingS),
            const Icon(
              Icons.arrow_drop_down,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'dashboard',
          child: Row(
            children: [
              Icon(Icons.dashboard, color: Colors.black54),
              SizedBox(width: AppDimensions.paddingM),
              Text('Dashboard'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'profile',
          child: Row(
            children: [
              Icon(Icons.person, color: Colors.black54),
              SizedBox(width: AppDimensions.paddingM),
              Text('My Profile'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'investments',
          child: Row(
            children: [
              Icon(Icons.token, color: Colors.black54),
              SizedBox(width: AppDimensions.paddingM),
              Text('My Investments'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'settings',
          child: Row(
            children: [
              Icon(Icons.settings, color: Colors.black54),
              SizedBox(width: AppDimensions.paddingM),
              Text('Settings'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, color: Colors.red),
              SizedBox(width: AppDimensions.paddingM),
              Text('Logout', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        switch (value) {
          case 'dashboard':
            Navigator.pushNamed(context, AppRoutes.dashboard);
            break;
          case 'profile':
            // Navigate to profile page
            break;
          case 'investments':
            // Navigate to investments page
            Navigator.pushNamed(context, AppRoutes.invest);
            break;
          case 'settings':
            // Navigate to settings page
            break;
          case 'logout':
            // Send logout event to the bloc
            context.read<LoginBloc>().add(LogoutRequested());
            Navigator.pushReplacementNamed(context, AppRoutes.home);
            break;
        }
      },
    );
  }

  Widget _buildUserMenuMobile(BuildContext context, User? user) {
    final firstLetter = user?.username.isNotEmpty == true ? user!.username[0].toUpperCase() : 'U';
    
    return IconButton(
      icon: CircleAvatar(
        backgroundColor: AppColors.primary,
        radius: 16,
        child: Text(
          firstLetter,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          builder: (context) => Container(
            padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingL),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // User info header
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingL),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.primary,
                        radius: 24,
                        child: Text(
                          firstLetter,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.paddingL),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.username ?? 'User',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              user?.email ?? '',
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                // Menu options
                ListTile(
                  leading: const Icon(Icons.dashboard, color: AppColors.primary),
                  title: const Text('Dashboard'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.dashboard);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.person, color: AppColors.primary),
                  title: const Text('My Profile'),
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to profile page
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.token, color: AppColors.primary),
                  title: const Text('My Investments'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.invest);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings, color: AppColors.primary),
                  title: const Text('Settings'),
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to settings page
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('Logout', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    // Send logout event to the bloc
                    context.read<LoginBloc>().add(LogoutRequested());
                    Navigator.pushReplacementNamed(context, AppRoutes.home);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NavLink extends StatelessWidget {
  final String title;
  final String route;
  final String? currentRoute;
  
  _NavLink(this.title, {required this.route, this.currentRoute});
  
  @override
  Widget build(BuildContext context) {
    final bool isActive = currentRoute == route;
    
    return TextButton(
      onPressed: () {
        if (!isActive) {
          Navigator.of(context).pushNamed(route);
        }
      },
      child: Text(
        title,
        style: TextStyle(
          color: isActive ? AppColors.primary : AppColors.textPrimary,
          fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
        ),
      ),
    );
  }
}