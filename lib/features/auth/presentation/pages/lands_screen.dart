// lib/features/auth/presentation/pages/lands_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:the_boost/core/di/dependency_injection.dart';
import 'package:the_boost/features/auth/data/models/land_model.dart';
import 'package:the_boost/features/auth/presentation/bloc/lands/land_bloc.dart';
import 'package:the_boost/features/auth/presentation/pages/land_detail_screen.dart';
import 'package:the_boost/features/auth/presentation/widgets/catalogue/land_card.dart';

class LandsScreen extends StatefulWidget {
  const LandsScreen({Key? key}) : super(key: key);

  @override
  _LandsScreenState createState() => _LandsScreenState();
}

class _LandsScreenState extends State<LandsScreen> {
  final FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _initTts();
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

  @override
  void dispose() {
    _stopSpeaking();
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
        appBar: AppBar(
          title: const Text('Terrains disponibles'),
          elevation: 0,
        ),
        body: BlocBuilder<LandBloc, LandState>(
          builder: (context, state) {
            print('[${DateTime.now()}] LandsScreen: BlocBuilder state: $state');
            if (state is LandLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is LandLoaded) {
                final lands = state.lands.where((land) => land.availability == 'AVAILABLE').toList();
                print('[${DateTime.now()}] LandsScreen: Loaded ${lands.length} available lands');
                if (lands.isEmpty) {
                  return const Center(child: Text('Aucun terrain disponible'));
                }
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<LandBloc>().add(LoadLands());
                },
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: lands.length,
                      itemBuilder: (context, index) {
                        final land = lands[index];
                        return LandCard(
                          land: land,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => LandDetailsScreen(land: land),
                              ),
                            );
                          },
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
                    ),
                  ),
                ),
              );
            } else if (state is LandError) {
              print('[${DateTime.now()}] LandsScreen: LandError: ${state.message}');
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Erreur lors du chargement des terrains: ${state.message}'),
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
    );
  }
}