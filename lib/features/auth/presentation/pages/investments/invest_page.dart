import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:the_boost/core/constants/colors.dart';
import 'package:the_boost/core/constants/dimensions.dart';
import 'package:the_boost/features/auth/data/models/land_model.dart';
import 'package:the_boost/features/auth/presentation/bloc/lands/land_bloc.dart';
import 'package:the_boost/features/auth/presentation/pages/investments/land_detail_screen.dart';
import 'package:the_boost/features/auth/presentation/widgets/app_nav_bar.dart';
import 'package:the_boost/features/auth/presentation/widgets/catalogue/land_card.dart';
import 'package:the_boost/features/auth/presentation/widgets/invest_filters.dart';

class InvestPage extends StatefulWidget {
  const InvestPage({Key? key}) : super(key: key);

  @override
  _InvestPageState createState() => _InvestPageState();
}

class _InvestPageState extends State<InvestPage> {
  final FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _initTtsAsync();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LandBloc>().add(LoadLands());
    });
  }

  Future<void> _initTtsAsync() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(1.0);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.2);
  }

  Future<void> _speak(String text) async {
    await _flutterTts.stop();
    await _flutterTts.speak(text);
  }

  Future<void> _stopSpeaking() async {
    await _flutterTts.stop();
  }

  @override
  void dispose() {
    _stopSpeaking();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const AppNavBar(currentRoute: '/invest'),
          Expanded(
            child: Row(
              children: [
                // Persistent Sidebar with Filters
                Container(
                  width: 300, // Fixed width for the sidebar
                  color: Colors.grey[200], // Light grey background
                  child: InvestFilters(
                    onFiltersChanged: (filters) {
                      context.read<LandBloc>().add(ApplyFilters(
                        priceRange: RangeValues(
                          (filters['priceRange']['min'] as double?) ?? 0,
                          (filters['priceRange']['max'] as double?) ?? 1000000,
                        ),
                        searchQuery: filters['searchQuery'] as String? ?? '',
                        sortBy: filters['sortBy'] as String? ?? '',
                        landType: filters['landType'] as String?,
                        validationStatus: filters['validationStatus'] as String?,
                        availability: filters['availability'] as String?,
                        amenities: (filters['amenities'] as Map<String, bool>?)?.cast<String, bool>(),
                      ));
                    },
                    onClose: () {}, // No-op since sidebar is persistent
                  ),
                ),
                // Land Grid
                Expanded(
                  child: BlocListener<LandBloc, LandState>(
                    listener: (context, state) {
                      if (state is LandError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: ${state.message}'), backgroundColor: Colors.red),
                        );
                      } else if (state is NavigatingToLandDetails) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LandDetailsScreen(land: state.land)),
                        );
                      }
                    },
                    child: BlocBuilder<LandBloc, LandState>(
                      buildWhen: (previous, current) => current is LandLoading || current is LandLoaded || current is LandError,
                      builder: (context, state) {
                        if (state is LandLoading) return const Center(child: CircularProgressIndicator());
                        if (state is LandLoaded) return _buildLandGrid(context, state.lands);
                        if (state is LandError) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Failed to load lands: ${state.message}',
                                  style: const TextStyle(color: Colors.red, fontSize: 18),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () => context.read<LandBloc>().add(LoadLands()),
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          );
                        }
                        return const Center(
                          child: Text(
                            'No lands available',
                            style: TextStyle(color: Colors.black, fontSize: 18),
                            semanticsLabel: 'No lands available',
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLandGrid(BuildContext context, List<Land> lands) {
    if (lands.isEmpty) {
      return const Center(
        child: Text(
          'No lands available after filtering',
          style: TextStyle(color: Colors.black, fontSize: 18),
          semanticsLabel: 'No lands available after filtering',
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: AppDimensions.paddingS,
          mainAxisSpacing: AppDimensions.paddingS,
          childAspectRatio: 3 / 4,
        ),
        itemCount: lands.length,
        itemBuilder: (context, index) {
          final land = lands[index];
          return Semantics(
            label: 'Land: ${land.title}, Location: ${land.location}, Price: ${land.priceland ?? 'N/A'} DT',
            child: LandCard(
              land: land,
              onTap: () => context.read<LandBloc>().add(NavigateToLandDetails(land: land)),
              onSpeak: () {
                final description = land.description ?? 'No description available';
                final price = land.priceland != null ? '${land.priceland} DT' : 'Price not available';
                _speak('Land: ${land.title}. Location: ${land.location}. Price: $price. Description: $description');
              },
              onStopSpeaking: _stopSpeaking,
            ),
          );
        },
      ),
    );
  }
}