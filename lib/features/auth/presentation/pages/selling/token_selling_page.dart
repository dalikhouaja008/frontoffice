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

  // Current date and username from requirements
  final String currentDate = "2025-05-04 20:14:53";

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

    // Filter tokens that are not already listed
    final nonListedTokens = tokens.where((token) => !token.isListed).toList();

    // Group by landId
    final Map<int, List<Token>> groupedTokens = {};
    for (final token in nonListedTokens) {
      if (!groupedTokens.containsKey(token.landId)) {
        groupedTokens[token.landId] = [];
      }
      groupedTokens[token.landId]!.add(token);
    }

    // Process tokens into the required format
    final processedTokens = groupedTokens.entries.map((entry) {
      final landId = entry.key;
      final tokensForLand = entry.value;
      final referenceToken = tokensForLand.first;
      final land = referenceToken.land;

      // Calculate average market price
      final totalValue = tokensForLand.fold(
          0.0,
          (sum, token) =>
              sum + (double.tryParse(token.currentMarketInfo.price) ?? 0.0));
      final avgPrice =
          tokensForLand.isNotEmpty ? totalValue / tokensForLand.length : 0.0;

      // Extract actual tokenIds for API call
      final tokenIds = tokensForLand.map((t) => t.tokenId).toList();

      return {
        'id': 'TOK-$landId-2025',
        'name': land.title,
        'location': land.location,
        'totalTokens': 1000, // Default value if not available
        'ownedTokens': tokensForLand.length,
        'marketPrice': avgPrice,
        'imageUrl': land.imageUrl ?? 'assets/1.jpg',
        'lastTraded': '2025-05-01', // Replace with actual data if available
        'priceChange': '+2.4%', // Calculate from history if available
        'actualTokens': tokensForLand, // Keep for reference
        'tokenIds': tokenIds, // Add tokenIds for API call
      };
    }).toList();

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
    final currentDateTime = '2025-05-04 21:20:30';
    final username = 'nesssim';

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
        '[$currentDateTime] $username - Tentative de mise en vente de $tokenCount tokens au prix de $price ETH');

    // Si tout est bon, procéder avec la vente
    setState(() {
      _isProcessing = true;
    });

    // Sélection intelligente: listToken ou listMultipleTokens selon le nombre de tokens
    if (tokenCount == 1) {
      // Si un seul token, utiliser la fonction simple listToken
      final tokenId = token['actualTokens'][0].tokenId;
      print(
          '[$currentDateTime] $username - Utilisation de listToken pour token #$tokenId');

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

      print(
          '[$currentDateTime] $username - Utilisation de listMultipleTokens pour ${tokenIds.length} tokens');

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
                                      currentDate: currentDate,
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
                                currentDate: currentDate,
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
    // Idéalement, récupérer ces données à partir d'une API
    final mockTransactions = [
      {'date': '2025-05-02', 'price': '0.012 ETH', 'type': 'sale'},
      {'date': '2025-04-30', 'price': '0.011 ETH', 'type': 'sale'},
      {'date': '2025-04-28', 'price': '0.0105 ETH', 'type': 'sale'},
    ];

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
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
                  Text('Price',
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
                  Text('Type',
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
                ],
              ),
              ...mockTransactions
                  .map((tx) => TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Text(tx['date']!,
                                style: const TextStyle(fontSize: 12)),
                          ),
                          Text(tx['price']!,
                              style: const TextStyle(fontSize: 12)),
                          Text(
                            tx['type']!.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ))
                  .toList(),
            ],
          ),
        ],
      ),
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
