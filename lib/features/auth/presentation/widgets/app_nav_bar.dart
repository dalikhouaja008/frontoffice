import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:the_boost/core/constants/colors.dart';
import 'package:the_boost/core/constants/dimensions.dart';
import 'package:the_boost/core/utils/responsive_helper.dart';
import 'package:the_boost/features/auth/presentation/widgets/buttons/app_button.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_boost/features/auth/domain/entities/user.dart';
import 'package:the_boost/features/auth/presentation/bloc/login/login_bloc.dart';
import 'package:the_boost/features/auth/presentation/bloc/login/login_state.dart';
import 'package:the_boost/features/auth/presentation/widgets/dialogs/two_factor_dialog.dart';
import 'package:the_boost/features/auth/presentation/widgets/Menu/widgets/securityBadge.dart';

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

    print('[${DateTime.now()}] AppNavBar: 🔄 Starting build'
        '\n└─ Current route: $currentRoute');

    // Vérifier si le LoginBloc est disponible
    try {
      final loginBloc = context.read<LoginBloc>();
      final currentState = loginBloc.state;
      print('[${DateTime.now()}] AppNavBar: ✅ LoginBloc found'
          '\n└─ Current state: ${currentState.runtimeType}');
    } catch (e) {
      print('[${DateTime.now()}] AppNavBar: ❌ LoginBloc not found: $e');
    }

    return BlocConsumer<LoginBloc, LoginState>(
      listenWhen: (previous, current) {
        final shouldListen = previous.runtimeType != current.runtimeType;
        print('[${DateTime.now()}] AppNavBar: 👂 ListenWhen check'
            '\n└─ Previous: ${previous.runtimeType}'
            '\n└─ Current: ${current.runtimeType}'
            '\n└─ Should listen: $shouldListen');
        return shouldListen;
      },
      listener: (context, state) {
        print('[${DateTime.now()}] AppNavBar: 🎧 State change detected'
            '\n└─ New state: ${state.runtimeType}');

        if (state is LoginSuccess) {
          print('[${DateTime.now()}] AppNavBar: ✅ User authenticated'
              '\n└─ Username: ${state.user.username}'
              '\n└─ Email: ${state.user.email}');
        }
      },
      buildWhen: (previous, current) {
        final shouldRebuild = previous.runtimeType != current.runtimeType;
        print('[${DateTime.now()}] AppNavBar: 🔄 BuildWhen check'
            '\n└─ Previous: ${previous.runtimeType}'
            '\n└─ Current: ${current.runtimeType}'
            '\n└─ Should rebuild: $shouldRebuild');
        return shouldRebuild;
      },
      builder: (context, state) {
        print(
            '[${DateTime.now()}] AppNavBar: 🏗️ Building with state: ${state.runtimeType}');

        final isAuthenticated = state is LoginSuccess;
        final user = isAuthenticated ? (state).user : null;

        if (isAuthenticated) {
          print(
              '[${DateTime.now()}] AppNavBar: 👤 Building for authenticated user'
              '\n└─ Username: ${user?.username}');
        } else {
          print(
              '[${DateTime.now()}] AppNavBar: 🚫 Building for unauthenticated user'
              '\n└─ State: ${state.runtimeType}');
        }

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal:
                isMobile ? AppDimensions.paddingL : AppDimensions.paddingXXL,
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

  Widget _buildDesktopNavBar(
      BuildContext context, bool isAuthenticated, User? user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildLogo(),
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
                    _NavLink('Features',
                        route: '/features', currentRoute: currentRoute),
                    _NavLink('How It Works',
                        route: '/how-it-works', currentRoute: currentRoute),
                    _NavLink('Invest',
                        route: '/invest', currentRoute: currentRoute),
                    _NavLink('Learn More',
                        route: '/learn-more', currentRoute: currentRoute),
                  ],
                ),
                const SizedBox(width: AppDimensions.paddingM),

                // Afficher les boutons d'authentification en fonction de l'état
                if (isAuthenticated)
                  _buildAuthenticatedButtons(context, user)
                else
                  _buildUnauthenticatedButtons(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileNavBar(
      BuildContext context, bool isAuthenticated, User? user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildLogo(),
        Row(
          children: [
            if (isAuthenticated) ...[
              // Bouton Dashboard
              IconButton(
                icon: const Icon(Icons.dashboard),
                onPressed: () {
                  Navigator.pushNamed(context, '/dashboard');
                },
                tooltip: 'Dashboard',
              ),
              // Bouton 2FA avec indicateur visuel
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.security),
                    onPressed: () => _show2FADialog(context, user),
                    tooltip: '2FA Activate',
                  ),
                  if (user != null && !user.isTwoFactorEnabled)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              // Bouton Logout
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.red),
                onPressed: () => _handleLogout(context),
                tooltip: 'Logout',
              ),
            ] else if (onLoginPressed != null)
              TextButton(
                onPressed: onLoginPressed,
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

  Widget _buildAuthenticatedButtons(BuildContext context, User? user) {
    final bool is2FAEnabled = user?.isTwoFactorEnabled ?? false;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Bouton Dashboard
        TextButton.icon(
          icon: const Icon(Icons.dashboard, color: AppColors.primary),
          label: const Text(
            'Dashboard',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: () {
            Navigator.pushNamed(context, '/dashboard');
          },
        ),
        const SizedBox(width: AppDimensions.paddingS),

        // Bouton pour activer 2FA avec style différent en fonction de l'état
        AppButton(
          text: is2FAEnabled ? '2FA Activé' : '2FA Activer',
          onPressed: () => _show2FADialog(context, user),
          type: is2FAEnabled ? ButtonType.primary : ButtonType.secondary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingM,
            vertical: AppDimensions.paddingS,
          ),
        ),
        const SizedBox(width: AppDimensions.paddingS),

        // Bouton de déconnexion
        AppButton(
          text: 'Logout',
          onPressed: () => _handleLogout(context),
          type: ButtonType.secondary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingM,
            vertical: AppDimensions.paddingS,
          ),
        ),
      ],
    );
  }

  Widget _buildUnauthenticatedButtons(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onLoginPressed != null)
          TextButton(
            onPressed: onLoginPressed,
            child: const Text(
              'Login',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        const SizedBox(width: AppDimensions.paddingS),
        if (onSignUpPressed != null)
          AppButton(
            text: 'Get Started',
            onPressed: onSignUpPressed ?? () {},
            type: ButtonType.primary,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingL,
              vertical: AppDimensions.paddingS,
            ),
          ),
      ],
    );
  }

  void _show2FADialog(BuildContext context, User? user) {
    if (user == null) {
      print(
          '[2025-03-02 20:49:21] AppNavBar: ❌ Cannot show 2FA dialog - User is null');
      return;
    }

    print('[2025-03-02 20:49:21] AppNavBar: 🔄 2FA Activation requested'
        '\n└─ User: ${user.username}'
        '\n└─ 2FA Status: ${user.isTwoFactorEnabled ? 'Enabled' : 'Disabled'}');

    // Utilisation de votre dialogue 2FA existant
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => TwoFactorDialog(
        user: user,
        onSkip: () {
          Navigator.of(context).pop(); // Ferme le dialogue
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Vous pouvez activer la 2FA à tout moment via le menu de sécurité',
              ),
              action: SnackBarAction(
                label: 'Activer',
                onPressed: () => _show2FADialog(context, user),
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    print('[2025-03-02 20:49:21] AppNavBar: 🔄 Logout requested'
        '\n└─ User: raednas');

    // Envoyer l'événement de déconnexion au bloc
    context.read<LoginBloc>().add(LogoutRequested());
    Navigator.pushReplacementNamed(context, '/');
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
}

// Ajout d'un type de bouton supplémentaire pour les boutons de succès
extension ButtonTypeExtension on ButtonType {
  static const ButtonType success = ButtonType.text;
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
