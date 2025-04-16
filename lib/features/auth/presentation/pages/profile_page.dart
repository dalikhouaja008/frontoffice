// lib/features/auth/presentation/pages/profile/profile_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_boost/core/constants/colors.dart';
import 'package:the_boost/core/constants/dimensions.dart';
import 'package:the_boost/features/auth/data/models/land_model.dart';
import 'package:the_boost/features/auth/presentation/bloc/lands/land_bloc.dart';
import 'package:the_boost/features/auth/presentation/bloc/login/login_bloc.dart';
import 'package:the_boost/features/auth/presentation/bloc/login/login_state.dart';
import 'package:the_boost/features/auth/presentation/widgets/app_nav_bar.dart';
import 'package:the_boost/features/auth/presentation/widgets/catalogue/land_card.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load lands when the page is initialized
    context.read<LandBloc>().add(LoadLands());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, loginState) {
        if (loginState is! LoginSuccess) {
          return const Center(child: Text('Please log in to view your profile.'));
        }
        final userId = loginState.user.id;
        print('[2025-04-16 10:15:23] ProfilePage: 🔄 Building profile for user: $userId');

        return Scaffold(
          appBar: AppBar(
            title: const Text('My Profile'),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          body: Column(
            children: [
              const AppNavBar(currentRoute: '/profile'),
              Expanded(
                child: BlocBuilder<LandBloc, LandState>(
                  builder: (context, state) {
                    if (state is LandLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is LandLoaded) {
                      final userLands = state.lands.where((land) => land.ownerId == userId).toList();
                      print('[2025-04-16 10:15:23] ProfilePage: ✅ Loaded ${userLands.length} lands for user $userId');
                      return _buildLandGrid(context, userLands);
                    } else if (state is LandError) {
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
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLandGrid(BuildContext context, List<Land> lands) {
    if (lands.isEmpty) {
      return const Center(
        child: Text(
          'No lands added by you',
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
              print('[2025-04-16 10:15:23] ProfilePage: Navigating to land details: ${land.id}');
              context.read<LandBloc>().add(NavigateToLandDetails(land: land));
            },
            onSpeak: () {
              final description = land.description ?? 'No description available';
              final price = land.totalPrice != null ? '${land.totalPrice} DT' : 'Price not available';
              // Note: Assuming LandBloc has speak and stopSpeaking methods; adjust if needed
              context.read<LandBloc>().speak('Land: ${land.title}. Location: ${land.location}. Price: $price. Description: $description');
            },
            onStopSpeaking: () => context.read<LandBloc>().stopSpeaking(),
          );
        },
      ),
    );
  }
}