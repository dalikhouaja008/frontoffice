import 'package:flutter/material.dart';
import 'package:the_boost/core/services/land_service.dart';
import 'package:the_boost/features/auth/data/models/land_model.dart';

class LandsScreen extends StatefulWidget {
  const LandsScreen({Key? key}) : super(key: key);

  @override
  State<LandsScreen> createState() => _LandsScreenState();
}

class _LandsScreenState extends State<LandsScreen> {
  final LandService landService = LandService();
  List<Land> lands = [];
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchLands();
  }

  Future<void> fetchLands() async {
    try {
      final fetchedLands = await landService.fetchLands();
      setState(() {
        lands = fetchedLands;
        errorMessage = null; // Clear any previous error
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching lands: $e';
      });
      print('Error fetching lands: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Lands')),
      body: errorMessage != null
          ? Center(child: Text(errorMessage!))
          : lands.isEmpty
              ? Center(child: Text('No lands available'))
              : ListView.builder(
                  itemCount: lands.length,
                  itemBuilder: (context, index) {
                    final land = lands[index];
                    return ListTile(
                      title: Text(land.title),
                      subtitle: Text(land.location),
                    );
                  },
                ),
    );
  }
}