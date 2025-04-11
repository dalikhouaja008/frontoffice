import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:the_boost/core/services/land_service.dart';
import 'package:the_boost/features/auth/data/models/land_model.dart';
import 'package:the_boost/features/auth/presentation/pages/land_detail_screen.dart';
import 'package:the_boost/features/auth/presentation/widgets/catalogue/land_card.dart';

class LandsScreen extends StatefulWidget {
  const LandsScreen({Key? key}) : super(key: key);

  @override
  State<LandsScreen> createState() => _LandsScreenState();
}

class _LandsScreenState extends State<LandsScreen> {
  late final LandService _landService;
  List<Land> lands = [];
  String? errorMessage;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _landService = GetIt.I<LandService>();
    fetchLands();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terrains disponibles'),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: fetchLands,
        child: isLoading 
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
            ? Center(child: Text(errorMessage!))
            : lands.isEmpty
              ? const Center(child: Text('Aucun terrain disponible'))
              : SingleChildScrollView(
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
                          onTap: () => _navigateToDetails(land),
                        );
                      },
                    ),
                  ),
                ),
      ),
    );
  }

  Future<void> fetchLands() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
      
      final fetchedLands = await _landService.fetchLands();
      setState(() {
        lands = fetchedLands;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Erreur lors du chargement des terrains: $e';
        isLoading = false;
      });
      print('Error fetching lands: $e');
    }
  }

  void _navigateToDetails(Land land) {
    print('Navigating to details for land: ${land.title}');
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LandDetailsScreen(land: land),
      ),
    );
  }
}