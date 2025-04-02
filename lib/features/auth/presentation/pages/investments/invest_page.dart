import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_boost/core/constants/colors.dart';
import 'package:the_boost/core/constants/dimensions.dart';
import 'package:the_boost/core/constants/text_styles.dart';
import 'package:the_boost/core/di/dependency_injection.dart';
import 'package:the_boost/core/utils/responsive_helper.dart';
import 'package:the_boost/features/auth/data/models/land_model.dart';
import 'package:the_boost/features/auth/domain/repositories/land_repository.dart';
import 'package:the_boost/features/auth/domain/use_cases/investments/get_properties_usecase.dart';
import 'package:the_boost/features/auth/presentation/bloc/lands/land_bloc.dart';
import 'package:the_boost/features/auth/presentation/bloc/property/property_bloc.dart';
import 'package:the_boost/features/auth/presentation/bloc/routes.dart';
import 'package:the_boost/features/auth/presentation/pages/base_page.dart';
import 'package:the_boost/features/auth/presentation/widgets/investment_filters.dart';
import 'package:the_boost/features/auth/presentation/widgets/investment_grid.dart';
import 'package:the_boost/features/auth/presentation/widgets/investment_header.dart';
import 'package:get_it/get_it.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_boost/core/constants/colors.dart';
import 'package:the_boost/core/constants/dimensions.dart';
import 'package:the_boost/core/constants/text_styles.dart';
class InvestPage extends StatelessWidget {
  const InvestPage({Key? key}) : super(key: key);

@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Investment Opportunities'),
        backgroundColor: AppColors.primary,
      ),
      body: Row(
        children: [
          // Sidebar for filters
          Container(
            width: 250,
            color: AppColors.backgroundLight,
            child: _buildSidebar(context),
          ),
          // Main content
          Expanded(
            child: BlocProvider(
              create: (context) {
                final bloc = LandBloc(getIt<LandRepository>());
                bloc.add(LoadLands());
                return bloc;
              },
              child: BlocConsumer<LandBloc, LandState>(
                listener: (context, state) {
                  if (state is LandError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message)),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is LandLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is LandLoaded) {
                    if (state.lands.isEmpty) {
                      return const Center(child: Text('No lands available'));
                    }
                    return Padding(
                      padding: const EdgeInsets.all(AppDimensions.paddingM),
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3, // Smaller cards with 3 columns
                          crossAxisSpacing: AppDimensions.paddingS,
                          mainAxisSpacing: AppDimensions.paddingS,
                          childAspectRatio: 4 / 3, // Adjusted aspect ratio
                        ),
                        itemCount: state.lands.length,
                        itemBuilder: (context, index) {
                          final land = state.lands[index];
                          return _buildLandCard(land);
                        },
                      ),
                    );
                  } else if (state is LandError) {
                    return Center(child: Text(state.message));
                  } else {
                    return const Center(child: Text('No lands available'));
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the sidebar for filtering lands
  Widget _buildSidebar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filters',
            style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppDimensions.paddingM),
          Text(
            'Status',
            style: AppTextStyles.body2.copyWith(fontWeight: FontWeight.bold),
          ),
          CheckboxListTile(
            title: const Text('Available'),
            value: true, // Replace with actual filter state
            onChanged: (value) {
              // Handle filter logic
            },
          ),
          CheckboxListTile(
            title: const Text('Sold'),
            value: false, // Replace with actual filter state
            onChanged: (value) {
              // Handle filter logic
            },
          ),
          const SizedBox(height: AppDimensions.paddingM),
          Text(
            'Price Range',
            style: AppTextStyles.body2.copyWith(fontWeight: FontWeight.bold),
          ),
          Slider(
            value: 50000, // Replace with actual filter state
            min: 0,
            max: 1000000,
            divisions: 20,
            label: '\$50000',
            onChanged: (value) {
              // Handle filter logic
            },
          ),
        ],
      ),
    );
  }

  /// Builds a single land card
  Widget _buildLandCard(Land land) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
      ),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusS)),
                image: DecorationImage(
                  image: NetworkImage(land.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingXS),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  land.title,
                  style: AppTextStyles.body2.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppDimensions.paddingS), // Replace with a valid padding value
                Text(
                  '\$${land.price} - ${land.location}',
                  style: AppTextStyles.body3.copyWith(color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the investment content based on the current state
  Widget _buildInvestmentContent(PropertyState state, PropertyBloc bloc) {
    if (state is PropertyLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else if (state is PropertyError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading properties',
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: 8),
            Text(
              state.message,
              style: AppTextStyles.body2,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                bloc.add(LoadProperties());
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    } else if (state is PropertyLoaded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInvestmentHeader(state.filteredProperties.length),
          const SizedBox(height: AppDimensions.paddingM),
          InvestmentGrid(
            properties: state.filteredProperties,
          ),
        ],
      );
    } else {
      return const Center(
        child: Text('No properties found'),
      );
    }
  }

  /// Builds the header for the investment section
  Widget _buildInvestmentHeader(int propertyCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "$propertyCount Investment Opportunities",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        DropdownButton<String>(
          value: 'Featured',
          onChanged: (String? value) {},
          items: ['Featured', 'Newest', 'Highest Return', 'Lowest Risk']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          underline: Container(
            height: 2,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  /// Builds the chatbot section for investment assistance
  Widget _buildChatbotSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: AppColors.backgroundGreen.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.support_agent,
                color: AppColors.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                "Need help with your investment decisions?",
                style: AppTextStyles.h4,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingM),
          Text(
            "Our Investment Assistant can help you understand tokenized land assets, investment strategies, and answer your specific questions.",
            textAlign: TextAlign.center,
            style: AppTextStyles.body2,
          ),
          const SizedBox(height: AppDimensions.paddingL),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.investmentAssistant);
            },
            icon: const Icon(Icons.support_agent),
            label: const Text('Chat with Investment Assistant'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingXL,
                vertical: AppDimensions.paddingM,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              ),
            ),
          ),
        ],
      ),
    );
  }
}