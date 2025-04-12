// lib/features/auth/presentation/pages/investments/invest_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

class _InvestPageState extends State<InvestPage> {
  List<Land> _filteredLands = [];
  List<Land> _allLands = [];

  void _applyFilters(Map<String, dynamic> filters) {
    setState(() {
      _filteredLands = _allLands.where((land) {
        // Price Range Filter
        double landPrice = land.totalPrice;
        if (filters['priceRange'] != null) {
          double minPrice = filters['priceRange']['min'];
          double maxPrice = filters['priceRange']['max'];
          if (landPrice < minPrice || landPrice > maxPrice) return false;
        }

        // Land Type Filter
        if (filters['landType'] != null && filters['landType'] != land.landtype.name) {
          return false;
        }

        // Validation Status Filter
        if (filters['validationStatus'] != null && filters['validationStatus'] != land.status.name) {
          return false;
        }

        // Amenities Filter
        if (filters['amenities'] != null) {
          Map<String, bool> selectedAmenities = filters['amenities'];
          for (var entry in selectedAmenities.entries) {
            if (entry.value && (land.amenities[entry.key] != true)) {
              return false;
            }
          }
        }

        return true;
      }).toList();

      // Sort By Filter
      if (filters['sortBy'] != null) {
        switch (filters['sortBy']) {
          case 'price_asc':
            _filteredLands.sort((a, b) => a.totalPrice.compareTo(b.totalPrice));
            break;
          case 'price_desc':
            _filteredLands.sort((a, b) => b.totalPrice.compareTo(a.totalPrice));
            break;
          case 'title_asc':
            _filteredLands.sort((a, b) => a.title.compareTo(b.title));
            break;
          case 'title_desc':
            _filteredLands.sort((a, b) => b.title.compareTo(a.title));
            break;
        }
      }
    });
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
        
        body: Column(
          children: [
            const AppNavBar(currentRoute: '/invest'),
            Expanded(
              child: Row(
                children: [
                  // Sidebar with Filters
                  InvestFilters(
                    onFiltersChanged: _applyFilters,
                    onClose: () {}, // No-op since it's not a drawer
                  ),
                  // Main Content (Lands Grid)
                  Expanded(
                    child: BlocListener<LandBloc, LandState>(
                      listener: (context, state) {
                        print('[${DateTime.now()}] InvestPage: BlocListener - State: $state');
                        if (state is LandError) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: ${state.message}'),
                              backgroundColor: Colors.red,
                              duration: const Duration(seconds: 5),
                            ),
                          );
                        } else if (state is NavigatingToLandDetails) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => LandDetailsScreen(land: state.land),
                            ),
                          );
                        } else if (state is LandLoaded) {
                          setState(() {
                            _allLands = state.lands;
                            _filteredLands = state.lands;
                          });
                        }
                      },
                      child: BlocBuilder<LandBloc, LandState>(
                        builder: (context, state) {
                          print('[${DateTime.now()}] InvestPage: BlocBuilder - State: $state');
                          if (state is LandLoading) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (state is LandLoaded) {
                            print('[${DateTime.now()}] InvestPage: Lands loaded: ${state.lands.length}');
                            return _buildLandGrid(context, _filteredLands);
                          } else if (state is LandError) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Failed to load lands',
                                    style: TextStyle(color: Colors.red, fontSize: 18),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    state.message,
                                    style: const TextStyle(color: Colors.black54, fontSize: 14),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () {
                                      context.read<LandBloc>().add(LoadLands());
                                    },
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
      ),
    );
  }

  Widget _buildLandGrid(BuildContext context, List<Land> lands) {
    if (lands.isEmpty) {
      return const Center(
        child: Text(
          'No lands available after filtering',
          style: TextStyle(color: Colors.black, fontSize: 18),
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
          return LandCard(
            land: land,
            onTap: () {
              print('[${DateTime.now()}] InvestPage: Navigating to land details: ${land.id}');
              context.read<LandBloc>().add(NavigateToLandDetails(land));
            },
          );
        },
      ),
    );
  }
}