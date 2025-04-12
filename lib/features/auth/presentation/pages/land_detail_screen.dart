import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:the_boost/core/constants/colors.dart';
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
        context.read<LandBloc>().add(LoadLands());
        return true;
      },
      child: Scaffold(
        body: Column(
          children: [
            const AppNavBar(currentRoute: '/invest'),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImageSection(context),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeaderSection(context),
                          const SizedBox(height: 16),
                          _buildMainInfoSection(context),
                          const SizedBox(height: 16),
                          _buildAmenitiesSection(context),
                          const SizedBox(height: 16),
                          if (widget.land.latitude != null && widget.land.longitude != null)
                            _buildLocationSection(context),
                          const SizedBox(height: 16),
                          if (widget.land.validations.isNotEmpty)
                            _buildValidationsSection(context),
                          const SizedBox(height: 16),
                          _buildBlockchainSection(context),
                          const SizedBox(height: 16),
                          _buildAdditionalInfoSection(context),
                          const SizedBox(height: 16),
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

  Widget _buildImageSection(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 300,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.3),
                Colors.black.withOpacity(0.7),
              ],
            ),
          ),
          child: widget.land.imageCIDs.isNotEmpty
              ? Image.network(
                  widget.land.imageCIDs[0],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                  ),
                )
              : Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                ),
        ),
        Positioned(
          top: 40,
          left: 16,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                context.read<LandBloc>().add(LoadLands());
                Navigator.pop(context);
              },
            ),
          ),
        ),
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.land.title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black45,
                      offset: Offset(1, 1),
                      blurRadius: 3,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.land.location,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  shadows: [
                    Shadow(
                      color: Colors.black45,
                      offset: Offset(1, 1),
                      blurRadius: 3,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Price',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  NumberFormat.currency(locale: 'en_US', symbol: 'DT')
                      .format(widget.land.totalPrice),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Status',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 4),
                _buildStatusChip(widget.land.status),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainInfoSection(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Main Information',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.location_on, 'Location', widget.land.location),
            _buildInfoRow(Icons.straighten, 'Surface', '${widget.land.surface} m²'),
            if (widget.land.totalTokens != null)
              _buildInfoRow(
                  Icons.token, 'Total Tokens', widget.land.totalTokens.toString()),
            if (widget.land.pricePerToken != null)
              _buildInfoRow(
                  Icons.attach_money, 'Price per Token', '${widget.land.pricePerToken} DT'),
            if (widget.land.description != null && widget.land.description!.isNotEmpty)
              _buildInfoRow(Icons.description, 'Description', widget.land.description!),
            _buildInfoRow(
                Icons.terrain, 'Land Type', widget.land.landtype.displayName),
          ],
        ),
      ),
    );
  }

  Widget _buildAmenitiesSection(BuildContext context) {
    final amenities = widget.land.amenities.entries
        .where((entry) => entry.value == true)
        .map((entry) => entry.key)
        .toList();

    if (amenities.isEmpty) return const SizedBox.shrink();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Amenities',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: amenities.map((amenity) {
                return _buildAmenityChip(amenity);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'GPS Coordinates',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.gps_fixed, 'Latitude', widget.land.latitude.toString()),
            _buildInfoRow(Icons.gps_fixed, 'Longitude', widget.land.longitude.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildValidationsSection(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Validations',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...widget.land.validations.map((validation) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      validation.isValidated ? Icons.check_circle : Icons.cancel,
                      color: validation.isValidated ? Colors.green : Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${validation.validatorType.displayName} (${validation.validator})',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Date: ${_formatDate(DateTime.fromMillisecondsSinceEpoch(validation.timestamp * 1000))}',
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          if (validation.cidComments.isNotEmpty)
                            Text(
                              'Comments CID: ${validation.cidComments}',
                              style: const TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildBlockchainSection(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Blockchain Information',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.account_balance_wallet, 'Owner Address',
                widget.land.ownerAddress),
            _buildInfoRow(
                Icons.fingerprint, 'Land ID', widget.land.blockchainLandId),
            if (widget.land.blockchainTxHash != null)
              _buildInfoRow(
                  Icons.link, 'Transaction Hash', widget.land.blockchainTxHash!),
            if (widget.land.ipfsCIDs.isNotEmpty)
              _buildInfoRow(
                  Icons.cloud, 'IPFS CIDs', widget.land.ipfsCIDs.join(', ')),
            if (widget.land.imageCIDs.isNotEmpty)
              _buildInfoRow(
                  Icons.image, 'Image CIDs', widget.land.imageCIDs.join(', ')),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfoSection(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Additional Information',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.calendar_today, 'Creation Date',
                _formatDate(widget.land.createdAt)),
            _buildInfoRow(
                Icons.update, 'Last Update', _formatDate(widget.land.updatedAt)),
            _buildInfoRow(Icons.person_outline, 'Owner ID', widget.land.ownerId),
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
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16),
                  softWrap: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(LandValidationStatus status) {
    Color chipColor;
    switch (status) {
      case LandValidationStatus.PENDING_VALIDATION:
        chipColor = Colors.orange;
        break;
      case LandValidationStatus.VALIDATED:
        chipColor = Colors.green;
        break;
      case LandValidationStatus.REJECTED:
        chipColor = Colors.red;
        break;
      case LandValidationStatus.PARTIALLY_VALIDATED:
        chipColor = Colors.amber;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          fontSize: 14,
          color: chipColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildAmenityChip(String amenity) {
    IconData icon;
    Color color;
    switch (amenity) {
      case 'electricity':
        icon = Icons.electrical_services;
        color = Colors.green;
        break;
      case 'water':
        icon = Icons.water_drop;
        color = Colors.blue;
        break;
      case 'roadAccess':
        icon = Icons.directions_car;
        color = Colors.grey;
        break;
      case 'buildingPermit':
        icon = Icons.build;
        color = Colors.orange;
        break;
      case 'internet':
        icon = Icons.wifi;
        color = Colors.purple;
        break;
      case 'publicTransport':
        icon = Icons.directions_bus;
        color = Colors.blueGrey;
        break;
      case 'fenced':
        icon = Icons.fence;
        color = Colors.brown;
        break;
      case 'trees':
        icon = Icons.park;
        color = Colors.green;
        break;
      default:
        icon = Icons.check;
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            amenity[0].toUpperCase() + amenity.substring(1),
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy HH:mm').format(date);
  }
}