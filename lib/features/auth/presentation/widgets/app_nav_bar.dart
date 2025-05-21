import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:the_boost/core/constants/colors.dart';
import 'package:the_boost/core/constants/dimensions.dart';
import 'package:the_boost/core/services/secure_storage_service.dart';
import 'package:the_boost/core/utils/responsive_helper.dart';
import 'package:the_boost/features/auth/presentation/pages/valuation/land_valuation_home_screen.dart';
import 'package:the_boost/features/auth/presentation/widgets/buttons/app_button.dart';
import 'package:the_boost/features/auth/domain/entities/user.dart';
import 'package:the_boost/features/auth/presentation/bloc/login/login_bloc.dart';
import 'package:the_boost/features/auth/presentation/bloc/login/login_state.dart';
import 'package:the_boost/features/auth/presentation/bloc/routes.dart';
import 'package:the_boost/features/auth/presentation/pages/preferences/user_preferences_screen.dart';
import 'package:the_boost/features/auth/presentation/widgets/dialogs/preferences_alert_dialog.dart';
import 'package:the_boost/features/auth/presentation/widgets/notification_bell.dart';
import 'package:the_boost/features/marketplace/presentation/pages/marketplace_page.dart';
import 'package:the_boost/features/metamask/data/models/metamask_provider.dart';
import 'dart:convert';
import 'dart:developer' as developer;

