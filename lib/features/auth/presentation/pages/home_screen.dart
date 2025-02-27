import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:the_boost/constants.dart';
import 'package:the_boost/features/auth/data/static_lands.dart';
import 'package:the_boost/features/auth/presentation/pages/landing_page.dart';
import 'package:the_boost/features/auth/presentation/pages/terrain_detail_screen.dart';
import '../../domain/entities/user.dart';
import '../bloc/login_bloc.dart';
import 'login_screen.dart';
import '../models/land_model.dart' show Land, LandStatus, LandType;
import '../widgets/land_card.dart';
import '../widgets/filter_bar.dart';

class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({Key? key, required this.user}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  LandType? _selectedType;
  LandStatus? _selectedStatus;
  String _searchQuery = '';
  bool _isLoading = false;
  List<Land> _lands = [];
  int selectedIndex = 0;
  String currentDateTime = '';

  List<Land> get filteredLands {
    return _lands.where((land) {
      final matchesType = _selectedType == null || land.type == _selectedType;
      final matchesStatus = _selectedStatus == null || land.status == _selectedStatus;
      final matchesQuery = _searchQuery.isEmpty || 
          land.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesType && matchesStatus && matchesQuery;
    }).toList();
  }

  final List<String> menuItems = [
    "Accueil",
    "Nos Terrains", 
    "Services", 
    "À Propos", 
    "Contact"
  ];

  @override
  void initState() {
    super.initState();
    _loadLands();
    _startTimeUpdate();
  }

  void _startTimeUpdate() {
    _updateDateTime();
    Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateDateTime();
    });
  }

  void _updateDateTime() {
    setState(() {
      currentDateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now().toUtc());
    });
  }

  Widget buildWebNavigation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: menuItems.map((item) => 
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: TextButton(
            onPressed: () {
              setState(() {
                selectedIndex = menuItems.indexOf(item);
              });
            },
            child: Text(
              item,
              style: TextStyle(
                fontSize: 16,
                fontWeight: selectedIndex == menuItems.indexOf(item) 
                    ? FontWeight.bold 
                    : FontWeight.normal,
                color: selectedIndex == menuItems.indexOf(item) 
                    ? kPrimaryColor 
                    : kTextLightColor,
              ),
            ),
          ),
        ),
      ).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [kDefaultShadow],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Text(
                    "The Boost",
                    style: TextStyle(
                      color: kPrimaryColor,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: buildWebNavigation(),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: kPrimaryColor,
                        child: Text(
                          widget.user.username[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.user.username,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: kTextColor,
                            ),
                          ),
                          Text(
                            widget.user.role,
                            style: const TextStyle(
                              fontSize: 12,
                              color: kTextColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.logout_rounded),
                  color: kTextLightColor,
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LandingPage()),
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  margin: const EdgeInsets.all(kDefaultPadding),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [kDefaultShadow],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(kDefaultPadding),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [kDefaultShadow],
                        ),
                        child: FilterBar(
                          onTypeChanged: (type) => setState(() => _selectedType = type),
                          onStatusChanged: (status) => setState(() => _selectedStatus = status),
                          onSearchChanged: (query) => setState(() => _searchQuery = query),
                          selectedType: _selectedType,
                          selectedStatus: _selectedStatus,
                        ),
                      ),
                      Expanded(
                        child: _isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: kPrimaryColor,
                                ),
                              )
                            : _buildLandGrid(filteredLands, constraints),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, -2),
                  blurRadius: 10,
                  color: Colors.black.withOpacity(0.05),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'The Boost',
                            style: TextStyle(
                              color: kPrimaryColor,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Dernière mise à jour: $currentDateTime',
                            style: TextStyle(
                              color: kTextColor.withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Suivez-nous',
                            style: TextStyle(
                              color: kTextColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _buildSocialIcon(FontAwesomeIcons.facebook, () {}),
                              const SizedBox(width: 12),
                              _buildSocialIcon(FontAwesomeIcons.linkedin, () {}),
                              const SizedBox(width: 12),
                              _buildSocialIcon(FontAwesomeIcons.twitter, () {}),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  '© ${DateTime.now().year} The Boost. Tous droits réservés',
                  style: TextStyle(
                    color: kTextColor.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLandGrid(List<Land> lands, BoxConstraints constraints) {
    if (lands.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: kTextLightColor.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun terrain trouvé',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: kTextLightColor,
                  ),
            ),
          ],
        ),
      );
    }

    final double itemWidth = 300.0;
    final int crossAxisCount = (constraints.maxWidth / itemWidth).floor();

    return GridView.builder(
      padding: const EdgeInsets.all(kDefaultPadding),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount.clamp(1, 4),
        childAspectRatio: 0.85,
        crossAxisSpacing: kDefaultPadding,
        mainAxisSpacing: kDefaultPadding,
      ),
      itemCount: lands.length,
      itemBuilder: (context, index) {
        return LandCard(
          land: lands[index],
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TerrainDetailPage(land: lands[index]),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _loadLands() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Future.delayed(const Duration(seconds: 1));
      final lands = StaticLandsData.getLands();
      setState(() {
        _lands = lands;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Erreur lors du chargement des terrains: $e');
    }
  }

  Widget _buildSocialIcon(IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Icon(
        icon,
        color: kTextColor,
        size: 24,
      ),
    );
  }
}

class MenuItemData {
  final String title;
  final IconData icon;

  MenuItemData({required this.title, required this.icon});
}