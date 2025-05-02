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
  bool _showFullDescription = false;
  
  // Définir la constante du nom du réseau
  final String _networkName = 'sepolia'; // ou 'mainnet' selon votre besoin

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeaderSection(),
        const SizedBox(height: 20),
        _buildDescriptionSection(),
        const SizedBox(height: 20),
        _buildTokenizationDetails(),
        const SizedBox(height: 20),
        _buildLocationSection(),
      ],
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header gradient banner - TITRE RÉDUIT
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16), // Réduit
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.8),
                  AppColors.primary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8), // Réduit
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    color: Colors.white,
                    size: 20, // Réduit
                  ),
                ),
                const SizedBox(width: 10), // Réduit
                const Text(
                  'Property Details',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16, // Réduit
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and status row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        widget.land.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: _getStatusColor().withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        widget.land.status,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Price with animation effect
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.8, end: 1.0),
                  duration: const Duration(milliseconds: 500),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: child,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.attach_money,
                          color: AppColors.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.land.priceland != null
                              ? '${widget.land.priceland} DT'
                              : 'Price not available',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Property info cards
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    // Surface area
                    if (widget.land.surface != null)
                      _buildInfoCard(
                        icon: Icons.square_foot,
                        title: 'Surface',
                        value: '${widget.land.surface} m²',
                        backgroundColor: Colors.blue.withOpacity(0.1),
                        iconColor: Colors.blue,
                      ),
                    
                    // Land type
                    if (widget.land.landtype != null)
                      _buildInfoCard(
                        icon: Icons.category,
                        title: 'Type',
                        value: _getLandTypeDisplay(widget.land.landtype!),
                        backgroundColor: Colors.amber.withOpacity(0.1),
                        iconColor: Colors.amber[700]!,
                      ),
                      
                    // Listed date
                    _buildInfoCard(
                      icon: Icons.calendar_today,
                      title: 'Listed on',
                      value: _formatDate(widget.land.createdAt),
                      backgroundColor: Colors.green.withOpacity(0.1),
                      iconColor: Colors.green,
                    ),
                    
                    // Availability
                    if (widget.land.availability != null)
                      _buildInfoCard(
                        icon: Icons.access_time,
                        title: 'Availability',
                        value: widget.land.availability!,
                        backgroundColor: Colors.purple.withOpacity(0.1),
                        iconColor: Colors.purple,
                      ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Blockchain info
                if (widget.land.ownerAddress != null && widget.land.ownerAddress!.isNotEmpty) ...[
                  _buildBlockchainInfo(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color backgroundColor,
    required Color iconColor,
  }) {
    return Container(
      width: MediaQuery.of(context).size.width > 600 
          ? (MediaQuery.of(context).size.width - 80) / 3
          : (MediaQuery.of(context).size.width - 80) / 2,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
  
  Widget _buildBlockchainInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blueGrey.withOpacity(0.2),
            Colors.blueGrey.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blueGrey.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TITRE RÉDUIT
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6), // Réduit
                decoration: BoxDecoration(
                  color: Colors.blueGrey.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.token,
                  color: Colors.blueGrey,
                  size: 16, // Réduit
                ),
              ),
              const SizedBox(width: 8), // Réduit
              const Text(
                'Blockchain Information',
                style: TextStyle(
                  fontSize: 14, // Réduit
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (widget.land.ownerAddress != null && widget.land.ownerAddress!.isNotEmpty) ...[
            Row(
              children: [
                const Icon(Icons.account_balance_wallet, 
                  size: 16, color: Colors.blueGrey),
                const SizedBox(width: 8),
                const Text(
                  'Owner Address:',
                  style: TextStyle(
                    color: Colors.blueGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _truncateAddress(widget.land.ownerAddress!),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => widget.land.blockchainTxHash != null
                ? _launchEtherscanAddress(widget.land.blockchainTxHash!)
                : null,
            icon: const Icon(Icons.open_in_new),
            label: const Text('View on Etherscan'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueGrey[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
    final description = widget.land.description ?? 'No description available';
    final shouldTruncate = description.length > 300 && !_showFullDescription;
    final displayedText = shouldTruncate 
        ? '${description.substring(0, 300)}...' 
        : description;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TITRE RÉDUIT
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6), // Réduit
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.description,
                  color: Colors.orange[700],
                  size: 16, // Réduit
                ),
              ),
              const SizedBox(width: 8), // Réduit
              const Text(
                'Description',
                style: TextStyle(
                  fontSize: 16, // Réduit
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            displayedText,
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: Colors.grey[800],
            ),
          ),
          if (shouldTruncate) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                setState(() {
                  _showFullDescription = true;
                });
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Read more',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_drop_down,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ],
          if (!shouldTruncate && _showFullDescription) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                setState(() {
                  _showFullDescription = false;
                });
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Show less',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_drop_up,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildTokenizationDetails() {
    if (widget.land.totalTokens == null && widget.land.pricePerToken == null) {
      return const SizedBox.shrink();
    }
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TITRE RÉDUIT
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6), // Réduit
                decoration: BoxDecoration(
                  color: Colors.indigo.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.token,
                  color: Colors.indigo,
                  size: 16, // Réduit
                ),
              ),
              const SizedBox(width: 8), // Réduit
              const Text(
                'Tokenization Details',
                style: TextStyle(
                  fontSize: 16, // Réduit
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Stats in cards
          Row(
            children: [
              if (widget.land.totalTokens != null)
                Expanded(
                  child: _buildStatCard(
                    title: 'Total Tokens',
                    value: '${widget.land.totalTokens}',
                    icon: Icons.token,
                    color: Colors.indigo,
                  ),
                ),
              const SizedBox(width: 15),
              if (widget.land.pricePerToken != null)
                Expanded(
                  child: _buildStatCard(
                    title: 'Price per Token',
                    value: '${widget.land.pricePerToken} ETH',
                    icon: Icons.attach_money,
                    color: Colors.green,
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          if (widget.land.blockchainLandId != null) ...[
            ElevatedButton.icon(
              onPressed: () => _launchBlockchainExplorer(),
              icon: const Icon(Icons.explore),
              label: const Text('View on Blockchain Explorer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: color.withOpacity(0.8),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    final hasCoordinates = widget.land.latitude != null && widget.land.longitude != null;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TITRE RÉDUIT
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16), // Réduit
            decoration: BoxDecoration(
              color: Colors.teal,
              gradient: LinearGradient(
                colors: [
                  Colors.teal.shade400,
                  Colors.teal.shade700,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6), // Réduit
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.white,
                    size: 18, // Réduit
                  ),
                ),
                const SizedBox(width: 8), // Réduit
                const Text(
                  'Location',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16, // Réduit
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Address
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.withOpacity(0.1)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.teal,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Property Address',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            SelectableText(
                              widget.land.location,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                if (hasCoordinates) ...[
                  const SizedBox(height: 20),
                  
                  // Map
                  Container(
                    height: 250,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        children: [
                          FlutterMap(
                            mapController: _mapController,
                            options: MapOptions(
                              center: LatLng(widget.land.latitude!, widget.land.longitude!),
                              zoom: 14.0,
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
                                    width: 50.0,
                                    height: 50.0,
                                    point: LatLng(widget.land.latitude!, widget.land.longitude!),
                                    builder: (ctx) => TweenAnimationBuilder<double>(
                                      tween: Tween<double>(begin: 0.7, end: 1.0),
                                      duration: const Duration(milliseconds: 500),
                                      curve: Curves.elasticOut,
                                      builder: (context, value, child) {
                                        return Transform.scale(
                                          scale: value,
                                          child: child,
                                        );
                                      },
                                      child: const Icon(
                                        Icons.location_on,
                                        color: Colors.red,
                                        size: 50,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.fullscreen, color: Colors.teal),
                                onPressed: () {
                                  _mapController.move(
                                    LatLng(widget.land.latitude!, widget.land.longitude!),
                                    16.0,
                                  );
                                },
                                tooltip: 'Zoom In',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // GPS coordinates
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.teal.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.teal.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.gps_fixed,
                          color: Colors.teal,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'GPS Coordinates',
                                style: TextStyle(
                                  color: Colors.teal,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              SelectableText(
                                '${widget.land.latitude!.toStringAsFixed(6)}, ${widget.land.longitude!.toStringAsFixed(6)}',
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, color: Colors.teal, size: 18),
                          onPressed: () {
                            // Copy coordinates to clipboard
                            // Implement clipboard functionality
                          },
                          tooltip: 'Copy coordinates',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Open in Maps button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _launchMapsUrl(),
                      icon: const Icon(Icons.map),
                      label: const Text('Open in Google Maps'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
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
  
  String _truncateAddress(String address) {
    if (address.length <= 14) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 6)}';
  }

  void _launchMapsUrl() async {
    if (widget.land.latitude == null || widget.land.longitude == null) return;
    
    final url = 'https://www.google.com/maps/search/?api=1&query=${widget.land.latitude},${widget.land.longitude}';
    final uri = Uri.parse(url);
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open maps'),
          behavior: SnackBarBehavior.floating,
        ),
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
        const SnackBar(
          content: Text('Could not open Etherscan'),
          behavior: SnackBarBehavior.floating,
        ),
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
        const SnackBar(
          content: Text('Could not open blockchain explorer'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}