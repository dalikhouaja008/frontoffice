import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_boost/core/constants/colors.dart';
import 'package:the_boost/core/utils/responsive_helper.dart';
import 'package:the_boost/features/auth/presentation/pages/base_page.dart';
import 'package:intl/intl.dart';
import 'package:the_boost/features/auth/domain/entities/token.dart';
import 'package:the_boost/features/auth/presentation/bloc/investment/investment_bloc.dart';
import 'package:the_boost/features/auth/presentation/bloc/marketplace/marketplace_bloc.dart';
import 'package:the_boost/features/auth/presentation/bloc/marketplace/marketplace_event.dart';
import 'package:the_boost/features/auth/presentation/bloc/marketplace/marketplace_state.dart';
import 'package:the_boost/features/auth/presentation/pages/selling/widgets/hero_banner_widget.dart';
import 'package:the_boost/features/auth/presentation/pages/selling/widgets/sale_summary_widget.dart';
import 'package:the_boost/features/auth/presentation/pages/selling/widgets/success_dialog_widget.dart';
import 'package:the_boost/features/auth/presentation/pages/selling/widgets/token_selection_widget.dart';
import 'package:the_boost/features/auth/presentation/pages/selling/widgets/token_selling_form_widget.dart';
import 'package:the_boost/core/di/dependency_injection.dart';

class TokenSellingPage extends StatefulWidget {
  final List<Map<String, dynamic>>? preselectedTokens;
  final int initialSelectedIndex;
  final String landName;

  const TokenSellingPage({
    super.key,
    this.preselectedTokens,
    this.initialSelectedIndex = 0,
    this.landName = '',
  });

  @override
  _TokenSellingPageState createState() => _TokenSellingPageState();
}

class _TokenSellingPageState extends State<TokenSellingPage> {
  final TextEditingController _tokensToSellController = TextEditingController();
  final TextEditingController _pricePerTokenController =
      TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  double _totalAmount = 0;
  bool _termsAccepted = false;
  bool _isMarketPrice = true;
  String _selectedDuration = '7 days';
  int _selectedTokenIndex = 0;
  final formatter = NumberFormat("#,##0.00");
  bool _isProcessing = false;

  // Liste des tokens disponibles
  late List<Map<String, dynamic>> _ownedTokens;
  late MarketplaceBloc _marketplaceBloc;

  final List<String> _durations = [
    '1 day',
    '3 days',
    '7 days',
    '14 days',
    '30 days',
    'Until sold'
  ];

  @override
  void initState() {
    super.initState();
    _marketplaceBloc = getIt<MarketplaceBloc>();

    // Initialiser avec les tokens présélectionnés ou une liste vide
    _ownedTokens = widget.preselectedTokens ?? [];
    _selectedTokenIndex = widget.initialSelectedIndex;

    // Si pas de tokens présélectionnés, charger depuis le bloc
    if (_ownedTokens.isEmpty) {
      _loadTokensFromBloc();
    } else {
      _updateSelectedToken();
    }
  }

  void _loadTokensFromBloc() {
    final state = context.read<InvestmentBloc>().state;
    if (state is InvestmentLoaded) {
      _processTokensFromBloc(state.tokens);
    } else {
      // Demander le chargement des tokens si pas encore chargés
      context.read<InvestmentBloc>().add(LoadEnhancedTokens());
    }
  }

