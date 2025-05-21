import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_boost/core/constants/colors.dart';
import 'package:the_boost/core/constants/dimensions.dart';
import 'package:the_boost/features/auth/presentation/pages/land/domain/entities/land.dart';
import 'package:the_boost/features/auth/presentation/pages/land/presentation/bloc/my_lands/my_lands_bloc.dart';
import 'package:the_boost/features/auth/presentation/pages/land/presentation/widgets/land_card.dart';

class MyLandsPage extends StatelessWidget {
  const MyLandsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Terrains'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
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
                    'Erreur: ${state.message}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: AppDimensions.paddingM),
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
              return const Center(
                child: Text(
                  'Vous n\'avez pas encore de terrains enregistrés',
                  style: TextStyle(fontSize: 16),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<MyLandsBloc>().add(LoadMyLands());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                itemCount: state.lands.length,
                itemBuilder: (context, index) {
                  final land = state.lands[index];
                  return Padding(
                    padding:
                        const EdgeInsets.only(bottom: AppDimensions.paddingM),
                    child: LandCard(land: land),
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add new land page
          // Navigator.pushNamed(context, '/add-land');
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
