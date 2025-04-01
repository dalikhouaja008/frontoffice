import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_boost/core/constants/colors.dart';
import 'package:the_boost/core/constants/dimensions.dart';
import 'package:the_boost/core/constants/text_styles.dart';
import 'package:the_boost/core/di/dependency_injection.dart';
import 'package:the_boost/core/utils/responsive_helper.dart';
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
      ),
      body: BlocProvider(
        create: (context) {
          print('[${DateTime.now()}] InvestPage: Initializing LandBloc...');
          final bloc = LandBloc(getIt<LandRepository>());
          bloc.add(LoadLands()); // Trigger the loading of lands
          return bloc;
        },
        child: BlocConsumer<LandBloc, LandState>(
          listener: (context, state) {
            if (state is LandError) {
              print('[${DateTime.now()}] InvestPage: Error state received: ${state.message}');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            if (state is LandLoading) {
              print('[${DateTime.now()}] InvestPage: Loading state...');
              return const Center(child: CircularProgressIndicator());
            } else if (state is LandLoaded) {
              print('[${DateTime.now()}] InvestPage: Loaded state with ${state.lands.length} lands.');
              if (state.lands.isEmpty) {
                return const Center(child: Text('No lands available'));
              }
              return ListView.builder(
                itemCount: state.lands.length,
                itemBuilder: (context, index) {
                  final land = state.lands[index];
                  return ListTile(
                    title: Text(land.title),
                    subtitle: Text('\$${land.price} - ${land.location}'),
                  );
                },
              );
            } else if (state is LandError) {
              print('[${DateTime.now()}] InvestPage: Error state: ${state.message}');
              return Center(child: Text(state.message));
            } else {
              print('[${DateTime.now()}] InvestPage: Default state (no lands available).');
              return const Center(child: Text('No lands available'));
            }
          },
        ),
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