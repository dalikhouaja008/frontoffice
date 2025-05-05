import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_boost/core/constants/colors.dart';
import 'package:the_boost/core/constants/dimensions.dart';
import 'package:the_boost/core/di/dependency_injection.dart';
import 'package:the_boost/core/utils/responsive_helper.dart';
import 'package:the_boost/features/auth/domain/entities/token.dart';
import 'package:the_boost/features/auth/presentation/bloc/investment/investment_bloc.dart';
import 'package:the_boost/features/auth/presentation/bloc/marketplace/marketplace_bloc.dart';
import 'package:the_boost/features/auth/presentation/bloc/marketplace/marketplace_event.dart';
import 'package:the_boost/features/auth/presentation/bloc/marketplace/marketplace_state.dart';

class InvestmentPortfolio extends StatefulWidget {
  const InvestmentPortfolio({Key? key}) : super(key: key);

  @override
  State<InvestmentPortfolio> createState() => _InvestmentPortfolioState();
}

class _InvestmentPortfolioState extends State<InvestmentPortfolio> {
  // Current date and user info
  final String currentDate = '2025-05-04 23:34:11';
  final String userName = 'nesssim';
  
  // Marketplace bloc pour gérer l'annulation des listings
  late final MarketplaceBloc _marketplaceBloc;
  bool _processingCancelation = false;
  int? _cancelingTokenId;