  void _processTokensFromBloc(List<Token> tokens) {
    if (tokens.isEmpty) {
      setState(() {
        _ownedTokens = [];
      });
      return;
    }

    print(
        '[2025-05-10 16:48:04] nesssim - Processing ${tokens.length} tokens from bloc');

    // 1. Filtrer les tokens non nuls et s'assurer qu'ils ne sont PAS listés
    final availableTokens = tokens.where((token) {
      // Vérifier si le token est non-null
      if (token == null) return false;

      // Vérifier explicitement si le token est listé (double vérification)
      bool isAvailableForSale = !token.isListed;

      // Vérifier aussi si listingInfo est null (token non listé)
      if (token.listingInfo != null) {
        isAvailableForSale = false;
      }

      // Vérifier si owner est "you" (tokens possédés, pas en vente sur marketplace)
      if (token.owner != "you") {
        isAvailableForSale = false;
      }

      print(
          '[2025-05-10 16:48:04] nesssim - Token #${token.tokenId}: isListed=${token.isListed}, '
          'has listingInfo=${token.listingInfo != null}, owner=${token.owner}, '
          'available for sale=$isAvailableForSale');

      return isAvailableForSale;
    }).toList();

    print(
        '[2025-05-10 16:48:04] nesssim - Found ${availableTokens.length} available tokens for selling');

    // Si aucun token valide, retourner une liste vide
    if (availableTokens.isEmpty) {
      setState(() {
        _ownedTokens = [];
      });
      return;
    }

    // Group by landId
    final Map<int, List<Token>> groupedTokens = {};
    for (final token in availableTokens) {
      if (token.landId != null) {
        if (!groupedTokens.containsKey(token.landId)) {
          groupedTokens[token.landId] = [];
        }
        groupedTokens[token.landId]!.add(token);
      }
    }

    print(
        '[2025-05-10 16:48:04] nesssim - Grouped tokens into ${groupedTokens.length} lands');

    // Process tokens into the required format
    final processedTokens = groupedTokens.entries
        .map((entry) {
          try {
            final landId = entry.key;
            final tokensForLand = entry.value;

            // S'assurer que tokensForLand n'est pas vide
            if (tokensForLand.isEmpty) return null;

            final referenceToken = tokensForLand.first;

            // Déclarer land en dehors pour pouvoir le rechercher parmi tous les tokens
            var land = referenceToken.land;

            // Si land est null, chercher parmi tous les tokens originaux qui ont ce landId
            if (land == null) {
              for (var token in tokens) {
                if (token.landId == landId && token.land != null) {
                  land = token.land;
                  break;
                }
              }
            }

            // S'il n'y a toujours pas d'infos sur le terrain, utiliser des valeurs par défaut
            final landTitle = land?.title ?? 'Land #$landId';
            final landLocation = land?.location ?? 'Unknown Location';
            final landImageUrl = land?.imageUrl ?? 'assets/1.jpg';

            // Calculate average market price with null safety
            double avgPrice = 0.0;
            int validTokenCount = 0;

            for (var token in tokensForLand) {
              if (token.currentMarketInfo != null &&
                  token.currentMarketInfo.price != null) {
                final price =
                    double.tryParse(token.currentMarketInfo.price) ?? 0.0;
                if (price > 0) {
                  avgPrice += price;
                  validTokenCount++;
                }
              }
            }

            // Diviser par le nombre de tokens valides ou retourner 0
            avgPrice = validTokenCount > 0 ? avgPrice / validTokenCount : 0.0;

            // Extract actual tokenIds for API call
            final tokenIds = tokensForLand
                .map((t) => t.tokenId)
                .where((id) => id != null)
                .toList();

            print('Processed land #$landId: '
                '${tokensForLand.length} tokens, avgPrice=$avgPrice');

            // Créer la structure finalisée avec des valeurs par défaut
            return {
              'id': 'TOK-$landId-2025',
              'name': landTitle,
              'location': landLocation,
              'totalTokens':
                  land?.totalTokens ?? 1000, // Default value if not available
              'ownedTokens':
                  tokensForLand.length, // Uniquement les tokens disponibles
              'marketPrice': avgPrice,
              'imageUrl': landImageUrl,
              'actualTokens': tokensForLand,
              'tokenIds': tokenIds,
            };
          } catch (e) {
            print(
                'Error processing token group: $e');
            return null;
          }
        })
        .where((token) => token != null)
        .cast<Map<String, dynamic>>()
        .toList();

    print(
        'Final result: ${processedTokens.length} token groups ready for selling');

    setState(() {
      _ownedTokens = processedTokens;
    });

    if (_ownedTokens.isNotEmpty) {
      _updateSelectedToken();
    }
  }

  void _updateSelectedToken() {
    if (_ownedTokens.isEmpty) return;

    final token = _ownedTokens[_selectedTokenIndex];
    _pricePerTokenController.text = formatter.format(token['marketPrice']);
    _tokensToSellController.text = '';
    _calculateTotal();
  }

