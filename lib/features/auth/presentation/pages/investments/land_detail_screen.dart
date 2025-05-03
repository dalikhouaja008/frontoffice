import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:the_boost/core/constants/colors.dart';
import 'package:the_boost/core/di/dependency_injection.dart';
import 'package:the_boost/core/services/land_service.dart';
import 'package:the_boost/features/auth/data/models/land_model.dart';
import 'package:the_boost/features/auth/presentation/bloc/tokenization/tokenization_bloc.dart';
import 'package:the_boost/features/auth/presentation/pages/investments/widgets/land_amenities_widget.dart';
import 'package:the_boost/features/auth/presentation/pages/investments/widgets/land_general_info_widget.dart';
import 'package:the_boost/features/auth/presentation/pages/investments/widgets/land_images_widget.dart';
import 'package:the_boost/features/auth/presentation/pages/investments/widgets/land_tokenization_widget.dart';
import 'package:the_boost/features/auth/presentation/pages/investments/widgets/land_validation_widget.dart';
import 'package:the_boost/features/auth/presentation/widgets/app_nav_bar.dart';

class LandDetailsScreen extends StatefulWidget {
  final String? landId;
  final Land? land;
  final String? networkName;

  const LandDetailsScreen({
    super.key,
    this.land,
    this.landId,
    this.networkName = "ethereum",
  });

  @override
  State<LandDetailsScreen> createState() => _LandDetailsScreenState();
}

class _LandDetailsScreenState extends State<LandDetailsScreen>
    with SingleTickerProviderStateMixin {
  Land? _land;
  bool _isLoading = true;
  String? _error;
  final ScrollController _scrollController = ScrollController();

  // Déclarer TabController pour le TabBar
  late TabController _tabController;

  // Liste des tabs pour organiser le contenu
  final List<String> _tabs = [
    'Overview',
    'Tokenization',
    'Features',
    'Validation'
  ];

  @override
  void initState() {
    super.initState();
    // Initialiser le TabController
    _tabController = TabController(length: _tabs.length, vsync: this);
    _loadLand();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose(); // Libérer les ressources du TabController
    super.dispose();
  }

  Future<void> _loadLand() async {
    if (widget.land != null) {
      setState(() {
        _land = widget.land;
        _isLoading = false;
      });
      return;
    }

    if (widget.landId == null) {
      setState(() {
        _error = 'No land ID provided';
        _isLoading = false;
      });
      return;
    }

    try {
      final landService = getIt<LandService>();
      final land = await landService.fetchLandById(widget.landId!);
      if (land == null) {
        setState(() {
          _error = 'Land not found';
          _isLoading = false;
        });
      } else {
        setState(() {
          _land = land;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load land: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingScreen();
    }

    if (_error != null) {
      return _buildErrorScreen();
    }

    return Scaffold(
      body: _land == null
          ? const Center(child: Text('No Land Selected'))
          : BlocProvider(
              create: (context) => TokenizationBloc(),
              child: Column(
                children: [
                  const AppNavBar(currentRoute: '/land-details'),
                  _buildHeader(),
                  _buildTabBar(),
                  // Expanded pour éviter le débordement
                  Expanded(
                    child: _buildTabContent(),
                  ),
                  _buildActionButtons(),
                ],
              ),
            ),
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            const SizedBox(height: 20),
            Text(
              'Loading land details...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red[300],
            ),
            const SizedBox(height: 20),
            Text(
              _error!,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                _loadLand();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      color: AppColors.backgroundLight,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  _land!.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(_land!.status),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _land!.status,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                _land!.location,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.straighten, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                '${_land!.surface ?? 'N/A'} m²',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.attach_money, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                '${_land!.priceland ?? 'N/A'} DT',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'active':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return AppColors.primary;
    }
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController, // Utiliser le TabController
        isScrollable: true,
        labelColor: AppColors.primary,
        unselectedLabelColor: Colors.grey,
        indicatorColor: AppColors.primary,
        indicatorWeight: 3,
        tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
      ),
    );
  }

  Widget _buildTabContent() {
    return TabBarView(
      controller: _tabController, // Utiliser le TabController
      children: [
        // Overview Tab
        SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section des images
              LandImagesWidget(land: _land!),
              const SizedBox(height: 24),

              // Section des informations générales
              LandGeneralInfoWidget(land: _land!),
            ],
          ),
        ),

        // Tokenization Tab
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: LandTokenizationWidget(land: _land!),
        ),

        // Features Tab
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: LandAmenitiesWidget(land: _land!),
        ),

        // Validation Tab
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: LandValidationWidget(land: _land!),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _shareLand(),
              icon: const Icon(Icons.share),
              label: const Text('Share This Land'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 2,
              ),
            ),
          ),
          if (_land?.isTokenized ?? false) ...[
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Naviguer vers l'onglet Tokenization
                  _tabController.animateTo(1); // Passer à l'onglet Tokenization
                },
                icon: const Icon(Icons.token),
                label: const Text('Buy Tokens'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _shareLand() {
    final land = _land!;
    final String shareText = '''
🏡 Land for Sale: ${land.title}
📍 Location: ${land.location}
📏 Surface: ${land.surface ?? 'N/A'} m²
💰 Price: ${land.priceland ?? 'N/A'} DT
${land.blockchainLandId != null ? '🔗 Blockchain ID: ${land.blockchainLandId}\n' : ''}
${land.isTokenized ? '🪙 Tokenized: Yes - ${land.availableTokens ?? 0}/${land.totalTokens ?? 0} tokens available\n' : ''}
📜 Description: ${land.description ?? 'No description available'}
🔍 Status: ${land.status}
📞 Contact us for more information!
    ''';

    Share.share(
      shareText,
      subject: 'Land for Sale: ${land.title}',
    );
  }
}
