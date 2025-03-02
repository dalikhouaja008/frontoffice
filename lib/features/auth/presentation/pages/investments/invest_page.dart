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

    return BlocProvider(
      create: (context) => PropertyBloc(
        getPropertiesUseCase: GetIt.instance<GetPropertiesUseCase>(),
      )..add(LoadProperties()),
      child: BlocBuilder<PropertyBloc, PropertyState>(
        builder: (context, state) {
          final bloc = context.read<PropertyBloc>();
          
          return BasePage(
            title: 'Investment Opportunities',
            currentRoute: '/invest',
            body: Column(
              children: [
                InvestmentHeader(),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? AppDimensions.paddingL : AppDimensions.paddingXXL,
                    vertical: AppDimensions.paddingL,
                  ),
                  child: isMobile
                      ? Column(
                          children: [
                            InvestmentFilters(
                              bloc: bloc,
                              isMobile: true,
                            ),
                            const SizedBox(height: AppDimensions.paddingL),
                            _buildInvestmentContent(state, bloc),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InvestmentFilters(
                              bloc: bloc,
                              isMobile: false,
                            ),
                            const SizedBox(width: AppDimensions.paddingL),
                            Expanded(
                              child: _buildInvestmentContent(state, bloc),
                            ),
                          ],
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
        Text(
          "$propertyCount Investment Opportunities",
          style: const TextStyle(
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
}