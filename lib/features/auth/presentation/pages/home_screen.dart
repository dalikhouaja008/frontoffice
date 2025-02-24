import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:the_boost/constants.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:the_boost/features/auth/data/static_lands.dart';
import 'package:the_boost/features/auth/presentation/pages/landing_page.dart';
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
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
  LandType? _selectedType;
  LandStatus? _selectedStatus;
  String _searchQuery = '';
  bool _isLoading = false;
  List<Land> _lands = [];
  int selectedIndex = 0;
  int hoverIndex = 0;
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

  final List<MenuItemData> menuItems = [
    MenuItemData(title: "Accueil", icon: Icons.home_rounded),
    MenuItemData(title: "Terrains", icon: Icons.landscape_rounded),
    MenuItemData(title: "Favoris", icon: Icons.favorite_rounded),
    MenuItemData(title: "Messages", icon: Icons.message_rounded),
    //MenuItemData(title: "Profile", icon: Icons.person_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _loadLands();
    _startTimeUpdate();

  }

  void _startTimeUpdate() {
    // Mise à jour initiale
    _updateDateTime();
    // Mise à jour toutes les secondes
    Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateDateTime();
    });
  }

  void _updateDateTime() {
    setState(() {
      currentDateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now().toUtc());
    });
  }

  Widget buildMenuItem(int index) {
    final item = menuItems[index];
    final isSelected = selectedIndex == index;
    final isHovered = hoverIndex == index;

    return Flexible(
      child: InkWell(
        onTap: () {
          setState(() {
            selectedIndex = index;
          });
        },
        onHover: (value) {
          setState(() {
            hoverIndex = value ? index : selectedIndex;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          constraints: const BoxConstraints(minWidth: 80),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                item.icon,
                color: isSelected ? kPrimaryColor : kTextLightColor,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                item.title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? kPrimaryColor : kTextLightColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              if (isSelected || isHovered)
                Container(
                  height: 3,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: kPrimaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
            ],
          ),
        ),
      ),
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
              // Logo
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.3),
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
              // Menu Items
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: menuItems.map((item) => 
                    buildMenuItem(menuItems.indexOf(item))
                  ).toList(),
                ),
              ),
              // Profile Section
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
                            color: kTextColor, // Use your desired text color here
                          ),
                        ),
                        Text(
                          widget.user.role,
                          style: const TextStyle(
                            fontSize: 12,
                            color: kTextColor, // Use your desired text color here
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
        
        // Content Section
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
                    // FilterBar
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
                    // Grid Content
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

        // Footer (Nouveau)
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
                  // Company Info
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
                  // Quick Links
                  Expanded(
                    flex: 3,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      
                    ),
                  ),
                  // Social Media
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
              // Copyright
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

    // Calculate the optimal number of columns based on available width
    final double itemWidth = 300.0; // Minimum width for each item
    final int crossAxisCount = (constraints.maxWidth / itemWidth).floor();

    return GridView.builder(
      padding: const EdgeInsets.all(kDefaultPadding),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount.clamp(1, 4), // Ensure at least 1 column and max 4
        childAspectRatio: 0.85,
        crossAxisSpacing: kDefaultPadding,
        mainAxisSpacing: kDefaultPadding,
      ),
      itemCount: lands.length,
      itemBuilder: (context, index) {
        return LandCard(
          land: lands[index],
          onTap: () {},
        );
      },
    );
  }

  Future<void> _loadLands() async {
  setState(() {
    _isLoading = true;
  });

  try {
    // Simuler un délai de chargement
    await Future.delayed(const Duration(seconds: 1));
    
    // Charger les terrains depuis StaticLandsData
    final lands = StaticLandsData.getLands();
    
    setState(() {
      _lands = lands;
      _isLoading = false;
    });
  } catch (e) {
    setState(() {
      _isLoading = false;
    });
    // Gérer l'erreur si nécessaire
    print('Erreur lors du chargement des terrains: $e');
  }
}
}

class MenuItemData {
  final String title;
  final IconData icon;

  MenuItemData({required this.title, required this.icon});
}