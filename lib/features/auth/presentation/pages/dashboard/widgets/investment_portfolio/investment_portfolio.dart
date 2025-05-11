import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_boost/core/constants/colors.dart';
import 'package:the_boost/core/constants/dimensions.dart';
import 'package:the_boost/core/di/dependency_injection.dart';
import 'package:the_boost/features/auth/domain/entities/token.dart';
import 'package:the_boost/features/auth/presentation/bloc/investment/investment_bloc.dart';
import 'package:the_boost/features/auth/presentation/bloc/marketplace/marketplace_bloc.dart';
import 'package:the_boost/features/auth/presentation/bloc/marketplace/marketplace_event.dart';
import 'package:the_boost/features/auth/presentation/bloc/marketplace/marketplace_state.dart';
import 'portfolio_header_widget.dart';
import 'land_item_widget.dart';
import 'empty_portfolio_widget.dart';
import 'loading_portfolio_widget.dart';
import 'error_portfolio_widget.dart';

class InvestmentPortfolio extends StatefulWidget {
  const InvestmentPortfolio({super.key});

  @override
  State<InvestmentPortfolio> createState() => _InvestmentPortfolioState();
}

class _InvestmentPortfolioState extends State<InvestmentPortfolio> {
  // Current date and user info
  final String currentDate = '2025-05-10 17:19:09';
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
              return const LoadingPortfolioWidget();
            } else if (state is InvestmentError) {
              return ErrorPortfolioWidget(
                message: state.message,
                onRetry: () => context.read<InvestmentBloc>().add(LoadEnhancedTokens()),
                currentDate: currentDate,
                userName: userName,
              );
            } else if (state is InvestmentLoaded) {
              return _buildPortfolio(context, state.tokens);
            } else if (state is InvestmentRefreshing) {
              return _buildPortfolio(context, state.tokens, isRefreshing: true);
            } else {
              return EmptyPortfolioWidget(
                currentDate: currentDate,
                userName: userName,
              );
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
        const SnackBar(
          content: Row(
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
          duration: Duration(seconds: 3),
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
      return EmptyPortfolioWidget(
        currentDate: currentDate,
        userName: userName,
      );
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
              PortfolioHeaderWidget(currentDate: currentDate),
              const Divider(height: 24),

              // Land items with sell buttons
              for (int i = 0; i < displayLands.length; i++)
                Column(
                  children: [
                    LandItemWidget(
                      landId: displayLands[i].key,
                      tokens: displayLands[i].value,
                      onCancelListing: _cancelTokenListing,
                      onShowCancelDialog: _showCancelListingDialog,
                      currentDate: currentDate,
                      userName: userName,
                    ),
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
}