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
        // Recharger les terrains avant de retourner à la page précédente
        context.read<LandBloc>().add(LoadLands());
        return true;
      },
      child: Scaffold(
        body: Column(
          children: [
            // Même barre de navigation que l'écran invest
            const AppNavBar(
              currentRoute: '/invest',
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Section avec bouton retour
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
                        // Bouton retour
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
                                // Recharger les terrains avant de retourner
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
                          // En-tête avec titre et prix
                          _buildHeaderSection(context),
                          const SizedBox(height: 24),

                          // Informations principales
                          _buildMainInfoSection(context),
                          const SizedBox(height: 24),

                          // Localisation
                          if (widget.land.latitude != null && widget.land.longitude != null)
                            _buildLocationSection(context),
                          const SizedBox(height: 24),

                          // Détails supplémentaires
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
              '${NumberFormat.currency(locale: 'fr_TN', symbol: 'TND').format(widget.land.price)}',
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
              'Informations principales',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.location_on,
              'Emplacement',
              widget.land.location,
            ),
            _buildInfoRow(
              Icons.category,
              'Type',
              _getTypeInFrench(widget.land.type),
            ),
            _buildInfoRow(
              Icons.info_outline,
              'Statut',
              _getStatusInFrench(widget.land.status),
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
              'Coordonnées GPS',
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
              'Informations supplémentaires',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.calendar_today,
              'Date de création',
              _formatDate(widget.land.createdAt),
            ),
            _buildInfoRow(
              Icons.update,
              'Dernière mise à jour',
              _formatDate(widget.land.updatedAt),
            ),
            _buildInfoRow(
              Icons.person_outline,
              'ID du propriétaire',
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
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  String _getTypeInFrench(LandType type) {
    switch (type) {
      case LandType.AGRICULTURAL:
        return 'Agricole';
      case LandType.RESIDENTIAL:
        return 'Résidentiel';
      case LandType.INDUSTRIAL:
        return 'Industriel';
      case LandType.COMMERCIAL:
        return 'Commercial';
    }
  }

  String _getStatusInFrench(LandStatus status) {
    switch (status) {
      case LandStatus.AVAILABLE:
        return 'Disponible';
      case LandStatus.PENDING:
        return 'En attente';
      case LandStatus.SOLD:
        return 'Vendu';
    }
  }
}