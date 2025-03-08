import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:the_boost/core/constants/constants.dart';
import 'package:the_boost/features/auth/data/models/land_model.dart';
import 'package:the_boost/features/investment/presentation/bloc/land_bloc.dart';
import 'package:the_boost/features/auth/presentation/widgets/Menu/app_menu.dart';
import 'package:the_boost/features/auth/presentation/widgets/Menu/widgets/securityBadge.dart';
import 'package:the_boost/features/auth/presentation/widgets/catalogue/filter_bar.dart';
import 'package:the_boost/features/auth/presentation/widgets/catalogue/land_card.dart';
import 'package:the_boost/features/auth/presentation/widgets/dialogs/two_factor_dialog.dart';
import 'package:the_boost/features/auth/presentation/widgets/footer/app_footer.dart';
import '../../domain/entities/user.dart';

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
  int selectedIndex = 0;
  String currentDateTime = '';

  List<Land> get filteredLands {
    final LandState state = context.watch<LandBloc>().state;
    if (state is! LandLoadedState) return [];

    return state.lands.where((land) {
      final matchesType = _selectedType == null || land.type == _selectedType;
      final matchesStatus = _selectedStatus == null || land.status == _selectedStatus;
      final matchesQuery = _searchQuery.isEmpty ||
          land.title != null && land.title!.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesType && matchesStatus && matchesQuery;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    print('[HomeScreen: 🚀 Initializing HomeScreen state] - Current User: ${widget.user?.username}');

    // Charger les terrains au démarrage
    context.read<LandBloc>().add(LoadLandsEvent());
    _startTimeUpdate();

    // Vérification de 2FA
    if (widget.user != null && !widget.user!.isTwoFactorEnabled) {
      print('HomeScreen: 🔔 Scheduling 2FA dialog');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _show2FADialog();
      });
    }
  }

  void _show2FADialog() {
    if (widget.user == null) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => TwoFactorDialog(
        user: widget.user,
        onSkip: () {
          Navigator.of(context).pop();
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
      currentDateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now().toUtc());
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
              AppMenu(
                user: widget.user,
                on2FAButtonPressed: widget.user != null ? _show2FADialog : null,
                selectedIndex: selectedIndex,
                onMenuItemSelected: (index) {
                  setState(() => selectedIndex = index);
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
                          Container(
                            padding: const EdgeInsets.all(kDefaultPadding),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [kDefaultShadow],
                            ),
                            child: FilterBar(
                              onTypeChanged: (type) => setState(() => _selectedType = type),
                              onStatusChanged: (status) => setState(() => _selectedStatus = status),
                              onSearchChanged: (query) => setState(() => _searchQuery = query),
                              selectedType: _selectedType,
                              selectedStatus: _selectedStatus,
                            ),
                          ),
                          Expanded(
                            child: BlocBuilder<LandBloc, LandState>(
                              builder: (context, state) {
                                if (state is LandLoadingState) {
                                  return const Center(
                                    child: CircularProgressIndicator(color: kPrimaryColor),
                                  );
                                }
                                if (state is LandErrorState) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(state.message),
                                        ElevatedButton(
                                          onPressed: () {
                                            context.read<LandBloc>().add(LoadLandsEvent());
                                          },
                                          child: const Text('Réessayer'),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                return _buildLandGrid(filteredLands, constraints);
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              AppFooter(currentDateTime: currentDateTime),
            ],
          ),

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
    final int crossAxisCount = (constraints.maxWidth / itemWidth).floor().clamp(1, 4);

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
        return LandCard(
          land: lands[index],
          onTap: () {},
        );
      },
    );
  }
}