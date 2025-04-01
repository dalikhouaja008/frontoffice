import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:the_boost/core/constants/constants.dart';
import 'package:the_boost/features/auth/data/models/land_model.dart';
import 'package:the_boost/features/auth/presentation/widgets/Menu/app_menu.dart';
import 'package:the_boost/features/auth/presentation/widgets/Menu/widgets/securityBadge.dart';
import 'package:the_boost/features/auth/presentation/widgets/catalogue/filter_bar.dart';
import 'package:the_boost/features/auth/presentation/widgets/catalogue/land_card.dart';
import 'package:the_boost/features/auth/presentation/widgets/dialogs/two_factor_dialog.dart';
import 'package:the_boost/features/auth/presentation/widgets/footer/app_footer.dart';
import '../../domain/entities/user.dart';
import 'package:the_boost/core/services/land_service.dart'; // Import your LandService

class HomeScreen extends StatefulWidget {
  final User? user;

  const HomeScreen({super.key, this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  LandType? _selectedType;
  LandStatus? _selectedStatus;
  String _searchQuery = '';
  bool _isLoading = false;
  List<Land> _lands = [];
  int selectedIndex = 0;
  String currentDateTime = '';

  // Reference to LandService for fetching lands dynamically
  final LandService _landService = LandService();

  // Filter logic for lands
  List<Land> get filteredLands {
    return _lands.where((land) {
      final matchesType = _selectedType == null || land.type == _selectedType;
      final matchesStatus =
          _selectedStatus == null || land.status == _selectedStatus;
      final matchesQuery = _searchQuery.isEmpty ||
          land.title.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesType && matchesStatus && matchesQuery;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    print(
        '[HomeScreen: 🚀 Initializing HomeScreen state] - Current User: ${widget.user?.username}');

    _loadLands();
    _startTimeUpdate();

    // Show 2FA dialog if 2FA is not enabled
    if (widget.user != null && !widget.user!.isTwoFactorEnabled) {
      print('HomeScreen: 🔔 Scheduling 2FA dialog');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _show2FADialog();
      });
    }
  }

  // Show 2FA dialog
  void _show2FADialog() {
    if (widget.user == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => TwoFactorDialog(
        user: widget.user!,
        onSkip: () {
          Navigator.of(context).pop(); // Close the dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Vous pouvez activer la 2FA à tout moment via le menu de sécurité',
              ),
              action: SnackBarAction(
                label: 'Activer',
                onPressed: _show2FADialog,
              ),
            ),
          );
        },
      ),
    );
  }

  // Update the current date and time every second
  void _startTimeUpdate() {
    _updateDateTime();
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        _updateDateTime();
      } else {
        timer.cancel();
      }
    });
  }

  void _updateDateTime() {
    setState(() {
      currentDateTime =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now().toUtc());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Stack(
        children: [
          Column(
            children: [
              // App Menu
              AppMenu(
                user: widget.user,
                on2FAButtonPressed:
                    widget.user != null ? _show2FADialog : null,
                selectedIndex: selectedIndex,
                onMenuItemSelected: (index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
              ),

              // Content Section
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Container(
                      margin: const EdgeInsets.all(kDefaultPadding),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [kDefaultShadow],
                      ),
                      child: Column(
                        children: [
                          // Filter Bar
                          Container(
                            padding: const EdgeInsets.all(kDefaultPadding),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [kDefaultShadow],
                            ),
                            child: FilterBar(
                              onTypeChanged: (type) =>
                                  setState(() => _selectedType = type),
                              onStatusChanged: (status) =>
                                  setState(() => _selectedStatus = status),
                              onSearchChanged: (query) =>
                                  setState(() => _searchQuery = query),
                              selectedType: _selectedType,
                              selectedStatus: _selectedStatus,
                            ),
                          ),

                          // Grid Content
                          Expanded(
                            child: _isLoading
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      color: kPrimaryColor,
                                    ),
                                  )
                                : _buildLandGrid(filteredLands, constraints),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Footer
              AppFooter(currentDateTime: currentDateTime),
            ],
          ),

          // Security Badge if 2FA is not enabled
          if (widget.user != null && !widget.user!.isTwoFactorEnabled)
            const Positioned(
              top: 90,
              right: 16,
              child: SecurityBadge(message: '2FA non activé'),
            ),
        ],
      ),
    );
  }

  // Build the grid of lands
  Widget _buildLandGrid(List<Land> lands, BoxConstraints constraints) {
    if (lands.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: kTextLightColor.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun terrain trouvé',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: kTextLightColor,
                  ),
            ),
          ],
        ),
      );
    }

    const double itemWidth = 300.0;
    final int crossAxisCount =
        (constraints.maxWidth / itemWidth).floor().clamp(1, 4);

    return GridView.builder(
      padding: const EdgeInsets.all(kDefaultPadding),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.85,
        crossAxisSpacing: kDefaultPadding,
        mainAxisSpacing: kDefaultPadding,
      ),
      itemCount: lands.length,
      itemBuilder: (context, index) {
        final land = lands[index];
        return LandCard(
          land: land,
          onTap: () {
            // Navigate to the land details screen
            Navigator.pushNamed(
              context,
              '/land-details',
              arguments: land.id,
            );
          },
        );
      },
    );
  }

  // Load lands dynamically from the backend
  Future<void> _loadLands() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch lands from the backend
      final fetchedLands = await _landService.fetchLands();

      setState(() {
        _lands = fetchedLands;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Erreur lors du chargement des terrains: $e');
    }
  }
}