  void _calculateTotal() {
    final tokensToSell = double.tryParse(_tokensToSellController.text) ?? 0;
    final pricePerToken =
        double.tryParse(_pricePerTokenController.text.replaceAll(',', '')) ?? 0;
    setState(() {
      _totalAmount = tokensToSell * pricePerToken;
    });
  }

  void _handleSelectToken(int index) {
    setState(() {
      _selectedTokenIndex = index;
      _updateSelectedToken();
    });
  }

  void _handleTokensChange(String value) {
    _calculateTotal();
  }

  void _handlePriceChange(String value) {
    _calculateTotal();
  }

  void _incrementTokens() {
    final currentValue = int.tryParse(_tokensToSellController.text) ?? 0;
    final maxValue = _ownedTokens.isNotEmpty
        ? _ownedTokens[_selectedTokenIndex]['ownedTokens']
        : 0;
    if (currentValue < maxValue) {
      _tokensToSellController.text = (currentValue + 1).toString();
      _calculateTotal();
    }
  }

  void _decrementTokens() {
    final currentValue = int.tryParse(_tokensToSellController.text) ?? 0;
    if (currentValue > 0) {
      _tokensToSellController.text = (currentValue - 1).toString();
      _calculateTotal();
    }
  }

  void _toggleMarketPrice(bool? value) {
    setState(() {
      _isMarketPrice = value ?? false;
      if (_isMarketPrice && _ownedTokens.isNotEmpty) {
        _pricePerTokenController.text =
            formatter.format(_ownedTokens[_selectedTokenIndex]['marketPrice']);
        _calculateTotal();
      }
    });
  }

  void _handleDurationChange(String? value) {
    if (value != null) {
      setState(() {
        _selectedDuration = value;
      });
    }
  }

  void _handleTermsAccepted(bool? value) {
    setState(() {
      _termsAccepted = value ?? false;
    });
  }

  void _handleTokenSale() {
    if (_ownedTokens.isEmpty) return;

    final token = _ownedTokens[_selectedTokenIndex];
    final tokenCount = int.tryParse(_tokensToSellController.text) ?? 0;

    if (tokenCount <= 0) {
      _showErrorMessage('Please enter a valid quantity of tokens to sell');
      return;
    }

    // Vérifions que l'utilisateur ne tente pas de vendre plus de tokens qu'il ne possède
    final availableTokens = token['ownedTokens'] ?? 0;
    if (tokenCount > availableTokens) {
      _showErrorMessage(
          'You cannot sell more tokens than you own (max: $availableTokens)');
      return;
    }

    final price = _pricePerTokenController.text.replaceAll(',', '');
    if (double.tryParse(price) == null || double.tryParse(price)! <= 0) {
      _showErrorMessage('Please enter a valid price');
      return;
    }

    print(
        'Tentative de mise en vente de $tokenCount tokens au prix de $price ETH');

    // Si tout est bon, procéder avec la vente
    setState(() {
      _isProcessing = true;
    });

    // Sélection intelligente: listToken ou listMultipleTokens selon le nombre de tokens
    if (tokenCount == 1) {
      // Si un seul token, utiliser la fonction simple listToken
      final tokenId = token['actualTokens'][0].tokenId;
      print(' Utilisation de listToken pour token #$tokenId');

      _marketplaceBloc.add(ListTokenEvent(tokenId: tokenId, price: price));
    } else {
      // Si plusieurs tokens, utiliser listMultipleTokens
      final List<int> tokenIds = [];
      final List<String> prices = [];

      // Préparer les listes de tokenIds et prix
      for (int i = 0; i < tokenCount; i++) {
        if (i < token['actualTokens'].length) {
          tokenIds.add(token['actualTokens'][i].tokenId);
          prices.add(price);
        }
      }

      if (tokenIds.isEmpty) {
        setState(() {
          _isProcessing = false;
        });
        _showErrorMessage('No valid tokens selected');
        return;
      }

      print('Utilisation de listMultipleTokens pour ${tokenIds.length} tokens');

      _marketplaceBloc
          .add(ListMultipleTokensEvent(tokenIds: tokenIds, prices: prices));
    }
  }

