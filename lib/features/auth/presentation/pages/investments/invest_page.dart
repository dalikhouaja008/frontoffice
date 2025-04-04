import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:the_boost/core/constants/colors.dart';
import 'package:the_boost/core/constants/dimensions.dart';
import 'package:the_boost/core/constants/text_styles.dart';
import 'package:the_boost/features/auth/data/models/land_model.dart';
import 'package:the_boost/features/auth/domain/repositories/land_repository.dart';
import 'package:the_boost/features/auth/presentation/bloc/lands/land_bloc.dart';
import 'package:the_boost/features/auth/presentation/pages/land_detail_screen.dart';
import 'package:the_boost/features/auth/presentation/widgets/app_nav_bar.dart';
import 'package:the_boost/features/auth/presentation/widgets/catalogue/land_card.dart';
import 'package:the_boost/features/auth/presentation/widgets/invest_filters.dart';

class InvestPage extends StatefulWidget {
  const InvestPage({Key? key}) : super(key: key);

  @override
  State<InvestPage> createState() => _InvestPageState();
}

class _InvestPageState extends State<InvestPage> {
  late final LandBloc _landBloc;

  @override
  void initState() {
    super.initState();
    _landBloc = LandBloc(GetIt.I<LandRepository>());
    _landBloc.add(LoadLands());
  }

  void _navigateToLandDetails(BuildContext context, Land land) {
    print('Attempting to navigate to details for: ${land.title}');
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: _landBloc,
          child: LandDetailsScreen(land: land),
        ),
      ),
    ).then((_) => print('Returned from details page'));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _landBloc,
      child: Scaffold(
        body: BlocListener<LandBloc, LandState>(
          listener: (context, state) {
            if (state is LandError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: Column(
            children: [
              const AppNavBar(
                currentRoute: '/invest',
              ),
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 250,
                      color: AppColors.backgroundLight,
                      child: BlocProvider.value(
                        value: _landBloc,
                        child: InvestFilters(
                          onFiltersChanged: (filters) {
                            // Cette méthode n'est plus nécessaire
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: BlocConsumer<LandBloc, LandState>(
                        listener: (context, state) {
                          if (state is LandError) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(state.message)),
                            );
                          } else if (state is NavigatingToLandDetails) {
                            _navigateToLandDetails(context, state.land);
                          }
                        },
                        builder: (context, state) {
                          if (state is LandLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (state is LandLoaded) {
                            return _buildLandGrid(context, state.lands);
                          } else if (state is LandError) {
                            return Center(child: Text(state.message));
                          } else {
                            return const Center(
                              child: Text('No lands available'),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLandGrid(BuildContext context, List<Land> lands) {
    if (lands.isEmpty) {
      return const Center(child: Text('No lands available'));
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
              print('Card tapped for land: ${land.title}');
              _landBloc.add(NavigateToLandDetails(land));
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _landBloc.close();
    super.dispose();
  }
}