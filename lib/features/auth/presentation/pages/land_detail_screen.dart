import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:the_boost/core/constants/colors.dart';
import 'package:the_boost/core/constants/dimensions.dart';
import 'package:the_boost/features/auth/data/models/land_model.dart';
import 'package:the_boost/features/auth/presentation/bloc/lands/land_bloc.dart';
import 'package:the_boost/features/auth/presentation/widgets/app_nav_bar.dart';

class LandDetailsScreen extends StatefulWidget {
  final Land land;

  const LandDetailsScreen({Key? key, required this.land}) : super(key: key);

  @override
  State<LandDetailsScreen> createState() => _LandDetailsScreenState();
}

class _LandDetailsScreenState extends State<LandDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Reload lands before returning to previous page
        context.read<LandBloc>().add(LoadLands());
        return true;
      },
      child: Scaffold(
        body: Column(
          children: [
            // Same navigation bar as invest screen
            const AppNavBar(
              currentRoute: '/invest',
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Section with back button
                    Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 300,
                          child: Image.network(
                            widget.land.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.image_not_supported,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                        ),
                        // Back button
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
                          if (widget.land.latitude != null && widget.land.longitude != null)
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
              widget.land.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              NumberFormat.currency(locale: 'en_US', symbol: '\D''\T').format(widget.land.price),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
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
            Text(
              'Main Information',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.location_on,
              'Location',
              widget.land.location,
            ),
            _buildInfoRow(
              Icons.category,
              'Type',
              _getTypeInEnglish(widget.land.type),
            ),
            _buildInfoRow(
              Icons.info_outline,
              'Status',
              _getStatusInEnglish(widget.land.status),
            ),
            if (widget.land.description != null && widget.land.description!.isNotEmpty)
              _buildInfoRow(
                Icons.description,
                'Description',
                widget.land.description!,
              ),
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
            Text(
              'GPS Coordinates',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.gps_fixed,
              'Latitude',
              widget.land.latitude.toString(),
            ),
            _buildInfoRow(
              Icons.gps_fixed,
              'Longitude',
              widget.land.longitude.toString(),
            ),
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
            Text(
              'Additional Information',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.calendar_today,
              'Creation Date',
              _formatDate(widget.land.createdAt),
            ),
            _buildInfoRow(
              Icons.update,
              'Last Update',
              _formatDate(widget.land.updatedAt),
            ),
            _buildInfoRow(
              Icons.person_outline,
              'Owner ID',
              widget.land.ownerId,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
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

  String _getTypeInEnglish(LandType type) {
    switch (type) {
      case LandType.AGRICULTURAL:
        return 'AGRICULTURAL';
      case LandType.RESIDENTIAL:
        return 'RESIDENTIAL';
      case LandType.INDUSTRIAL:
        return 'INDUSTRIAL';
      case LandType.COMMERCIAL:
        return 'COMMERCIAL';
    }
  }

  String _getStatusInEnglish(LandStatus status) {
    switch (status) {
      case LandStatus.AVAILABLE:
        return 'AVAILABLE';
      case LandStatus.RESERVED:
        return 'RESERVED';
      case LandStatus.SOLD:
        return 'SOLD';
    }
  }
}