import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user.dart';
import '../bloc/login_bloc.dart';
import 'login_screen.dart';
import '../models/land_model.dart';
import '../widgets/land_card.dart';
import '../widgets/filter_bar.dart';

class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  LandType? _selectedType;
  LandStatus? _selectedStatus;
  String _searchQuery = '';
  bool _isLoading = false;
  List<Land> _lands = [];

  @override
  void initState() {
    super.initState();
    _loadLands();
  }

  Future<void> _loadLands() async {
    setState(() => _isLoading = true);
    try {
      await Future.delayed(const Duration(seconds: 1));
      _lands = [
        Land(
          id: '1',
          title: 'Terrain Agricole Fertile',
          description: 'Magnifique terrain agricole avec irrigation',
          location: 'Tunis Nord',
          type: LandType.AGRICULTURAL,
          status: LandStatus.APPROVED,
          price: 150000,
          imageUrl: 'https://example.com/land1.jpg',
          createdAt: DateTime.now(),
        ),
        Land(
          id: '2',
          title: 'Terrain Urbain Premium',
          description: 'Excellent emplacement pour projet immobilier',
          location: 'Tunis Centre',
          type: LandType.URBAN,
          status: LandStatus.PENDING,
          price: 250000,
          imageUrl: 'https://example.com/land2.jpg',
          createdAt: DateTime.now(),
        ),
      ];
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de chargement: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<Land> get filteredLands {
    return _lands.where((land) {
      final matchesType = _selectedType == null || land.type == _selectedType;
      final matchesStatus = _selectedStatus == null || land.status == _selectedStatus;
      final matchesSearch = _searchQuery.isEmpty ||
          land.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          land.location.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesType && matchesStatus && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bienvenue, ${widget.user.username}"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()), // Suppression du const ici
              );
            },
          ),
        ],
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blue,
                  child: Text(
                    widget.user.username[0].toUpperCase(),
                    style: const TextStyle(fontSize: 24, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Email: ${widget.user.email}",
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                      Text(
                        "Rôle: ${widget.user.role}",
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadLands,
              child: Column(
                children: [
                  FilterBar(
                    onTypeChanged: (type) => setState(() => _selectedType = type),
                    onStatusChanged: (status) => setState(() => _selectedStatus = status),
                    onSearchChanged: (query) => setState(() => _searchQuery = query),
                    selectedType: _selectedType,
                    selectedStatus: _selectedStatus,
                  ),
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _buildLandGrid(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLandGrid() {
    if (filteredLands.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Aucun terrain trouvé',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: filteredLands.length,
      itemBuilder: (context, index) {
        return LandCard(
          land: filteredLands[index],
          onTap: () {
          },
        );
      },
    );
  }
}