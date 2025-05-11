import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:the_boost/core/constants/colors.dart';
import 'package:the_boost/core/constants/dimensions.dart';
import 'package:the_boost/features/auth/data/models/land_model.dart';
import 'package:the_boost/features/auth/presentation/bloc/lands/land_bloc.dart';
import 'package:the_boost/features/auth/presentation/bloc/login/login_bloc.dart';
import 'package:the_boost/features/auth/presentation/bloc/login/login_state.dart';
import 'package:the_boost/features/auth/presentation/pages/investments/land_detail_screen.dart';
import 'package:the_boost/features/auth/presentation/widgets/app_nav_bar.dart';
import 'package:the_boost/features/auth/presentation/widgets/catalogue/land_card.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _initTtsAsync(); // Async TTS initialization
    // Delay land loading until widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LandBloc>().add(LoadLands());
    });
  }

  Future<void> _initTtsAsync() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(1.0);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.2); // Slightly higher pitch for clarity
  }

  Future<void> _speak(String text) async {
    await _flutterTts.stop(); // Stop any ongoing speech
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
    return BlocBuilder<LoginBloc, LoginState>(
      buildWhen: (previous, current) => current is LoginSuccess, // Rebuild only on login success
      builder: (context, loginState) {
        if (loginState is! LoginSuccess) {
          return const Center(child: Text('Please log in to view your profile.'));
        }
        final userId = loginState.user.id;

        return const Scaffold(
          body: Column(
            children: [
              AppNavBar(currentRoute: '/profile'),
              Expanded(
                child: _LandGrid(), // Extracted for better separation
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LandGrid extends StatelessWidget {
  const _LandGrid();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LandBloc, LandState>(
      buildWhen: (previous, current) => current is LandLoading || current is LandLoaded || current is LandError,
      builder: (context, state) {
        final loginState = context.read<LoginBloc>().state;
        if (loginState is! LoginSuccess) return const SizedBox.shrink(); // Safety check
        final userId = loginState.user.id;

        if (state is LandLoading) return const Center(child: CircularProgressIndicator());
        if (state is LandLoaded) {
          final userLands = state.lands.where((land) => land.ownerId == userId).toList();
          return _buildLandGridContent(context, userLands);
        }
        if (state is LandError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Failed to load lands: ${state.message}', style: const TextStyle(color: Colors.red, fontSize: 18)),
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
    );
  }

  Widget _buildLandGridContent(BuildContext context, List<Land> lands) {
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
            onTap: () => context.read<LandBloc>().add(NavigateToLandDetails(land: land)),
            onSpeak: () {
              final description = land.description ?? 'No description available';
              final price = land.priceland != null ? '${land.priceland} DT' : 'Price not available';
              final state = context.findAncestorStateOfType<_ProfilePageState>()!;
              state._speak('Land: ${land.title}. Location: ${land.location}. Price: $price. Description: $description');
            },
            onStopSpeaking: () {
              final state = context.findAncestorStateOfType<_ProfilePageState>()!;
              state._stopSpeaking();
            },
          );
        },
      ),
    );
  }
}