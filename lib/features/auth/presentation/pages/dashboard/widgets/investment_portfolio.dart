import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_boost/core/constants/colors.dart';
import 'package:the_boost/core/constants/dimensions.dart';
import 'package:the_boost/core/utils/responsive_helper.dart';
import 'package:the_boost/features/auth/domain/entities/token.dart';
import 'package:the_boost/features/auth/presentation/bloc/investment/investment_bloc.dart';

class InvestmentPortfolio extends StatefulWidget {
  const InvestmentPortfolio({Key? key}) : super(key: key);

  @override
  State<InvestmentPortfolio> createState() => _InvestmentPortfolioState();
}

class _InvestmentPortfolioState extends State<InvestmentPortfolio> {
  // Current date and user info
  final String currentDate = DateTime.now().toString();

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
              // Header section with title and date
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.paddingM,
                  AppDimensions.paddingM,
                  AppDimensions.paddingM,
                  0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Your Land Tokens",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    // Afficher la date actuelle au lieu du bouton
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundGreen,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.update,
                            color: AppColors.primary,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            currentDate,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 24),

              // Land items with sell buttons
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

    return Column(
      children: [
        InkWell(
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
        ),
        // Ajout du bouton de vente pour ce terrain spécifique
        Padding(
          padding: const EdgeInsets.only(
            left: AppDimensions.paddingL,
            right: AppDimensions.paddingL,
            bottom: AppDimensions.paddingM,
          ),
          child: SizedBox(
            width: double.infinity,
            child: ResponsiveHelper.isMobile(context)
                ? ElevatedButton.icon(
                    onPressed: () {
                      // Naviguer vers la page de vente
                      final formattedTokens =
                          _convertTokensToSellingFormat(tokens);
                      Navigator.pushNamed(
                        context,
                        '/token-selling',
                        arguments: {
                          'tokens': formattedTokens,
                          'selectedTokenIndex': 0,
                          'landName': land.title,
                        },
                      );
                    },
                    icon: const Icon(Icons.sell, size: 16),
                    label: const Text(
                        "Sell Tokens"), // Version plus courte pour mobile
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  )
                : ElevatedButton.icon(
                    onPressed: () {
                      // Naviguer vers la page de vente
                      final formattedTokens =
                          _convertTokensToSellingFormat(tokens);
                      Navigator.pushNamed(
                        context,
                        '/token-selling',
                        arguments: {
                          'tokens': formattedTokens,
                          'selectedTokenIndex': 0,
                          'landName': land.title,
                        },
                      );
                    },
                    icon: const Icon(Icons.sell, size: 16),
                    label:
                        Text("Sell ${land.title} Tokens"), // Version complète
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _convertTokensToSellingFormat(List<Token> tokens) {
    // Calculs de la valeur moyenne, etc.
    final referenceToken = tokens.first;
    final land = referenceToken.land;

    // Trier les tokens par ordre de valeur (du plus élevé au plus bas)
    tokens.sort((a, b) {
      final aPrice = double.tryParse(a.currentMarketInfo.price) ?? 0.0;
      final bPrice = double.tryParse(b.currentMarketInfo.price) ?? 0.0;
      return bPrice.compareTo(aPrice);
    });

    // Calculer le prix moyen par token
    final double avgPrice = _calculateAveragePrice(tokens);

    // Calculer le changement de prix (simulé pour l'exemple)
    final String priceChange = _calculatePriceChange(tokens);

    // Format map attendu par la page de vente
    return [
      {
        'id': 'TOK-${land.id}-${DateTime.now().year}',
        'name': land.title,
        'location': land.location,
        'totalTokens': 1000, // Si disponible
        'ownedTokens': tokens.length,
        'marketPrice': avgPrice,
        'imageUrl': land.imageUrl,
        'lastTraded': DateTime.now()
            .subtract(const Duration(days: 3))
            .toString()
            .substring(0, 10),
        'priceChange': priceChange,
        'actualTokens': tokens, // Les tokens réels pour traitement
      }
    ];
  }

  double _calculateAveragePrice(List<Token> tokens) {
    if (tokens.isEmpty) return 0.0;
    final totalValue = tokens.fold(
        0.0,
        (sum, token) =>
            sum + (double.tryParse(token.currentMarketInfo.price) ?? 0.0));
    return totalValue / tokens.length;
  }

  String _calculatePriceChange(List<Token> tokens) {
    // Dans une application réelle, calculez cela à partir de l'historique
    // Ici, nous simulons une légère fluctuation positive/négative
    final token = tokens.first;
    final currentPrice = double.tryParse(token.currentMarketInfo.price) ?? 0.0;
    final originalPrice = double.tryParse(token.purchaseInfo.price) ?? 0.0;

    if (originalPrice <= 0) return "+0.0%";

    final percentChange =
        ((currentPrice - originalPrice) / originalPrice) * 100;
    final direction = percentChange >= 0 ? "+" : "";
    return "$direction${percentChange.toStringAsFixed(1)}%";
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
        children: [
          // Loading header with date
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.paddingM,
              AppDimensions.paddingM,
              AppDimensions.paddingM,
              0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 120,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Container(
                  width: 150,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 24),

          // Loading items
          Column(
            children: List.generate(
              3,
              (index) => Column(
                children: [
                  // Token info
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
                  // Loading button
                  Padding(
                    padding: const EdgeInsets.only(
                      left: AppDimensions.paddingL,
                      right: AppDimensions.paddingL,
                      bottom: AppDimensions.paddingM,
                    ),
                    child: Container(
                      width: double.infinity,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  if (index < 2)
                    const Divider(height: 1, indent: 16, endIndent: 16),
                ],
              ),
            ),
          ),
        ],
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
          // Header section with title and date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Your Land Tokens",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.backgroundGreen,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.update,
                      color: AppColors.primary,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      currentDate,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingL),
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
