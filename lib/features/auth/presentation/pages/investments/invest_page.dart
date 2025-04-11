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

class InvestPage extends StatelessWidget {
  const InvestPage({Key? key}) : super(key: key);

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
        ),
        body: Column(
          children: [
            const AppNavBar(currentRoute: '/invest'),
            InvestFilters(
              onFiltersChanged: (filters) {
                print('[${DateTime.now()}] InvestPage: Filters changed: $filters');
              },
            ),
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