  @override
  void initState() {
    super.initState();
    _marketplaceBloc = getIt<MarketplaceBloc>();
    
    print('[$currentDate] InvestmentPortfolio: ✨ Initializing'
        '\n└─ User: $userName');
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _marketplaceBloc,
      child: BlocListener<MarketplaceBloc, MarketplaceState>(
        listener: (context, state) {
          _handleMarketplaceState(context, state);
        },
        child: BlocBuilder<InvestmentBloc, InvestmentState>(
          builder: (context, state) {
            if (state is InvestmentLoading) {
              return _buildLoadingPortfolio();
            } else if (state is InvestmentError) {
              return _buildErrorPortfolio(state.message);
            } else if (state is InvestmentLoaded) {
              return _buildPortfolio(context, state.tokens);
            } else if (state is InvestmentRefreshing) {
              return _buildPortfolio(context, state.tokens, isRefreshing: true);
            } else {
              return _buildEmptyPortfolio();
            }
          },
        ),
      ),
    );
  }

  void _handleMarketplaceState(BuildContext context, MarketplaceState state) {
    setState(() {
      _processingCancelation = state is MarketplaceLoading;
    });

    if (state is CancelListingSuccess) {
      setState(() {
        _cancelingTokenId = null;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Token listing has been successfully cancelled',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );

      // Rafraîchir les données des tokens
      context.read<InvestmentBloc>().add(LoadEnhancedTokens());
      
      print('[$currentDate] InvestmentPortfolio: ✅ Listing cancelled successfully'
          '\n└─ User: $userName'
          '\n└─ Token ID: $_cancelingTokenId');
    } else if (state is MarketplaceError) {
      setState(() {
        _cancelingTokenId = null;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Error cancelling listing: ${state.message}',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
      
      print('[$currentDate] InvestmentPortfolio: ❌ Error cancelling listing'
          '\n└─ User: $userName'
          '\n└─ Token ID: $_cancelingTokenId'
          '\n└─ Error: ${state.message}');
    }
  }

  Widget _buildPortfolio(BuildContext context, List<Token> tokens, {bool isRefreshing = false}) {
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
                    // Afficher la date actuelle
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
                    _buildLandItem(context, displayLands[i].key, displayLands[i].value),
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
        if (isRefreshing || _processingCancelation)
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

  Widget _buildLandItem(BuildContext context, int landId, List<Token> tokens) {
    // Prendre le premier token comme référence pour les infos du terrain
    final Token referenceToken = tokens.first;
    final land = referenceToken.land;

    // Calculer le nombre total de tokens et la valeur combinée
    final int tokenCount = tokens.length;
    final double totalValue = tokens.fold(
        0.0,
        (sum, token) =>
            sum + (double.tryParse(token.currentMarketInfo.price) ?? 0.0));
    final double totalOriginalValue = tokens.fold(
        0.0,
        (sum, token) =>
            sum + (double.tryParse(token.purchaseInfo.price) ?? 0.0));

    // Calculer le profit/perte global
    final double profitLoss = totalValue - totalOriginalValue;
    final double profitLossPercentage =
        totalOriginalValue > 0 ? (profitLoss / totalOriginalValue) * 100 : 0.0;

    // Formater les valeurs
    final formattedTotalValue = "${totalValue.toStringAsFixed(4)} ETH";
    final formattedProfitLoss =
        "${profitLoss >= 0 ? '+' : ''}${profitLoss.toStringAsFixed(4)} ETH";
    final formattedPercentage =
        "${profitLossPercentage >= 0 ? '+' : ''}${profitLossPercentage.toStringAsFixed(2)}%";

    // Est-ce qu'un token de ce terrain est mis en vente?
    final bool anyListed = tokens.any((token) => token.isListed);
    
    // Récupérer les tokens mis en vente
    final listedTokens = tokens.where((token) => token.isListed).toList();

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
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                "${listedTokens.length} Listed",
                                style: const TextStyle(
                                  color: Colors.orange,
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
        
        // Boutons d'action
        Padding(
          padding: const EdgeInsets.only(
            left: AppDimensions.paddingL,
            right: AppDimensions.paddingL,
            bottom: AppDimensions.paddingM,
          ),
          child: Row(
            children: [
              // Bouton de vente
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Naviguer vers la page de vente
                    final formattedTokens = _convertTokensToSellingFormat(tokens);
                    Navigator.pushNamed(
                      context,
                      '/token-selling',
                      arguments: {
                        'tokens': formattedTokens,
                        'selectedTokenIndex': 0,
                        'landName': land.title,
                      },
                    );
                    
                    print('[$currentDate] InvestmentPortfolio: 🔄 Navigating to token selling page'
                        '\n└─ User: $userName'
                        '\n└─ Land: ${land.title}'
                        '\n└─ Total Tokens: $tokenCount');
                  },
                  icon: const Icon(Icons.sell, size: 16),
                  label: Text(ResponsiveHelper.isMobile(context) 
                      ? "Sell" 
                      : "Sell Tokens"),
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
              
              // N'afficher le bouton d'annulation que si des tokens sont mis en vente
              if (anyListed) ...[
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: ElevatedButton.icon(
                    onPressed: _processingCancelation 
                        ? null 
                        : () {
                            _showCancelListingDialog(context, listedTokens);
                          },
                    icon: const Icon(Icons.cancel, size: 16),
                    label: Text(ResponsiveHelper.isMobile(context) 
                        ? "Cancel Listing" 
                        : "Cancel ${listedTokens.length} Listing${listedTokens.length > 1 ? 's' : ''}"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      disabledBackgroundColor: Colors.grey,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _showCancelListingDialog(BuildContext context, List<Token> listedTokens) {
    print('[$currentDate] InvestmentPortfolio: 📋 Showing cancel listing dialog'
        '\n└─ User: $userName'
        '\n└─ Listed Tokens: ${listedTokens.length}');
        
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Token Listing'),
        content: SizedBox(
          width: double.maxFinite,
          child: listedTokens.length == 1
              ? Text('Are you sure you want to cancel the listing for token #${listedTokens[0].tokenNumber}?\n\nListed price: ${listedTokens[0].listingInfo?.formattedPrice ?? "0 ETH"}')
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Select token listing${listedTokens.length > 1 ? 's' : ''} to cancel:'),
                    const SizedBox(height: 12),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: listedTokens.length,
                        itemBuilder: (context, index) {
                          final token = listedTokens[index];
                          return ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.token, color: AppColors.primary),
                            title: Text('#${token.tokenNumber}'),
                            subtitle: Text('Listed for: ${token.listingInfo?.formattedPrice ?? "0 ETH"}'),
                            trailing: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _cancelTokenListing(token.tokenId);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                textStyle: const TextStyle(fontSize: 12),
                              ),
                              child: const Text('Cancel'),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
        ),
        actions: [
          if (listedTokens.length == 1) ...[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _cancelTokenListing(listedTokens[0].tokenId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Yes, Cancel Listing'),
            ),
          ] else
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
        ],
      ),
    );
  }

  void _cancelTokenListing(int tokenId) {
    print('[$currentDate] InvestmentPortfolio: 🚫 Cancelling listing for token #$tokenId'
        '\n└─ User: $userName');
    
    setState(() {
      _cancelingTokenId = tokenId;
      _processingCancelation = true;
    });
    
    _marketplaceBloc.add(CancelListingEvent(tokenId: tokenId));
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
              
              print('[$currentDate] InvestmentPortfolio: 🔄 Retrying to load tokens'
                  '\n└─ User: $userName');
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
              
              print('[$currentDate] InvestmentPortfolio: 🔄 Navigating to invest page'
                  '\n└─ User: $userName');
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