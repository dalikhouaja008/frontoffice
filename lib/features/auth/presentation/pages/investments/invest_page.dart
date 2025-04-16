// lib/features/auth/presentation/pages/investments/invest_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:the_boost/core/constants/colors.dart';
import 'package:the_boost/core/constants/dimensions.dart';
import 'package:the_boost/core/di/dependency_injection.dart';
import 'package:the_boost/features/auth/data/models/land_model.dart';
import 'package:the_boost/features/auth/presentation/bloc/lands/land_bloc.dart';
import 'package:the_boost/features/auth/presentation/pages/land_detail_screen.dart';
import 'package:the_boost/features/auth/presentation/widgets/app_nav_bar.dart';
import 'package:the_boost/features/auth/presentation/widgets/catalogue/land_card.dart';
import 'package:the_boost/features/auth/presentation/widgets/invest_filters.dart';

class InvestPage extends StatefulWidget {
  const InvestPage({Key? key}) : super(key: key);

  @override
  _InvestPageState createState() => _InvestPageState();
}

class _InvestPageState extends State<InvestPage> with SingleTickerProviderStateMixin {
  bool _isSidebarOpen = false;
  final FlutterTts _flutterTts = FlutterTts();
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _initTts();
    // Initialize animation controller for sidebar
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }

  Future<void> _stopSpeaking() async {
    await _flutterTts.stop();
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarOpen = !_isSidebarOpen;
      if (_isSidebarOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _stopSpeaking();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('[${DateTime.now()}] InvestPage: 🔄 Building InvestPage');
    return BlocProvider(
      create: (context) {
        print('[${DateTime.now()}] InvestPage: 🚀 Creating LandBloc');
        final bloc = getIt<LandBloc>();
        print('[${DateTime.now()}] InvestPage: 🚀 Adding LoadLands event');
        bloc.add(LoadLands());
        return bloc;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Invest'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: Icon(_isSidebarOpen ? Icons.close : Icons.filter_list),
              onPressed: _toggleSidebar,
              tooltip: 'Toggle Filters',
            ),
          ],
        ),
        body: Stack(
          children: [
            Column(
              children: [
                const AppNavBar(currentRoute: '/invest'),
                Expanded(
                  child: BlocListener<LandBloc, LandState>(
                    listener: (context, state) {
                      print('[${DateTime.now()}] InvestPage: BlocListener - State: $state');
                      if (state is LandError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: ${state.message}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } else if (state is NavigatingToLandDetails) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => LandDetailsScreen(land: state.land),
                          ),
                        );
                      }
                    },
                    child: BlocBuilder<LandBloc, LandState>(
                      builder: (context, state) {
                        print('[${DateTime.now()}] InvestPage: BlocBuilder - State: $state');
                        if (state is LandLoading) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (state is LandLoaded) {
                          print('[${DateTime.now()}] InvestPage: Lands loaded: ${state.lands.length}');
                          return _buildLandGrid(context, state.lands);
                        } else if (state is LandError) {
                          return const Center(
                            child: Text(
                              'Failed to load lands',
                              style: TextStyle(color: Colors.red, fontSize: 18),
                              semanticsLabel: 'Failed to load lands',
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
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Positioned(
                  left: _isSidebarOpen ? 0 : -MediaQuery.of(context).size.width * 0.75,
                  top: 0,
                  bottom: 0,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.75, // Responsive width
                    child: child!,
                  ),
                );
              },
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
                        availability: filters['availability'] as String?, // Added availability
                        amenities: (filters['amenities'] as Map<String, bool>?)?.cast<String, bool>(),
                      ));
                },
                onClose: _toggleSidebar,
              ),
            ),
          ],
        ),
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
            label: 'Land: ${land.title}, Location: ${land.location}, Price: ${land.totalPrice ?? 'N/A'} DT',
            child: LandCard(
              land: land,
              onTap: () {
                print('[${DateTime.now()}] InvestPage: Navigating to land details: ${land.id}');
                context.read<LandBloc>().add(NavigateToLandDetails(land: land));
              },
              onSpeak: () {
                final description = land.description ?? 'No description available';
                final price = land.totalPrice != null ? '${land.totalPrice} DT' : 'Price not available';
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