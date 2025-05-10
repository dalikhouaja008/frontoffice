import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_boost/core/constants/colors.dart';
import 'package:the_boost/core/constants/dimensions.dart';
import 'package:the_boost/core/utils/responsive_helper.dart';
import 'package:the_boost/features/auth/domain/entities/investment_stats.dart';
import 'package:the_boost/features/auth/presentation/bloc/investment/investment_bloc.dart';

class DashboardStats extends StatelessWidget {
  const DashboardStats({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    
    return BlocBuilder<InvestmentBloc, InvestmentState>(
      builder: (context, state) {
        if (state is InvestmentLoading) {
          return _buildLoadingStats(isMobile);
        } else if (state is InvestmentLoaded) {
          return _buildStats(context, state.stats, isMobile);
        } else if (state is InvestmentRefreshing) {
          return _buildStats(context, state.stats, isMobile);
        } else if (state is InvestmentError) {
          return _buildErrorStats(context, state.message);
        } else {
          return _buildEmptyStats(isMobile);
        }
      },
    );
  }
  
  Widget _buildStats(BuildContext context, InvestmentStats stats, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: isMobile
          ? Column(
              children: [
                _buildStatItem(
                  context: context,
                  title: "Portfolio Value",
                  value: "${stats.totalCurrentMarketValue} ETH",
                  changeText: "${stats.totalProfit} (${stats.totalProfitPercentage}%)",
                  isPositive: double.parse(stats.totalProfit) >= 0,
                ),
                const Divider(height: AppDimensions.paddingXL),
                _buildStatItem(
                  context: context,
                  title: "Invested Capital",
                  value: "${stats.totalPurchaseValue} ETH",
                  changeText: "${stats.countOwned} tokens",
                ),
                const Divider(height: AppDimensions.paddingXL),
                _buildStatItem(
                  context: context,
                  title: "Listed Value",
                  value: "${stats.totalListedValue} ETH",
                  changeText: "${stats.countListed} tokens listed",
                  isPositive: stats.countListed > 0,
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: _buildStatItem(
                    context: context,
                    title: "Portfolio Value",
                    value: "${stats.totalCurrentMarketValue} ETH",
                    changeText: "${stats.totalProfit} (${stats.totalProfitPercentage}%)",
                    isPositive: double.parse(stats.totalProfit) >= 0,
                  ),
                ),
                const VerticalDivider(width: AppDimensions.paddingXL),
                Expanded(
                  child: _buildStatItem(
                    context: context,
                    title: "Invested Capital",
                    value: "${stats.totalPurchaseValue} ETH",
                    changeText: "${stats.countOwned} tokens",
                  ),
                ),
                const VerticalDivider(width: AppDimensions.paddingXL),
                Expanded(
                  child: _buildStatItem(
                    context: context,
                    title: "Listed Value",
                    value: "${stats.totalListedValue} ETH",
                    changeText: "${stats.countListed} tokens listed",
                    isPositive: stats.countListed > 0,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatItem({
    required BuildContext? context,
    required String title,
    required String value,
    required String changeText,
    bool isPositive = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingS),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingS),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isPositive)
              const Icon(
                Icons.arrow_upward,
                color: Colors.green,
                size: 16,
              ),
            Text(
              changeText,
              style: TextStyle(
                fontSize: 14,
                color: isPositive ? Colors.green : Colors.black54,
                fontWeight: isPositive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingStats(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: isMobile
          ? Column(
              children: List.generate(
                3,
                (index) => Column(
                  children: [
                    _buildSkeletonStatItem(),
                    if (index < 2) const Divider(height: AppDimensions.paddingXL),
                  ],
                ),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(child: _buildSkeletonStatItem()),
                const VerticalDivider(width: AppDimensions.paddingXL),
                Expanded(child: _buildSkeletonStatItem()),
                const VerticalDivider(width: AppDimensions.paddingXL),
                Expanded(child: _buildSkeletonStatItem()),
              ],
            ),
    );
  }

  Widget _buildSkeletonStatItem() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 14,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: AppDimensions.paddingS),
        Container(
          width: 100,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: AppDimensions.paddingS),
        Container(
          width: 60,
          height: 14,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorStats(BuildContext context, String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.orange, size: 40),
          const SizedBox(height: AppDimensions.paddingM),
          const Text(
            "Couldn't load investment stats",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingS),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingM),
          TextButton.icon(
            onPressed: () {
              context.read<InvestmentBloc>().add(LoadEnhancedTokens());
            },
            icon: const Icon(Icons.refresh),
            label: const Text("Retry"),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStats(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: isMobile
          ? Column(
              children: [
                _buildStatItem(
                  context: null,
                  title: "Portfolio Value",
                  value: "0.00 ETH",
                  changeText: "No investments yet",
                ),
                const Divider(height: AppDimensions.paddingXL),
                _buildStatItem(
                  context: null,
                  title: "Invested Capital",
                  value: "0.00 ETH",
                  changeText: "0 tokens",
                ),
                const Divider(height: AppDimensions.paddingXL),
                _buildStatItem(
                  context: null,
                  title: "Listed Value",
                  value: "0.00 ETH",
                  changeText: "0 tokens listed",
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: _buildStatItem(
                    context: null,
                    title: "Portfolio Value",
                    value: "0.00 ETH",
                    changeText: "No investments yet",
                  ),
                ),
                const VerticalDivider(width: AppDimensions.paddingXL),
                Expanded(
                  child: _buildStatItem(
                    context: null,
                    title: "Invested Capital",
                    value: "0.00 ETH",
                    changeText: "0 tokens",
                  ),
                ),
                const VerticalDivider(width: AppDimensions.paddingXL),
                Expanded(
                  child: _buildStatItem(
                    context: null,
                    title: "Listed Value",
                    value: "0.00 ETH",
                    changeText: "0 tokens listed",
                  ),
                ),
              ],
            ),
    );
  }
}