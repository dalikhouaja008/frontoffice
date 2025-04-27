import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:the_boost/core/constants/colors.dart';
import 'package:the_boost/features/auth/data/models/land_model.dart';
import 'package:url_launcher/url_launcher.dart';

class LandGeneralInfoWidget extends StatefulWidget {
  final Land land;

  const LandGeneralInfoWidget({Key? key, required this.land}) : super(key: key);

  @override
  State<LandGeneralInfoWidget> createState() => _LandGeneralInfoWidgetState();
}

class _LandGeneralInfoWidgetState extends State<LandGeneralInfoWidget> {
  final MapController _mapController = MapController();
  bool _mapLoaded = false;
  
  // Définir la constante du nom du réseau
  final String _networkName = 'sepolia'; // ou 'mainnet' selon votre besoin

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeaderSection(),
        const SizedBox(height: 16),
        _buildBasicInfoSection(),
        const SizedBox(height: 16),
        _buildLocationSection(),
        const SizedBox(height: 16),
        _buildContactSection(),
      ],
    );
  }

  Widget _buildHeaderSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.land.title,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                    semanticsLabel: 'Title: ${widget.land.title}',
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _getStatusColor(),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    widget.land.status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.land.priceland != null
                  ? '${widget.land.priceland} DT'
                  : 'Price not available',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primary, fontWeight: FontWeight.bold),
              semanticsLabel: 'Price: ${widget.land.priceland ?? 'N/A'} DT',
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Listed on: ${_formatDate(widget.land.createdAt)}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            if (widget.land.surface != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.square_foot, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Surface: ${widget.land.surface} m²',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ],
            if (widget.land.landtype != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.category, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Type: ${_getLandTypeDisplay(widget.land.landtype!)}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ],
            if (widget.land.ownerAddress != null && widget.land.ownerAddress!.isNotEmpty) ...[
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () => _launchEtherscanAddress(widget.land.ownerAddress!),
                icon: const Icon(Icons.account_balance_wallet),
                label: const Text('View Owner on Etherscan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Description',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              widget.land.description ?? 'No description available',
              style: const TextStyle(fontSize: 16),
            ),
            if (widget.land.availability != null) ...[
              const Divider(height: 24),
              Row(
                children: [
                  const Icon(Icons.access_time, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Availability: ${widget.land.availability}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ],
            if (widget.land.totalTokens != null || widget.land.pricePerToken != null) ...[
              const Divider(height: 24),
              Text(
                'Tokenization Details',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (widget.land.totalTokens != null)
                _buildInfoRow(Icons.token, 'Total Tokens', '${widget.land.totalTokens}'),
              if (widget.land.pricePerToken != null)
                _buildInfoRow(Icons.money, 'Price per Token', '${widget.land.pricePerToken} DT'),
              
              if (widget.land.blockchainLandId != null) ...[
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => _launchBlockchainExplorer(),
                  icon: const Icon(Icons.explore),
                  label: const Text('View on Blockchain'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    final hasCoordinates = widget.land.latitude != null && widget.land.longitude != null;
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Location',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.location_on, 'Address', widget.land.location),
            
            if (hasCoordinates) ...[
              const SizedBox(height: 16),
              Text(
                'GPS Coordinates',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 250,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      center: LatLng(widget.land.latitude!, widget.land.longitude!),
                      zoom: 13.0,
                      interactiveFlags: InteractiveFlag.all,
                      onMapReady: () {
                        setState(() {
                          _mapLoaded = true;
                        });
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                        subdomains: const ['a', 'b', 'c'],
                        userAgentPackageName: 'com.theboost.app',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            width: 40.0,
                            height: 40.0,
                            point: LatLng(widget.land.latitude!, widget.land.longitude!),
                            builder: (ctx) => const Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () => _launchMapsUrl(),
                icon: const Icon(Icons.map),
                label: const Text('Open in Maps'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Owner Information',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.person_outline, 'Owner ID', widget.land.ownerId),
            if (widget.land.ownerAddress != null)
              _buildInfoRow(Icons.account_balance_wallet, 'Wallet Address', widget.land.ownerAddress!),
            
            const SizedBox(height: 16),
            const Text('Contact Owner', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // Implement contact owner functionality
                  },
                  icon: const Icon(Icons.email),
                  label: const Text('Send Message'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
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
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 2),
                SelectableText(
                  value,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (widget.land.status.toLowerCase()) {
      case 'available':
        return Colors.green;
      case 'sold':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      case 'validated':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getLandTypeDisplay(LandType landType) {
    switch (landType) {
      case LandType.residential:
        return 'Residential';
      case LandType.commercial:
        return 'Commercial';
      case LandType.agricultural:
        return 'Agricultural';
      case LandType.industrial:
        return 'Industrial';
      default:
        return landType.toString().split('.').last;
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  void _launchMapsUrl() async {
    if (widget.land.latitude == null || widget.land.longitude == null) return;
    
    final url = 'https://www.google.com/maps/search/?api=1&query=${widget.land.latitude},${widget.land.longitude}';
    final uri = Uri.parse(url);
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open maps')),
      );
    }
  }

  // Méthode pour ouvrir un lien Etherscan pour une adresse
  void _launchEtherscanAddress(String address) async {
    final url = 'https://${_networkName}.etherscan.io/address/$address';
    final uri = Uri.parse(url);
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Etherscan')),
      );
    }
  }

  // Méthode pour ouvrir un lien Etherscan pour une transaction
  void _launchEtherscanTx(String txHash) async {
    final url = 'https://${_networkName}.etherscan.io/tx/$txHash';
    final uri = Uri.parse(url);
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Etherscan')),
      );
    }
  }
  
  // Méthode pour ouvrir l'explorateur blockchain pour ce terrain
  void _launchBlockchainExplorer() async {
    if (widget.land.blockchainLandId == null) return;
    
    // Vous pouvez adapter cette URL selon votre explorateur de blockchain spécifique
    final url = 'https://${_networkName}.etherscan.io/token/${widget.land.blockchainLandId}';
    final uri = Uri.parse(url);
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open blockchain explorer')),
      );
    }
  }
}