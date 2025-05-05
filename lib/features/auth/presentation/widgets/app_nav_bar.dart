import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:the_boost/core/constants/colors.dart';
import 'package:the_boost/core/constants/dimensions.dart';
import 'package:the_boost/core/services/secure_storage_service.dart';
import 'package:the_boost/core/utils/responsive_helper.dart';
import 'package:the_boost/features/auth/presentation/widgets/buttons/app_button.dart';
import 'package:the_boost/features/auth/domain/entities/user.dart';
import 'package:the_boost/features/auth/presentation/bloc/login/login_bloc.dart';
import 'package:the_boost/features/auth/presentation/bloc/login/login_state.dart';
import 'package:the_boost/features/auth/presentation/bloc/routes.dart';
import 'package:the_boost/features/auth/presentation/pages/preferences/user_preferences_screen.dart';
import 'package:the_boost/features/auth/presentation/widgets/dialogs/preferences_alert_dialog.dart';
import 'package:the_boost/features/auth/presentation/widgets/notification_bell.dart';
import 'dart:convert';
import 'dart:developer' as developer;

import '../../../../core/di/dependency_injection.dart';
import '../../../../core/services/prop_service.dart';
import '../../../metamask/data/models/metamask_provider.dart';
import '../pages/valuation/land_valuation_home_screen.dart';
import '../pages/valuation/land_valuation_screen_with_nav.dart';
import 'howitworks_page.dart';

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
    print(
        '[2025-05-05 01:36:09] AppNavBar: 🔄 Building navbar\n└─ Current route: $currentRoute');

    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        print(
            '[2025-05-05 01:36:09] AppNavBar: 🔎 Current auth state: ${state.runtimeType}\n└─ Is authenticated: ${state is LoginSuccess}');
        final isAuthenticated = state is LoginSuccess;
        final user = isAuthenticated ? state.user : null;

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

  // Handle public key update with user integration
  Future<void> _handlePublicKeyUpdate(BuildContext context, String address, User? user) async {
    developer.log('[2025-05-05 01:36:09] AppNavBar: 🔑 Public key updated for address: $address');
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Connected to wallet: ${address.substring(0, 6)}...${address.substring(address.length - 4)}'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
    
    // If the user is authenticated, associate the wallet address with the user account
    if (user != null) {
      developer.log('[2025-05-05 01:36:09] AppNavBar: 👤 User authenticated: ${user.id}. Associating wallet address: $address with user: ${user.username}');
      
      final provider = Provider.of<MetamaskProvider>(context, listen: false);
      if (provider.publicKey.isEmpty) {
        developer.log('[2025-05-05 01:36:09] AppNavBar: 🔑 Requesting public key for user ${user.id}');
        
        // We need to get the public key from MetaMask and save it to the backend
        final success = await provider.getEncryptionPublicKey(userId: user.id);
        if (success) {
          developer.log('[2025-05-05 01:36:09] AppNavBar: ✅ Public key saved for user ${user.id}');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Wallet connected and public key saved successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          developer.log('[2025-05-05 01:36:09] AppNavBar: ❌ Failed to get public key: ${provider.error}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to get public key: ${provider.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        developer.log('[2025-05-05 01:36:09] AppNavBar: ℹ️ Public key already exists for user ${user.id}');
        
        // Associate the existing public key with this user explicitly
        provider.savePublicKeyToBackend(userId: user.id);
      }
    } else {
      developer.log('[2025-05-05 01:36:09] AppNavBar: ⚠️ User not authenticated. Wallet connected but not associated with user account');
      
      // Prompt user to log in to associate the wallet
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Log in to associate this wallet with your account'),
          backgroundColor: Colors.orange,
          action: SnackBarAction(
            label: 'Login',
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.auth);
            },
          ),
        ),
      );
    }
  }

  // Add this widget to your AppNavBar class
  Widget _buildWalletButton(BuildContext context, User? user) {
    return Consumer<MetamaskProvider>(
      builder: (context, provider, _) {
        developer.log('[2025-05-05 01:36:09] AppNavBar: 🔄 Building wallet button. Connected: ${provider.currentAddress.isNotEmpty}. Loading: ${provider.isLoading}');
        
        // Loading state
        if (provider.isLoading) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          );
        }

        // Connected state
        if (provider.currentAddress.isNotEmpty) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primary),
            ),
            child: InkWell(
              onTap: () => _showWalletOptions(context, provider, user),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.account_balance_wallet, color: AppColors.primary, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    '${provider.currentAddress.substring(0, 4)}...${provider.currentAddress.substring(provider.currentAddress.length - 4)}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Not connected state
        return ElevatedButton.icon(
          icon: const Icon(Icons.account_balance_wallet, size: 16),
          label: const Text('Connect Wallet', style: TextStyle(fontSize: 12)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            elevation: 1,
          ),
          onPressed: () {
            developer.log('[2025-05-05 01:36:09] AppNavBar: 🔘 MetaMask connect button clicked');
            
            try {
              provider.connect().then((success) {
                developer.log('[2025-05-05 01:36:09] AppNavBar: 🔄 MetaMask connect result: $success');
                
                if (success && provider.currentAddress.isNotEmpty) {
                  _handlePublicKeyUpdate(context, provider.currentAddress, user);
                } else if (!success && provider.error.isNotEmpty) {
                  developer.log('[2025-05-05 01:36:09] AppNavBar: ❌ MetaMask error: ${provider.error}');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('MetaMask error: ${provider.error}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }).catchError((error) {
                developer.log('[2025-05-05 01:36:09] AppNavBar: ❌ MetaMask connect error: $error');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to connect to MetaMask: $error'),
                    backgroundColor: Colors.red,
                  ),
                );
              });
            } catch (e) {
              developer.log('[2025-05-05 01:36:09] AppNavBar: ❌ Exception during MetaMask connection: $e');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to connect to MetaMask: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        );
      },
    );
  }

  // Show wallet options dialog with user integration
  void _showWalletOptions(BuildContext context, MetamaskProvider provider, User? user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Wallet Connected'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Your Ethereum Address:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              SelectableText(provider.currentAddress),
              const SizedBox(height: 16),
              if (provider.publicKey.isNotEmpty) ...[
                const Text('Public Key Status:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 16),
                    const SizedBox(width: 4),
                    const Text('Public Key Saved'),
                  ],
                ),
              ],
              if (user != null) ...[
                const SizedBox(height: 16),
                const Text('Account Status:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.link, color: Colors.blue, size: 16),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text('Connected to ${user.username}\'s account (ID: ${user.id})'),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              const Text('Network:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('ChainID: ${provider.chainId.isEmpty ? "Unknown" : provider.chainId}'),
            ],
          ),
        ),
        actions: [
          if (!provider.success && provider.publicKey.isEmpty)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                provider.getEncryptionPublicKey(userId: user?.id).then((success) {
                  if (success) {
                    _handlePublicKeyUpdate(context, provider.currentAddress, user);
                  } else if (provider.error.isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to get public key: ${provider.error}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                });
              },
              child: const Text('Get Public Key'),
            ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              provider.disconnect();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Wallet disconnected'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text('Disconnect'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopNavBar(
      BuildContext context, bool isAuthenticated, User? user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildLogo(context),
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
                    _NavLink(
                      'How It Works',
                      route: '/how-it-works',
                      currentRoute: currentRoute,
                      onNavigate: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => HowItWorksPage(),
                          ),
                        );
                      },
                    ),
                    // Only show Invest if user is authenticated
                    if (isAuthenticated)
                      _NavLink('Invest', route: '/invest', currentRoute: currentRoute),
                    _NavLink('Learn More', route: '/learn-more', currentRoute: currentRoute),
                  ],
                ),
                const SizedBox(width: AppDimensions.paddingM),
                // Add wallet connect button
                _buildWalletButton(context, user),
                const SizedBox(width: AppDimensions.paddingM),
                if (isAuthenticated)
                  Row(
                    children: [
                      NotificationBell(
                        onOpenPreferences: () =>
                            _checkAndShowPreferences(context, user!),
                      ),
                      const SizedBox(width: AppDimensions.paddingM),
                      _buildUserMenu(context, user),
                    ],
                  )
                else
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        onPressed: onLoginPressed ??
                            () => Navigator.pushNamed(context, AppRoutes.auth),
                        child: const Text(
                          'Login',
                          style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.paddingS),
                      AppButton(
                        text: 'Get Started',
                        onPressed: onSignUpPressed ??
                            () => Navigator.pushNamed(context, AppRoutes.auth),
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

  Widget _buildMobileNavBar(
      BuildContext context, bool isAuthenticated, User? user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildLogo(context),
        Row(
          children: [
            // Add wallet connect button
            _buildWalletButton(context, user),
            const SizedBox(width: 8),
            if (isAuthenticated) ...[
              NotificationBell(
                onOpenPreferences: () =>
                    _checkAndShowPreferences(context, user!),
              ),
              IconButton(
                icon: const Icon(Icons.dashboard),
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.dashboard),
              ),
              _buildUserMenuMobile(context, user),
            ] else
              TextButton(
                onPressed: onLoginPressed ??
                    () => Navigator.pushNamed(context, AppRoutes.auth),
                child: const Text(
                  'Login',
                  style: TextStyle(
                      color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
              ),
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ],
        ),
      ],
    );
  }

  // Method to handle mobile drawer with land valuation navigation
  Widget buildMobileDrawer(BuildContext context) {
    // Check if user is authenticated to show/hide Invest option
    final state = context.watch<LoginBloc>().state;
    final isAuthenticated = state is LoginSuccess;
    final user = isAuthenticated ? (state as LoginSuccess).user : null;
    
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppColors.primary,
            ),
            child: Row(
              children: [
                const Icon(Icons.landscape, color: Colors.white, size: 32),
                const SizedBox(width: 8),
                Text(
                  'TheBoost',
                  style: GoogleFonts.montserrat(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
            },
          ),
          ListTile(
            leading: const Icon(Icons.featured_play_list),
            title: const Text('Features'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/features');
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('How It Works'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HowItWorksPage(),
                ),
              );
            },
          ),
          // Only show Invest option if authenticated
          if (isAuthenticated)
            ListTile(
              leading: const Icon(Icons.token),
              title: const Text('Invest'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/invest');
              },
            ),
          ListTile(
            leading: const Icon(Icons.book),
            title: const Text('Learn More'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/learn-more');
            },
          ),
          // Add wallet management option to drawer
          Consumer<MetamaskProvider>(
            builder: (context, provider, _) {
              return ListTile(
                leading: const Icon(Icons.account_balance_wallet),
                title: Row(
                  children: [
                    const Text('Wallet'),
                    const SizedBox(width: 10),
                    if (provider.isLoading) 
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else if (provider.currentAddress.isNotEmpty)
                      Icon(Icons.check_circle, color: Colors.green, size: 14),
                  ],
                ),
                subtitle: provider.currentAddress.isNotEmpty 
                  ? Text(
                      '${provider.currentAddress.substring(0, 4)}...${provider.currentAddress.substring(provider.currentAddress.length - 4)}',
                      style: TextStyle(fontSize: 12),
                    )
                  : null,
                onTap: () {
                  Navigator.pop(context);
                  if (provider.currentAddress.isNotEmpty) {
                    _showWalletOptions(context, provider, user);
                  } else {
                    provider.connect().then((success) {
                      if (success) {
                        _handlePublicKeyUpdate(context, provider.currentAddress, user);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to connect wallet: ${provider.error}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    });
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _checkAndShowPreferences(BuildContext context, User user) async {
    final secureStorage = SecureStorageService();
    final prefsJson =
        await secureStorage.read(key: 'user_preferences_${user.id}');
    if (prefsJson == null) {
      showDialog(
        context: context,
        builder: (context) => PreferencesAlertDialog(user: user),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => UserPreferencesScreen(user: user)),
      );
    }
  }

  Widget _buildLogo(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, '/'),
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
    final firstLetter = user?.username.isNotEmpty == true
        ? user!.username[0].toUpperCase()
        : 'U';

    return PopupMenuButton<String>(
      offset: const Offset(0, 40),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingM,
            vertical: AppDimensions.paddingS),
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
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: AppDimensions.paddingS),
            Text(
              displayName,
              style: const TextStyle(
                  color: AppColors.primary, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: AppDimensions.paddingS),
            const Icon(Icons.arrow_drop_down, color: AppColors.primary),
          ],
        ),
      ),
      itemBuilder: (context) => [
        const PopupMenuItem(
            value: 'dashboard',
            child: Row(children: [
              Icon(Icons.dashboard, color: Colors.black54),
              SizedBox(width: AppDimensions.paddingM),
              Text('Dashboard')
            ])),
        const PopupMenuItem(
            value: 'profile',
            child: Row(children: [
              Icon(Icons.person, color: Colors.black54),
              SizedBox(width: AppDimensions.paddingM),
              Text('My Profile')
            ])),
        const PopupMenuItem(
            value: 'invest',
            child: Row(children: [
              Icon(Icons.token, color: Colors.black54),
              SizedBox(width: AppDimensions.paddingM),
              Text('My Investments')
            ])),
        const PopupMenuItem(
            value: 'preferences',
            child: Row(children: [
              Icon(Icons.tune, color: Colors.black54),
              SizedBox(width: AppDimensions.paddingM),
              Text('Investment Preferences')
            ])),
        // Add wallet management option
        PopupMenuItem(
            value: 'wallet',
            child: Consumer<MetamaskProvider>(
              builder: (context, provider, _) {
                return Row(
                  children: [
                    Icon(Icons.account_balance_wallet, color: Colors.black54),
                    SizedBox(width: AppDimensions.paddingM),
                    Text('Manage Wallet'),
                    const Spacer(),
                    if (provider.currentAddress.isNotEmpty)
                      Icon(Icons.check_circle, color: Colors.green, size: 14)
                  ],
                );
              }
            )),
        const PopupMenuItem(
            value: 'settings',
            child: Row(children: [
              Icon(Icons.settings, color: Colors.black54),
              SizedBox(width: AppDimensions.paddingM),
              Text('Settings')
            ])),
        const PopupMenuDivider(),
        const PopupMenuItem(
            value: 'logout',
            child: Row(children: [
              Icon(Icons.logout, color: Colors.red),
              SizedBox(width: AppDimensions.paddingM),
              Text('Logout', style: TextStyle(color: Colors.red))
            ])),
      ],
      onSelected: (value) {
        switch (value) {
          case 'dashboard':
            Navigator.pushNamed(context, AppRoutes.dashboard);
            break;
          case 'profile':
            Navigator.pushNamed(context, '/profile');
            break;
          case 'invest':
            Navigator.pushNamed(context, AppRoutes.invest);
            break;
          case 'preferences':
            if (user != null) _checkAndShowPreferences(context, user);
            break;
          case 'wallet':
            final provider = Provider.of<MetamaskProvider>(context, listen: false);
            if (provider.currentAddress.isNotEmpty) {
              _showWalletOptions(context, provider, user);
            } else {
              provider.connect().then((success) {
                if (success) {
                  _handlePublicKeyUpdate(context, provider.currentAddress, user);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to connect wallet: ${provider.error}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              });
            }
            break;
          case 'settings':
            break; // Add settings page route
          case 'logout':
            context.read<LoginBloc>().add(LogoutRequested());
            Navigator.pushReplacementNamed(context, AppRoutes.home);
            break;
        }
      },
    );
  }

  Widget _buildUserMenuMobile(BuildContext context, User? user) {
    final firstLetter = user?.username.isNotEmpty == true
        ? user!.username[0].toUpperCase()
        : 'U';

    return IconButton(
      icon: CircleAvatar(
        backgroundColor: AppColors.primary,
        radius: 16,
        child: Text(
          firstLetter,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          builder: (context) => SingleChildScrollView(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(vertical: AppDimensions.paddingL),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                                fontSize: 20),
                          ),
                        ),
                        const SizedBox(width: AppDimensions.paddingL),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user?.username ?? 'User',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 16)),
                              Text(user?.email ?? '',
                                  style: const TextStyle(
                                      color: Colors.black54, fontSize: 14)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  ListTile(
                      leading:
                          const Icon(Icons.dashboard, color: AppColors.primary),
                      title: const Text('Dashboard'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, AppRoutes.dashboard);
                      }),
                  ListTile(
                      leading: const Icon(Icons.person, color: AppColors.primary),
                      title: const Text('My Profile'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/profile');
                      }),
                  ListTile(
                      leading: const Icon(Icons.token, color: AppColors.primary),
                      title: const Text('My Investments'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, AppRoutes.invest);
                      }),
                  ListTile(
                      leading: const Icon(Icons.help_outline, color: AppColors.primary),
                      title: const Text('How It Works'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HowItWorksPage(),
                          ),
                        );
                      }),
                  // Add wallet management option
                  Consumer<MetamaskProvider>(
                    builder: (context, provider, _) {
                      return ListTile(
                        leading: const Icon(Icons.account_balance_wallet, color: AppColors.primary),
                        title: const Text('Manage Wallet'),
                        subtitle: provider.currentAddress.isNotEmpty 
                          ? Text(
                              '${provider.currentAddress.substring(0, 4)}...${provider.currentAddress.substring(provider.currentAddress.length - 4)}',
                              style: TextStyle(fontSize: 12),
                            )
                          : Text('Not connected', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        trailing: provider.currentAddress.isNotEmpty
                          ? Icon(Icons.check_circle, color: Colors.green, size: 16)
                          : Icon(Icons.arrow_forward_ios, size: 14),
                        onTap: () {
                          Navigator.pop(context);
                          if (provider.currentAddress.isNotEmpty) {
                            _showWalletOptions(context, provider, user);
                          } else {
                            provider.connect().then((success) {
                              if (success) {
                                _handlePublicKeyUpdate(context, provider.currentAddress, user);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Failed to connect wallet: ${provider.error}'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            });
                          }
                        },
                      );
                    }
                  ),
                  ListTile(
                      leading: const Icon(Icons.tune, color: AppColors.primary),
                      title: const Text('Investment Preferences'),
                      onTap: () {
                        Navigator.pop(context);
                        if (user != null) _checkAndShowPreferences(context, user);
                      }),
                  ListTile(
                      leading:
                          const Icon(Icons.settings, color: AppColors.primary),
                      title: const Text('Settings'),
                      onTap: () {
                        Navigator.pop(context);
                      }),
                  const Divider(),
                  ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: const Text('Logout',
                          style: TextStyle(color: Colors.red)),
                      onTap: () {
                        Navigator.pop(context);
                        context.read<LoginBloc>().add(LogoutRequested());
                        Navigator.pushReplacementNamed(context, AppRoutes.home);
                      }),
                ],
              ),
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
  final VoidCallback? onNavigate;

  const _NavLink(
    this.title, {
    required this.route,
    this.currentRoute,
    this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = currentRoute == route;
    return TextButton(
      onPressed: () {
        if (isActive) return;

        // If custom navigation is provided, use it
        if (onNavigate != null) {
          onNavigate!();
        } else {
          // Otherwise use standard navigation
          Navigator.pushNamed(context, route);
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