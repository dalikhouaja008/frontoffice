import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_boost/core/constants/colors.dart';
import 'package:the_boost/core/constants/dimensions.dart';
import 'package:the_boost/features/auth/domain/entities/token.dart';
import 'package:the_boost/features/auth/presentation/bloc/investment/investment_bloc.dart';

class InvestmentPortfolio extends StatefulWidget {
  const InvestmentPortfolio({Key? key}) : super(key: key);

  @override
  State<InvestmentPortfolio> createState() => _InvestmentPortfolioState();
}

class _InvestmentPortfolioState extends State<InvestmentPortfolio> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InvestmentBloc, InvestmentState>(
      builder: (context, state) {
        if (state is InvestmentLoading) {
          return _buildLoadingPortfolio();
        } else if (state is InvestmentError) {
          return _buildErrorPortfolio(state.message);
        } else if (state is InvestmentLoaded) {
          return _buildPortfolio(state.tokens);
        } else if (state is InvestmentRefreshing) {
          return _buildPortfolio(state.tokens, isRefreshing: true);
        } else {
          return _buildEmptyPortfolio();
        }
      },
    );
  }

  Widget _buildPortfolio(List<Token> tokens, {bool isRefreshing = false}) {
    if (tokens.isEmpty) {
      return _buildEmptyPortfolio();
    }

    // Group tokens by landId
    final Map<int, List<Token>> groupedTokens = {};
    for (final token in tokens) {
      if (!groupedTokens.containsKey(token.landId)) {
        groupedTokens[token.landId] = [];
      }
      groupedTokens[token.landId]!.add(token);
    }

    // Sort lands by total value
    final sortedLands = groupedTokens.entries.toList()
      ..sort((a, b) {
        final aTotal = a.value.fold(
            0.0,
            (sum, token) =>
                sum + (double.tryParse(token.currentMarketInfo.price) ?? 0.0));
        final bTotal = b.value.fold(
            0.0,
            (sum, token) =>
                sum + (double.tryParse(token.currentMarketInfo.price) ?? 0.0));
        return bTotal.compareTo(aTotal); // Sort descending
      });

    // Display top 3 or fewer lands
    final displayLands = sortedLands.take(3).toList();

    return Stack(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              for (int i = 0; i < displayLands.length; i++)
                Column(
                  children: [
                    _buildLandItem(displayLands[i].key, displayLands[i].value),
                    if (i < displayLands.length - 1)
                      const Divider(height: 1, indent: 16, endIndent: 16),
                  ],
                ),
              Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/investments');
                  },
                  child: const Text(
                    "View All Investments",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (isRefreshing)
          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(0.7),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLandItem(int landId, List<Token> tokens) {
    // Take first token as reference for land info
    final Token referenceToken = tokens.first;
    final land = referenceToken.land;

    // Calculate total tokens and combined value
    final int tokenCount = tokens.length;
    final double totalValue = tokens.fold(
        0.0,
        (sum, token) =>
            sum + (double.tryParse(token.currentMarketInfo.price) ?? 0.0));
    final double totalOriginalValue = tokens.fold(
        0.0,
        (sum, token) =>
            sum + (double.tryParse(token.purchaseInfo.price) ?? 0.0));

    // Calculate overall profit/loss
    final double profitLoss = totalValue - totalOriginalValue;
    final double profitLossPercentage =
        totalOriginalValue > 0 ? (profitLoss / totalOriginalValue) * 100 : 0.0;

    // Format values
    final formattedTotalValue = "${totalValue.toStringAsFixed(4)} ETH";
    final formattedProfitLoss =
        "${profitLoss >= 0 ? '+' : ''}${profitLoss.toStringAsFixed(4)} ETH";
    final formattedPercentage =
        "${profitLossPercentage >= 0 ? '+' : ''}${profitLossPercentage.toStringAsFixed(2)}%";

    // Is any token from this land listed?
    final bool anyListed = tokens.any((token) => token.isListed);

    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/land',
          arguments: landId,
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Row(
          children: [
            _buildLandImage(land.imageUrl),
            const SizedBox(width: AppDimensions.paddingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    land.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 12,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          land.location,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        "$tokenCount tokens owned",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      if (anyListed)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            "Some Listed",
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formattedTotalValue,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      profitLoss >= 0
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                      color: profitLoss >= 0 ? Colors.green : Colors.red,
                      size: 16,
                    ),
                    Text(
                      formattedPercentage,
                      style: TextStyle(
                        color: profitLoss >= 0 ? Colors.green : Colors.red,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLandImage(String? imageUrl) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          imageUrl,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholderImage();
          },
        ),
      );
    }
    return _buildPlaceholderImage();
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.home,
        color: AppColors.primary,
        size: 24,
      ),
    );
  }

  Widget _buildLoadingPortfolio() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: List.generate(
          3,
          (index) => Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.paddingM),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 120,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 80,
                            height: 14,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 60,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 60,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 40,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (index < 2)
                const Divider(height: 1, indent: 16, endIndent: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorPortfolio(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.orange,
            size: 40,
          ),
          const SizedBox(height: AppDimensions.paddingS),
          const Text(
            "Couldn't load your investments",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingXS),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingM),
          TextButton.icon(
            onPressed: () {
              context.read<InvestmentBloc>().add(LoadEnhancedTokens());
            },
            icon: const Icon(Icons.refresh),
            label: const Text("Try Again"),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyPortfolio() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.account_balance,
            color: Colors.grey[400],
            size: 40,
          ),
          const SizedBox(height: AppDimensions.paddingM),
          const Text(
            "No investments yet",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingS),
          Text(
            "Start investing in properties to build your portfolio",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingL),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/invest');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text("Discover Properties"),
          ),
        ],
      ),
    );
  }
}
