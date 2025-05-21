import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_boost/core/constants/colors.dart';
import 'package:the_boost/features/auth/presentation/bloc/routes.dart';
import 'package:the_boost/features/auth/presentation/widgets/app_nav_bar.dart';
import 'package:the_boost/features/land/domain/entities/land.dart';
import 'package:the_boost/features/land/presentation/bloc/my_lands/my_lands_bloc.dart';
import 'package:the_boost/features/land/presentation/widgets/land_card.dart';

class MyLandsPage extends StatelessWidget {
  const MyLandsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: AppNavBar(
          currentRoute: '/my-lands',
        ),
      ),
      body: BlocBuilder<MyLandsBloc, MyLandsState>(
        builder: (context, state) {
          if (state is MyLandsInitial) {
            context.read<MyLandsBloc>().add(LoadMyLands());
            return const Center(child: CircularProgressIndicator());
          }

          if (state is MyLandsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is MyLandsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Une erreur est survenue',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<MyLandsBloc>().add(LoadMyLands());
                    },
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          if (state is MyLandsLoaded) {
            if (state.lands.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.landscape,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Vous n\'avez pas encore de terrains',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Commencez par enregistrer votre premier terrain',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                         Navigator.pushNamed(context, AppRoutes.landValuation);
                      },
                      child: const Text('Enregistrer un terrain'),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.lands.length,
              itemBuilder: (context, index) {
                final land = state.lands[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: LandCard(land: land),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
