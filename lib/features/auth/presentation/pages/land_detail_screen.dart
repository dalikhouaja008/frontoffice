import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:the_boost/core/constants/colors.dart';
import 'package:the_boost/core/di/dependency_injection.dart';
import 'package:the_boost/core/services/land_service.dart';
import 'package:the_boost/features/auth/data/models/land_model.dart';
import 'package:the_boost/features/auth/presentation/bloc/lands/land_bloc.dart';
import 'package:the_boost/features/auth/presentation/widgets/app_nav_bar.dart';

class LandDetailsScreen extends StatefulWidget {
  final String? landId;
  final Land? land;

  const LandDetailsScreen({Key? key, this.land, this.landId}) : super(key: key);

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
          : Column(
              children: [
                const AppNavBar(currentRoute: '/land-details'),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LandImage(
                          imageCIDs: _land?.imageCIDs,
                          width: double.infinity,
                          height: 300,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(height: 16),
                        _buildHeaderSection(context),
                        const SizedBox(height: 16),
                        _buildMainInfoSection(context),
                        const SizedBox(height: 16),
                        if (_land!.latitude != null && _land!.longitude != null)
                          _buildLocationSection(context),
                        if (_land!.latitude != null && _land!.longitude != null)
                          const SizedBox(height: 16),
                        _buildAdditionalInfoSection(context),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => _shareLand(context),
                          icon: const Icon(Icons.share),
                          label: const Text('Share this Land'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  void _shareLand(BuildContext context) {
  final land = _land!;
  final String shareText = '''
  🏡 Land for Sale: ${land.title}
  📍 Location: ${land.location}
  📏 Surface: ${land.surface ?? 'N/A'} m²
  💰 Price: ${land.priceland ?? 'N/A'} DT
  📜 Description: ${land.description ?? 'No description available'}
  🔍 Status: ${land.status}
  📞 Contact us for more information!
  ''';

  Share.share(
    shareText,
    subject: 'Land for Sale: ${land.title}',
  );
}

  Widget _buildHeaderSection(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _land!.title,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
              semanticsLabel: 'Title: ${_land!.title}',
            ),
            const SizedBox(height: 8),
            Text(
            _land!.priceland != null
                ? '${_land!.priceland} DT'
                : 'Price not available',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.primary, fontWeight: FontWeight.bold),
            semanticsLabel: 'Price: ${_land!.priceland ?? 'N/A'} DT',
          ),
            const SizedBox(height: 8),
            Text(
              'Status: ${_land!.status}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainInfoSection(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Main Information',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.location_on, 'Location', _land!.location),
            if (_land!.description != null && _land!.description!.isNotEmpty)
              _buildInfoRow(
                  Icons.description, 'Description', _land!.description!),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('GPS Coordinates',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _buildInfoRow(
                Icons.gps_fixed, 'Latitude', _land!.latitude.toString()),
            _buildInfoRow(
                Icons.gps_fixed, 'Longitude', _land!.longitude.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfoSection(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Additional Information',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.calendar_today, 'Creation Date',
                _formatDate(_land!.createdAt)),
            _buildInfoRow(
                Icons.update, 'Last Update', _formatDate(_land!.updatedAt)),
            _buildInfoRow(Icons.person_outline, 'Owner ID', _land!.ownerId),
            if (_land!.ownerAddress != null)
              _buildInfoRow(
                  Icons.person, 'Owner Address', _land!.ownerAddress!),
            if (_land!.blockchainLandId != null)
              _buildInfoRow(
                  Icons.link, 'Blockchain Land ID', _land!.blockchainLandId!),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(fontSize: 14, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MM/dd/yyyy HH:mm').format(date);
  }
}

class LandImage extends StatelessWidget {
  final List<String>? imageCIDs;
  final double? width;
  final double? height;
  final BoxFit fit;

  const LandImage({
    Key? key,
    this.imageCIDs,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return imageCIDs?.isNotEmpty == true
        ? Image.network(
            imageCIDs!.first,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (context, error, stackTrace) =>
                const Text('Image not available'),
          )
        : const Text('No image available');
  }
}