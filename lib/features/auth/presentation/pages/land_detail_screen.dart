// lib/features/auth/presentation/pages/land_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
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
    return WillPopScope(
      onWillPop: () async {
        context.read<LandBloc>().add(LoadLands());
        return true;
      },
      child: Scaffold(
        body: Column(
          children: [
            const AppNavBar(currentRoute: '/property-details'),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(child: Text(_error!))
                      : _land == null
                          ? const Center(child: Text('No land data available'))
                          : SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Stack(
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        height: 300,
                                        child: _land?.imageCIDs?.isNotEmpty == true
                                          ? Image.network(
                                              _land!.imageCIDs![0], // Now safe because we checked isNotEmpty
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              height: 300,
                                              errorBuilder: (context, error, stackTrace) => const Text('Image Not Available'),
                                            )
                                          : const Text('No Image Available'),
                                      ),
                                      Positioned(
                                        top: 20,
                                        left: 20,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.9),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: IconButton(
                                            icon: const Icon(Icons.arrow_back),
                                            onPressed: () {
                                              context.read<LandBloc>().add(LoadLands());
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(24.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildHeaderSection(context),
                                        const SizedBox(height: 24),
                                        _buildMainInfoSection(context),
                                        const SizedBox(height: 24),
                                        if (_land!.latitude != null && _land!.longitude != null)
                                          _buildLocationSection(context),
                                        const SizedBox(height: 24),
                                        _buildAdditionalInfoSection(context),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
            ),
          ],
        ),
      ),
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
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              semanticsLabel: 'Title: ${_land!.title}',
            ),
            const SizedBox(height: 8),
            Text(
              _land!.totalPrice != null
                  ? NumberFormat.currency(locale: 'en_US', symbol: 'DT').format(_land!.totalPrice)
                  : 'Price not available',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
              semanticsLabel: 'Price: ${_land!.totalPrice ?? 'N/A'} DT',
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
            Text('Main Information', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.location_on, 'Location', _land!.location),
            if (_land!.description != null && _land!.description!.isNotEmpty)
              _buildInfoRow(Icons.description, 'Description', _land!.description!),
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
            Text('GPS Coordinates', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.gps_fixed, 'Latitude', _land!.latitude.toString()),
            _buildInfoRow(Icons.gps_fixed, 'Longitude', _land!.longitude.toString()),
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
            Text('Additional Information', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.calendar_today, 'Creation Date', _formatDate(_land!.createdAt)),
            _buildInfoRow(Icons.update, 'Last Update', _formatDate(_land!.updatedAt)),
            _buildInfoRow(Icons.person_outline, 'Owner ID', _land!.ownerId),
            if (_land!.ownerAddress != null)
              _buildInfoRow(Icons.person, 'Owner Address', _land!.ownerAddress!),
            if (_land!.blockchainLandId != null)
              _buildInfoRow(Icons.link, 'Blockchain Land ID', _land!.blockchainLandId!),
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
                Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
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