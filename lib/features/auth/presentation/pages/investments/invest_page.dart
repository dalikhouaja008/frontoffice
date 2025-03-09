// lib/features/auth/presentation/pages/investments/invest_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_boost/core/constants/colors.dart';
import 'package:the_boost/core/constants/dimensions.dart';
import 'package:the_boost/core/constants/text_styles.dart';
import 'package:the_boost/core/utils/responsive_helper.dart';
import 'package:the_boost/features/auth/domain/use_cases/investments/get_properties_usecase.dart';
import 'package:the_boost/features/auth/presentation/bloc/property/property_bloc.dart';
import 'package:the_boost/features/auth/presentation/pages/base_page.dart';
import 'package:the_boost/features/auth/presentation/widgets/investment_filters.dart';
import 'package:the_boost/features/auth/presentation/widgets/investment_grid.dart';
import 'package:the_boost/features/auth/presentation/widgets/investment_header.dart';
import 'package:get_it/get_it.dart';

class InvestPage extends StatefulWidget {
  const InvestPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _InvestPageState createState() => _InvestPageState();
}

class _InvestPageState extends State<InvestPage> {
  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    
    // Calculate responsive padding based on screen size
    final horizontalPadding = isMobile 
        ? AppDimensions.paddingM
        : isTablet 
            ? AppDimensions.paddingL
            : AppDimensions.paddingXXL;

    return BlocProvider(
      create: (context) => PropertyBloc(
        getPropertiesUseCase: GetIt.instance<GetPropertiesUseCase>(),
      )..add(LoadProperties()),
      child: BlocBuilder<PropertyBloc, PropertyState>(
        builder: (context, state) {
          final bloc = context.read<PropertyBloc>();
          
          return BasePage(
            key: const ValueKey('InvestPage'),
            title: 'Investment Opportunities',
            currentRoute: '/invest',
            body: Column(
              children: [
                InvestmentHeader(),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: AppDimensions.paddingL,
                  ),
                  // Use LayoutBuilder to constrain content width
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      print('Available width for invest page: ${constraints.maxWidth}');
                      
                      // Adjust layout based on constraints
                      if (constraints.maxWidth < 700) {
                        // Mobile layout
                        return Column(
                          children: [
                            InvestmentFilters(
                              bloc: bloc,
                              isMobile: true,
                            ),
                            const SizedBox(height: AppDimensions.paddingL),
                            _buildInvestmentContent(state, bloc),
                          ],
                        );
                      } else {
                        // Desktop/tablet layout with size constraints
                        final filterWidth = constraints.maxWidth * 0.25;
                        final filterWidthCapped = filterWidth > 300 ? 300.0 : filterWidth;
                        final contentWidth = constraints.maxWidth - filterWidthCapped - AppDimensions.paddingL;
                        
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: filterWidthCapped,
                              child: InvestmentFilters(
                                bloc: bloc,
                                isMobile: false,
                              ),
                            ),
                            const SizedBox(width: AppDimensions.paddingL),
                            SizedBox(
                              width: contentWidth,
                              child: _buildInvestmentContent(state, bloc),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

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

  Widget _buildInvestmentHeader(int propertyCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Use Flexible to allow text to shrink if needed
        Flexible(
          child: Text(
            "$propertyCount Investment Opportunities",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // Constrain the dropdown to prevent overflow
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 150),
          child: DropdownButton<String>(
            value: 'Featured',
            onChanged: (String? value) {},
            isExpanded: true, // Make dropdown use full width of its container
            isDense: true, // Use dense style for dropdown
            items: ['Featured', 'Newest', 'Highest Return', 'Lowest Risk']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14),
                ),
              );
            }).toList(),
            underline: Container(
              height: 2,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}