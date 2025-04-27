// lib/features/auth/presentation/pages/home_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart'; // Add this import for TTS
import 'package:intl/intl.dart';
import 'package:the_boost/core/constants/constants.dart';
import 'package:the_boost/core/di/dependency_injection.dart';
import 'package:the_boost/features/auth/data/models/land_model.dart';
import 'package:the_boost/features/auth/domain/entities/user.dart';
import 'package:the_boost/features/auth/presentation/bloc/lands/land_bloc.dart';
import 'package:the_boost/features/auth/presentation/widgets/Menu/widgets/securityBadge.dart';
import 'package:the_boost/features/auth/presentation/widgets/menu/app_menu.dart';
import 'package:the_boost/features/auth/presentation/widgets/catalogue/filter_bar.dart';
import 'package:the_boost/features/auth/presentation/widgets/catalogue/land_card.dart';
import 'package:the_boost/features/auth/presentation/widgets/dialogs/two_factor_dialog.dart';
import 'package:the_boost/features/auth/presentation/widgets/footer/app_footer.dart';

class HomeScreen extends StatefulWidget {
  final User? user;

  const HomeScreen({super.key, this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  int selectedIndex = 0;
  String currentDateTime = '';
  final FlutterTts _flutterTts = FlutterTts(); // Add FlutterTts instance

  @override
  void initState() {
    super.initState();
    print('[HomeScreen: 🚀 Initializing HomeScreen state] - Current User: ${widget.user?.username}');
    _startTimeUpdate();
    _initTts(); // Initialize TTS
    if (widget.user != null && !widget.user!.isTwoFactorEnabled) {
      print('HomeScreen: 🔔 Scheduling 2FA dialog');
      WidgetsBinding.instance.addPostFrameCallback((_) => _show2FADialog());
    }
  }

  // Initialize TTS settings
  Future<void> _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  // Speak the given text
  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }

  // Stop speaking
  Future<void> _stopSpeaking() async {
    await _flutterTts.stop();
  }

  void _show2FADialog() {
    if (widget.user == null) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => TwoFactorDialog(
        user: widget.user!,
        onSkip: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Vous pouvez activer la 2FA à tout moment via le menu de sécurité'),
              action: SnackBarAction(label: 'Activer', onPressed: _show2FADialog),
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
  void dispose() {
    _stopSpeaking(); // Stop any ongoing speech when disposing
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = getIt<LandBloc>();
        bloc.add(LoadLands());
        return bloc;
      },
      child: Scaffold(
        backgroundColor: kBackgroundColor,
        body: Stack(
          children: [
            Column(
              children: [
                AppMenu(
                  user: widget.user,
                  on2FAButtonPressed: widget.user != null ? _show2FADialog : null,
                  selectedIndex: selectedIndex,
                  onMenuItemSelected: (index) => setState(() => selectedIndex = index),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) => Container(
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
                            decoration: BoxDecoration(color: Colors.white, boxShadow: [kDefaultShadow]),
                            child: FilterBar(
                              onSearchChanged: (query) {
                                setState(() => _searchQuery = query);
                                context.read<LandBloc>().add(ApplyFilters(
                                      priceRange: const RangeValues(0, 1000000),
                                      searchQuery: query,
                                      sortBy: '',
                                    ));
                              },
                            ),
                          ),
                          Expanded(
                            child: BlocBuilder<LandBloc, LandState>(
                              builder: (context, state) {
                                print('[${DateTime.now()}] HomeScreen: BlocBuilder state: $state');
                                if (state is LandLoading) {
                                  return const Center(child: CircularProgressIndicator(color: kPrimaryColor));
                                } else if (state is LandLoaded) {
                                    final lands = state.lands.where((land) => land.availability == 'AVAILABLE').toList();
                                    print('[${DateTime.now()}] HomeScreen: Loaded ${lands.length} available lands');
                                    if (lands.isEmpty) {
                                    return Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.search_off_rounded, size: 64, color: kTextLightColor.withOpacity(0.5)),
                                          const SizedBox(height: 16),
                                          Text(
                                            'Aucun terrain trouvé',
                                            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: kTextLightColor),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                  return _buildLandGrid(lands, constraints);
                                } else if (state is LandError) {
                                print('[${DateTime.now()}] HomeScreen: LandError: ${state.message}');
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('Erreur: ${state.message}'),
                                      const SizedBox(height: 16),
                                      ElevatedButton(
                                        onPressed: () {
                                          context.read<LandBloc>().add(LoadLands());
                                        },
                                        child: const Text('Réessayer'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                                return const Center(child: Text('Aucun terrain disponible'));
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                AppFooter(currentDateTime: currentDateTime),
              ],
            ),
            if (widget.user != null && !widget.user!.isTwoFactorEnabled)
              const Positioned(top: 90, right: 16, child: SecurityBadge(message: '2FA non activé')),
          ],
        ),
      ),
    );
  }

  Widget _buildLandGrid(List<Land> lands, BoxConstraints constraints) {
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
        final land = lands[index];
        return LandCard(
          land: land,
          onTap: () => Navigator.pushNamed(context, '/land-details', arguments: land.id),
          onSpeak: () {
            final description = land.description ?? 'No description available';
            final price = land.priceland != null ? '${land.priceland} DT' : 'Price not available';
            final coordinates = land.latitude != null && land.longitude != null
                ? 'Coordinates: ${land.latitude}, ${land.longitude}'
                : 'Coordinates not available';
            _speak('Land: ${land.title}. Location: ${land.location}. Price: $price. $coordinates. Description: $description');
          },
          onStopSpeaking: _stopSpeaking,
        );
      },
    );
  }
}