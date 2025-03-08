import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_boost/features/auth/presentation/widgets/catalogue/land_card.dart';
import '../bloc/land_bloc.dart';

class InvestmentPage extends StatelessWidget {
  const InvestmentPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Investissements'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<LandBloc>().add(LoadLandsEvent()),
          ),
        ],
      ),
      body: BlocBuilder<LandBloc, LandState>(
        builder: (context, state) {
          if (state is LandLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is LandErrorState) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<LandBloc>().add(LoadLandsEvent()),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          if (state is LandLoadedState) {
            if (state.lands.isEmpty) {
              return const Center(
                child: Text('Aucun terrain disponible'),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<LandBloc>().add(LoadLandsEvent());
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = (constraints.maxWidth / 300).floor();
                    crossAxisCount = crossAxisCount < 1 ? 1 : crossAxisCount;
                    
                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: 0.8,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: state.lands.length,
                      itemBuilder: (context, index) {
                        return LandCard(
                          land: state.lands[index],
                          onTap: () {
                            // Navigation vers les détails
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            );
          }

          return const Center(
            child: Text('État inconnu'),
          );
        },
      ),
    );
  }
}