  void _saveDraft() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Brouillon sauvegardé avec succès'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _marketplaceBloc),
      ],
      child: MultiBlocListener(
        listeners: [
          // Écouter les mises à jour du bloc Investment
          BlocListener<InvestmentBloc, InvestmentState>(
            listener: (context, state) {
              if (state is InvestmentLoaded && _ownedTokens.isEmpty) {
                _processTokensFromBloc(state.tokens);
              }
            },
          ),
          // Écouter les réponses du bloc Marketplace
          BlocListener<MarketplaceBloc, MarketplaceState>(
            listener: (context, state) {
              if (state is MarketplaceLoading) {
                // No additional handling needed here as we have a local isProcessing state
              } else if (state is TokenListingSuccess) {
                setState(() {
                  _isProcessing = false;
                });
                _showSuccessDialog();
              } else if (state is MultipleTokensListingSuccess) {
                setState(() {
                  _isProcessing = false;
                });
                _showSuccessDialog();
              } else if (state is MarketplaceError) {
                setState(() {
                  _isProcessing = false;
                });
                _showErrorMessage('Erreur: ${state.message}');
              }
            },
          ),
        ],
        child: BasePage(
          title: widget.landName.isNotEmpty
              ? 'Sell ${widget.landName} Tokens'
              : 'Sell Tokens',
          currentRoute: '/token-selling',
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                widget.landName.isNotEmpty
                    ? _buildContextualHeroBanner(widget.landName)
                    : const HeroBannerWidget(),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.landName.isNotEmpty
                            ? 'Sell Your ${widget.landName} Tokens'
                            : 'Select Tokens to Sell',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                      ),
                      const SizedBox(height: 16),

                      // Section de sélection de token (n'afficher que si nous n'avons pas de terrain présélectionné)
                      if (widget.landName.isEmpty || _ownedTokens.length > 1)
                        TokenSelectionWidget(
                          tokens: _ownedTokens,
                          selectedIndex: _selectedTokenIndex,
                          onTokenSelected: _handleSelectToken,
                          formatter: formatter,
                        ),

                      const SizedBox(height: 32),

                      if (_ownedTokens.isNotEmpty)
                        if (isDesktop || isTablet)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: Column(
                                  children: [
                                    TokenSellingFormWidget(
                                      tokensToSellController:
                                          _tokensToSellController,
                                      pricePerTokenController:
                                          _pricePerTokenController,
                                      descriptionController:
                                          _descriptionController,
                                      selectedToken:
                                          _ownedTokens[_selectedTokenIndex],
                                      durations: _durations,
                                      selectedDuration: _selectedDuration,
                                      isMarketPrice: _isMarketPrice,
                                      currentDate: '',
                                      username: '',
                                      formatter: formatter,
                                      totalAmount: _totalAmount,
                                      onTokensChanged: _handleTokensChange,
                                      onPriceChanged: _handlePriceChange,
                                      onIncrementTokens: _incrementTokens,
                                      onDecrementTokens: _decrementTokens,
                                      onMarketPriceToggled: _toggleMarketPrice,
                                      onDurationChanged: _handleDurationChange,
                                    ),

                                    // Ajouter l'analyse de prix et transactions récentes si un terrain est présélectionné
                                    if (widget.landName.isNotEmpty) ...[
                                      const SizedBox(height: 24),
                                      _buildPriceAnalysis(
                                        double.tryParse(_pricePerTokenController
                                                .text
                                                .replaceAll(',', '')) ??
                                            0,
                                        _ownedTokens[_selectedTokenIndex]
                                            ['marketPrice'],
                                      ),
                                      const SizedBox(height: 24),
                                      _buildRecentTransactions(widget.landName),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                flex: 2,
                                child: Stack(
                                  children: [
                                    SaleSummaryWidget(
                                      selectedToken:
                                          _ownedTokens[_selectedTokenIndex],
                                      tokensToSell: double.tryParse(
                                              _tokensToSellController.text) ??
                                          0,
                                      pricePerToken: double.tryParse(
                                              _pricePerTokenController.text
                                                  .replaceAll(',', '')) ??
                                          0,
                                      selectedDuration: _selectedDuration,
                                      totalAmount: _totalAmount,
                                      termsAccepted: _termsAccepted,
                                      formatter: formatter,
                                      onTermsAccepted: _handleTermsAccepted,
                                      onSellPressed: _isProcessing
                                          ? null
                                          : _handleTokenSale,
                                      onCancelPressed: () =>
                                          Navigator.pop(context),
                                      onSaveDraftPressed: _saveDraft,
                                    ),
                                    if (_isProcessing)
                                      Positioned.fill(
                                        child: Container(
                                          color: Colors.white.withOpacity(0.7),
                                          child: const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        else
                          Column(
                            children: [
                              TokenSellingFormWidget(
                                tokensToSellController: _tokensToSellController,
                                pricePerTokenController:
                                    _pricePerTokenController,
                                descriptionController: _descriptionController,
                                selectedToken:
                                    _ownedTokens[_selectedTokenIndex],
                                durations: _durations,
                                selectedDuration: _selectedDuration,
                                isMarketPrice: _isMarketPrice,
                                currentDate: '',
                                username: '',
                                formatter: formatter,
                                totalAmount: _totalAmount,
                                onTokensChanged: _handleTokensChange,
                                onPriceChanged: _handlePriceChange,
                                onIncrementTokens: _incrementTokens,
                                onDecrementTokens: _decrementTokens,
                                onMarketPriceToggled: _toggleMarketPrice,
                                onDurationChanged: _handleDurationChange,
                              ),

                              // Ajouter l'analyse de prix et transactions récentes si un terrain est présélectionné
                              if (widget.landName.isNotEmpty) ...[
                                const SizedBox(height: 24),
                                _buildPriceAnalysis(
                                  double.tryParse(_pricePerTokenController.text
                                          .replaceAll(',', '')) ??
                                      0,
                                  _ownedTokens[_selectedTokenIndex]
                                      ['marketPrice'],
                                ),
                                const SizedBox(height: 24),
                                _buildRecentTransactions(widget.landName),
                              ],

                              const SizedBox(height: 24),
                              Stack(
                                children: [
                                  SaleSummaryWidget(
                                    selectedToken:
                                        _ownedTokens[_selectedTokenIndex],
                                    tokensToSell: double.tryParse(
                                            _tokensToSellController.text) ??
                                        0,
                                    pricePerToken: double.tryParse(
                                            _pricePerTokenController.text
                                                .replaceAll(',', '')) ??
                                        0,
                                    selectedDuration: _selectedDuration,
                                    totalAmount: _totalAmount,
                                    termsAccepted: _termsAccepted,
                                    formatter: formatter,
                                    onTermsAccepted: _handleTermsAccepted,
                                    onSellPressed:
                                        _isProcessing ? null : _handleTokenSale,
                                    onCancelPressed: () =>
                                        Navigator.pop(context),
                                    onSaveDraftPressed: _saveDraft,
                                  ),
                                  if (_isProcessing)
                                    Positioned.fill(
                                      child: Container(
                                        color: Colors.white.withOpacity(0.7),
                                        child: const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          )
                      // Afficher un état de chargement si pas encore de tokens
                      else
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    final tokenCount = int.tryParse(_tokensToSellController.text) ?? 0;
    final price =
        double.tryParse(_pricePerTokenController.text.replaceAll(',', '')) ?? 0;

    if (_ownedTokens.isEmpty) return;
    final token = _ownedTokens[_selectedTokenIndex];

    // Show success dialog
    showDialog(
      context: context,
      builder: (context) => TokenSaleSuccessDialog(
        tokenName: token['name'],
        tokenCount: tokenCount,
        price: price,
        totalAmount: _totalAmount,
        selectedDuration: _selectedDuration,
        formatter: formatter,
      ),
    ).then((_) {
      // Refresh the investment data after successful listing
      context.read<InvestmentBloc>().add(LoadEnhancedTokens());

      // Navigate back to the dashboard after a short delay
      Future.delayed(const Duration(milliseconds: 300), () {
        Navigator.of(context).pop();
      });
    });
  }

  Widget _buildContextualHeroBanner(String landName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.9),
            AppColors.primaryDark,
          ],
        ),
        image: DecorationImage(
          image: AssetImage(_ownedTokens.isNotEmpty
              ? _ownedTokens[_selectedTokenIndex]['imageUrl']
              : 'assets/1.jpg'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.5),
            BlendMode.darken,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Sell Your $landName Tokens',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Convert your investment in $landName into liquidity by selling tokens on our secure marketplace with transparent fees and instant settlements',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildInfoCard(Icons.security, 'Secure Transactions'),
              const SizedBox(width: 16),
              _buildInfoCard(Icons.speed, 'Fast Settlement'),
              const SizedBox(width: 16),
              _buildInfoCard(Icons.supervised_user_circle, 'Verified Buyers'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceAnalysis(double userPrice, double marketPrice) {
    final priceDifference = ((userPrice - marketPrice) / marketPrice) * 100;
    final bool isHigher = userPrice > marketPrice;

    Color statusColor;
    String message;
    IconData icon;

    if (priceDifference.abs() < 1.0) {
      // Prix proche du marché (moins de 1% de différence)
      statusColor = Colors.green;
      message = "Your price is aligned with the market";
      icon = Icons.check_circle;
    } else if (isHigher && priceDifference > 10.0) {
      // Prix beaucoup plus élevé que le marché
      statusColor = Colors.orange;
      message =
          "Your price is significantly above market rate (${priceDifference.toStringAsFixed(1)}%)";
      icon = Icons.warning;
    } else if (isHigher) {
      // Prix plus élevé que le marché (mais pas trop)
      statusColor = Colors.blue;
      message =
          "Your price is above market rate (${priceDifference.toStringAsFixed(1)}%)";
      icon = Icons.info;
    } else if (!isHigher && priceDifference.abs() > 10.0) {
      // Prix beaucoup plus bas que le marché
      statusColor = Colors.red;
      message =
          "Your price is significantly below market value (${priceDifference.abs().toStringAsFixed(1)}%)";
      icon = Icons.warning;
    } else {
      // Prix plus bas que le marché (mais pas trop)
      statusColor = Colors.orange;
      message =
          "Your price is below market value (${priceDifference.abs().toStringAsFixed(1)}%)";
      icon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: statusColor, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: statusColor,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
Widget _buildRecentTransactions(String landName) {
  // Écouteur pour obtenir les tokens depuis le bloc
  return BlocBuilder<InvestmentBloc, InvestmentState>(
    builder: (context, state) {
      if (state is InvestmentLoaded || state is InvestmentRefreshing) {
        // Extraire les tokens du state
        final tokens = state is InvestmentLoaded 
            ? state.tokens 
            : (state as InvestmentRefreshing).tokens;
        
        // Filtrer pour le terrain spécifique
        final landTokens = tokens.where((token) => 
            token.land != null && token.land!.title == landName).toList();
        
        // Si pas de tokens pour ce terrain, afficher un message
        if (landTokens.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.history, size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Recent $landName Transactions',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'No recent transactions found',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        
        // Trier par date d'achat (plus récent en premier)
        landTokens.sort((a, b) => b.purchaseInfo.date.compareTo(a.purchaseInfo.date));
        
        // Limiter à 3 transactions les plus récentes
        final recentTokens = landTokens.take(3).toList();
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.history, size: 18, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Recent $landName Transactions',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Table(
                columnWidths: const {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(2),
                  2: FlexColumnWidth(1),
                },
                children: [
                  const TableRow(
                    children: [
                      Text('Date',
                          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
                      Text('Price',
                          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
                      Text('Type',
                          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
                    ],
                  ),
                  ...recentTokens.map((token) => TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Text(token.purchaseInfo.date.toString().substring(0, 10),
                            style: const TextStyle(fontSize: 12)),
                      ),
                      Text(token.purchaseInfo.formattedPrice,
                          style: const TextStyle(fontSize: 12)),
                      const Text(
                        'PURCHASE',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )).toList(),
                ],
              ),
            ],
          ),
        );
      } else {
        // État de chargement ou d'erreur
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.history, size: 18, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Recent $landName Transactions',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Loading transaction data...',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    },
  );
}
  @override
  void dispose() {
    _tokensToSellController.dispose();
    _pricePerTokenController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
