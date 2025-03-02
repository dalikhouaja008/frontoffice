// presentation/pages/property_details/property_details_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_boost/core/constants/dimensions.dart';
import 'package:the_boost/core/utils/responsive_helper.dart';
import 'package:the_boost/features/auth/domain/entities/property.dart';
import 'package:the_boost/features/auth/presentation/bloc/login/login_bloc.dart';
import 'package:the_boost/features/auth/presentation/bloc/login/login_state.dart';
import 'package:the_boost/features/auth/presentation/bloc/property/property_bloc.dart';
import '../base_page.dart';
import 'widgets/property_details_header.dart';
import 'widgets/property_information.dart';
import 'widgets/investment_calculator.dart';
import 'widgets/property_gallery.dart';
import 'widgets/similar_properties.dart';

class PropertyDetailsPage extends StatefulWidget {
  final String propertyId;

  const PropertyDetailsPage({
    super.key,
    required this.propertyId,
  });

  @override
  // ignore: library_private_types_in_public_api
  _PropertyDetailsPageState createState() => _PropertyDetailsPageState();
}

class _PropertyDetailsPageState extends State<PropertyDetailsPage> {
  @override
  void initState() {
    super.initState();
    
    // Déclencher le chargement des propriétés si ce n'est pas déjà fait
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PropertyBloc>().add(LoadProperties());
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return BlocBuilder<PropertyBloc, PropertyState>(
      builder: (context, propertyState) {
        // Afficher un indicateur de chargement si les propriétés sont en cours de chargement
        if (propertyState is PropertyLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        // Vérifier si les propriétés sont chargées
        if (propertyState is PropertyLoaded) {
          // Chercher la propriété par ID
          final propertyList = propertyState.properties;
          final property = propertyList.firstWhere(
            (p) => p.id == widget.propertyId,
            // ignore: cast_from_null_always_fails
            orElse: () => null as Property, // Se déclenchera en cas de propriété non trouvée
          );
          
          // Si la propriété est trouvée, construire l'interface utilisateur
          return BlocBuilder<LoginBloc, LoginState>(
            builder: (context, loginState) {
              // Vérifier si l'utilisateur est authentifié
              final isAuthenticated = loginState is LoginSuccess;
              
              return BasePage(
                title: property.title,
                currentRoute: '/property-details',
                body: Column(
                  children: [
                    PropertyDetailsHeader(property: property),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? AppDimensions.paddingL : AppDimensions.paddingXXL,
                        vertical: AppDimensions.paddingXL,
                      ),
                      child: isMobile
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                PropertyInformation(property: property),
                                const SizedBox(height: AppDimensions.paddingXL),
                                InvestmentCalculator(
                                  property: property,
                                  isAuthenticated: isAuthenticated,
                                ),
                                const SizedBox(height: AppDimensions.paddingXL),
                                PropertyGallery(property: property),
                                const SizedBox(height: AppDimensions.paddingXL),
                                SimilarProperties(
                                  currentPropertyId: property.id,
                                  category: property.category,
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 7,
                                      child: PropertyInformation(property: property),
                                    ),
                                    SizedBox(width: AppDimensions.paddingXL),
                                    Expanded(
                                      flex: 3,
                                      child: InvestmentCalculator(
                                        property: property,
                                        isAuthenticated: isAuthenticated,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppDimensions.paddingXXL),
                                PropertyGallery(property: property),
                                const SizedBox(height: AppDimensions.paddingXXL),
                                SimilarProperties(
                                  currentPropertyId: property.id,
                                  category: property.category,
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              );
            },
          );
        }
        
        // En cas d'erreur lors du chargement des propriétés
        if (propertyState is PropertyError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Error loading property',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    propertyState.message,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<PropertyBloc>().add(LoadProperties());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }
        
        // État par défaut lorsque le bloc est dans un état initial
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}