import '../../../../core/di/dependency_injection.dart';
import '../../../../core/services/prop_service.dart';


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
  Future<void> _handlePublicKeyUpdate(
      BuildContext context, String address, User? user) async {
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Connected to wallet: ${address.substring(0, 6)}...${address.substring(address.length - 4)}'),
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

    // Check if user is authenticated
    if (user != null) {
      developer.log(
          '[${DateTime.now()}] AppNavBar: 👤 User authenticated: ${user.id}');

      // Compare with user's stored wallet address if it exists
      if (user.publicKey != null && user.publicKey!.isNotEmpty) {
        // Check if the current connected wallet matches the user's stored wallet
        if (user.publicKey!.toLowerCase() != address.toLowerCase()) {
          developer.log(
              '[${DateTime.now()}] AppNavBar: ⚠️ Wallet mismatch detected. Connected: $address, Stored: ${user.publicKey}');

          // Show a wallet mismatch dialog or notification
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Wallet Mismatch'),
              content: const Text(
                  'The connected wallet address is different from the wallet address associated with your account. '
                  'Would you like to update your account to use this wallet?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Here you would typically make an API call to update the user's wallet
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Updating your account wallet...'),
                        backgroundColor: Colors.blue,
                      ),
                    );
                    // This would be replaced with actual API call
                  },
                  child: const Text('Update Wallet'),
                ),
              ],
            ),
          );
          return;
        } else {
          developer.log(
              '[${DateTime.now()}] AppNavBar: ✅ Connected wallet matches user\'s stored wallet');
        }
      } else {
        // User doesn't have a wallet address stored yet, so save this one
        developer.log(
            '[${DateTime.now()}] AppNavBar: 📝 User doesn\'t have a stored wallet. Saving this wallet address');

        // Here you would make an API call to update the user record with this wallet address
        // This would be replaced with actual API call
      }

      // Get encryption public key if needed
      final provider = Provider.of<MetamaskProvider>(context, listen: false);
      if (provider.publicKey.isEmpty) {
        developer.log(
            '[${DateTime.now()}] AppNavBar: 🔑 Requesting encryption public key for user ${user.id}');

        // We need to get the public key from MetaMask and save it to the backend
        final success = await provider.getEncryptionPublicKey(userId: user.id);
        if (success) {
          developer.log(
              '[${DateTime.now()}] AppNavBar: ✅ Encryption public key saved for user ${user.id}');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Wallet connected and encryption key saved successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          developer.log(
              '[${DateTime.now()}] AppNavBar: ❌ Failed to get encryption public key: ${provider.error}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to get encryption key: ${provider.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      developer.log(
          '[${DateTime.now()}] AppNavBar: ⚠️ User not authenticated. Wallet connected but not associated with user account');

      // Prompt user to log in to associate the wallet
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              const Text('Log in to associate this wallet with your account'),
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

    // Check if the user already has a publicKey stored
    final String? userPublicKey = user?.publicKey;
    final bool userHasStoredWallet =
        userPublicKey != null && userPublicKey.isNotEmpty;

    return Consumer<MetamaskProvider>(
      builder: (context, provider, _) {
        developer.log(
            '[${DateTime.now()}] AppNavBar: 🔄 Building wallet button. Connected: ${provider.currentAddress.isNotEmpty}. User wallet: $userHasStoredWallet');

        // If the wallet provider is in loading state, show spinner
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

        // If user is not authenticated, show a simplified connect button
        if (user == null) {
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
              developer.log(
                  '[${DateTime.now()}] AppNavBar: 🔘 MetaMask connect button clicked');
              provider.connect().then((_) {
                if (provider.currentAddress.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Please log in to associate this wallet with your account'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              });
            },
          );
        }

        // If user has a stored wallet key, show it in the button
        if (userHasStoredWallet) {
          return ElevatedButton.icon(
            icon: const Icon(Icons.account_balance_wallet, size: 16),
            label: Text(
              '${userPublicKey!.substring(0, 6)}...${userPublicKey.substring(userPublicKey.length - 4)}',
              style: const TextStyle(fontSize: 12),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: provider.currentAddress.isNotEmpty &&
                          provider.currentAddress.toLowerCase() ==
                              userPublicKey.toLowerCase()
                      ? Colors.green
                      : Colors.grey.shade300,
                ),
              ),
              elevation: 1,
            ),
            onPressed: () {
              if (provider.currentAddress.isEmpty) {
                // If wallet is not connected, try to connect
                provider.connect().then((_) {
                  if (provider.currentAddress.isNotEmpty) {
                    _handlePublicKeyUpdate(
                        context, provider.currentAddress, user);
                  }
                });
              } else {
                // If wallet is connected, show wallet info
                _showWalletInfo(context, provider, user);
              }
            },
          );
        }

        // If user is authenticated but has no wallet, show connect button
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
            developer.log(
                '[${DateTime.now()}] AppNavBar: 🔘 MetaMask connect button clicked');
            provider.connect().then((_) {
              if (provider.currentAddress.isNotEmpty) {
                _handlePublicKeyUpdate(context, provider.currentAddress, user);
              }
            });
          },
        );
      },
    );
  }

  // Helper method to show wallet info in a dialog
  void _showWalletInfo(
      BuildContext context, MetamaskProvider provider, User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Wallet Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Connected Address: ${provider.currentAddress}'),
            const SizedBox(height: 8),
            Text('User Public Key: ${user.publicKey ?? 'Not set'}'),
            const SizedBox(height: 16),
            const Text('Status: Connected',
                style: TextStyle(color: Colors.green)),
          ],
        ),
        actions: [
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

                    // Add Marketplace link only when authenticated
                    if (isAuthenticated)
                      _NavLink(
                        'Marketplace',
                        route: '/marketplace',
                        currentRoute: currentRoute,
                        onNavigate: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => MarketplacePage(
                                walletAddress: _getUserWalletAddress(user),
                              ),
                            ),
                          );
                        },
                        isNew: true, // Highlight as a new feature
                      ),
                    // Only show Invest link when authenticated
                    if (isAuthenticated)
                      _NavLink('Invest',
                          route: '/invest', currentRoute: currentRoute),
                    _NavLink('Learn More',
                        route: '/learn-more', currentRoute: currentRoute),
                  ],
                ),
                const SizedBox(width: AppDimensions.paddingM),
                // Add wallet connect button (only for authenticated users)
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
            // Add wallet connect button (only for authenticated users)
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

  // Helper method to get or generate wallet address
  String _getUserWalletAddress(User? user) {
    // If user has a publicKey, return it
    if (user != null && user.publicKey != null && user.publicKey!.isNotEmpty) {
      return user.publicKey!;
    }

    // Otherwise generate a placeholder address based on user ID or username
    if (user == null) return '';

    final String baseString = user.id.isNotEmpty
        ? user.id
        : (user.username.isNotEmpty ? user.username : 'user');

    // Pad the string if needed to ensure it's long enough
    final String paddedString = baseString.padRight(40, '0');

    // Create a fixed-length wallet address
    return '0x${paddedString.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase().substring(0, 40)}';
  }

  // Add method to handle mobile drawer with land valuation navigation
  Widget buildMobileDrawer(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        final isAuthenticated = state is LoginSuccess;
        final user = isAuthenticated ? state.user : null;

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
              ListTile(
                leading: const Icon(Icons.map),
                title: const Text('Land Valuation'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LandValuationHomeScreen(),
                    ),
                  );
                },
              ),
              // Add Marketplace option only when user is authenticated
              if (isAuthenticated)
                ListTile(
                  leading: const Icon(Icons.shopping_cart),
                  title: Row(
                    children: [
                      const Text('Marketplace'),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          //color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'NEW',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MarketplacePage(
                          walletAddress: _getUserWalletAddress(user),
                        ),
                      ),
                    );
                  },
                ),
              // Only show Invest when authenticated  
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
                          Icon(Icons.check_circle,
                              color: Colors.green, size: 14),
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
                        _showWalletInfo(context, provider, user!);
                      } else {
                        provider.connect().then((success) {
                          if (success) {
                            _handlePublicKeyUpdate(
                                context, provider.currentAddress, user);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Failed to connect wallet: ${provider.error}'),
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
      },
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
        // Add new Marketplace menu item
        PopupMenuItem(
            value: 'marketplace',
            child: Row(children: [
              const Icon(Icons.shopping_cart, color: Colors.black54),
              const SizedBox(width: AppDimensions.paddingM),
              const Text('Marketplace'),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  //color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                /*child: const Text(
                  'NEW',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),*/
              ),
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
            child: Consumer<MetamaskProvider>(builder: (context, provider, _) {
              return Row(
                children: [
                  const Icon(Icons.account_balance_wallet,
                      color: Colors.black54),
                  SizedBox(width: AppDimensions.paddingM),
                  Text('Manage Wallet'),
                  const Spacer(),
                  if (provider.currentAddress.isNotEmpty)
                    Icon(Icons.check_circle, color: Colors.green, size: 14)
                ],
              );
            })),
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
          case 'marketplace':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MarketplacePage(
                  walletAddress: _getUserWalletAddress(user),
                ),
              ),
            );
            break;
          case 'invest':
            Navigator.pushNamed(context, AppRoutes.myLands);
            break;
          case 'preferences':
            if (user != null) _checkAndShowPreferences(context, user);
            break;
          case 'wallet':
            final provider =
                Provider.of<MetamaskProvider>(context, listen: false);
            if (provider.currentAddress.isNotEmpty) {
              _showWalletInfo(context, provider, user!);
            } else {
              provider.connect().then((success) {
                if (success) {
                  _handlePublicKeyUpdate(
                      context, provider.currentAddress, user);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('Failed to connect wallet: ${provider.error}'),
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
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
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
                      leading:
                          const Icon(Icons.person, color: AppColors.primary),
                      title: const Text('My Profile'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/profile');
                      }),
                  // Add Marketplace menu item
                  ListTile(
                      leading: const Icon(Icons.shopping_cart,
                          color: AppColors.primary),
                      title: Row(
                        children: [
                          const Text('Marketplace'),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              //color: AppColors.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            /*child: const Text(
                            'NEW',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),*/
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MarketplacePage(
                              walletAddress: _getUserWalletAddress(user),
                            ),
                          ),
                        );
                      }),
                  ListTile(
                      leading:
                          const Icon(Icons.token, color: AppColors.primary),
                      title: const Text('My Investments'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, AppRoutes.invest);
                      }),
                  ListTile(
                      leading: const Icon(Icons.map, color: AppColors.primary),
                      title: const Text('Land Valuation'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const LandValuationHomeScreen(),
                          ),
                        );
                      }),
                  ListTile(
                      leading: const Icon(Icons.tune, color: AppColors.primary),
                      title: const Text('Investment Preferences'),
                      onTap: () {
                        Navigator.pop(context);
                        if (user != null)
                          _checkAndShowPreferences(context, user);
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
  final bool isNew;

  const _NavLink(
    this.title, {
    required this.route,
    this.currentRoute,
    this.onNavigate,
    this.isNew = false,
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isActive ? AppColors.primary : AppColors.textPrimary,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          if (isNew) ...[
            const SizedBox(width: 5),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              /*child: const Text(
                'NEW',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),*/
            ),
          ],
        ],
      ),
    );
  }
}
