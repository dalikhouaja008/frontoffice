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

class _LandDetailsScreenState extends State<LandDetailsScreen> {
  Land? _land;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadLand();
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
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(child: Text(_error!)),
      );
    }

    return Scaffold(
      body: _land == null
          ? const Center(child: Text('No Land Selected'))
          : BlocProvider(
              create: (context) => TokenizationBloc(),
              child: Column(
                children: [
                  const AppNavBar(currentRoute: '/land-details'),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Section des images
                            LandImagesWidget(land: _land!),
                            const SizedBox(height: 24),
                            
                            // Section des informations générales
                            LandGeneralInfoWidget(land: _land!),
                            const SizedBox(height: 24),
                            
                            LandTokenizationWidget(land: _land!),
                            const SizedBox(height: 24),
                            
                            // Section des commodités
                            LandAmenitiesWidget(land: _land!),
                            const SizedBox(height: 24),
                            
                            // Section de validation
                            LandValidationWidget(land: _land!),
                            const SizedBox(height: 24),
                            
                            // Boutons d'action
                            _buildActionButtons(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _shareLand(),
            icon: const Icon(Icons.share),
            label: const Text('Share'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
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