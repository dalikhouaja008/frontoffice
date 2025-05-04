import 'package:flutter/material.dart';
import 'package:the_boost/core/constants/colors.dart';
import 'package:the_boost/core/utils/responsive_helper.dart';
import 'package:the_boost/features/auth/presentation/pages/base_page.dart';
import 'package:intl/intl.dart';
import 'package:the_boost/features/auth/presentation/pages/selling/widgets/hero_banner_widget.dart';
import 'package:the_boost/features/auth/presentation/pages/selling/widgets/sale_summary_widget.dart';
import 'package:the_boost/features/auth/presentation/pages/selling/widgets/success_dialog_widget.dart';
import 'package:the_boost/features/auth/presentation/pages/selling/widgets/token_selection_widget.dart';
import 'package:the_boost/features/auth/presentation/pages/selling/widgets/token_selling_frm_widget.dart';

class TokenSellingPage extends StatefulWidget {
  const TokenSellingPage({Key? key}) : super(key: key);

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

  // Current date and username from requirements
  final String currentDate = "2025-05-04 18:34:39";
  final String username = "nesssim";

  // Mock data for owned tokens
  final List<Map<String, dynamic>> _ownedTokens = [
    {
      'id': 'TOK-GV-2025',
      'name': 'Green Valley Estate',
      'location': 'Austin, Texas',
      'totalTokens': 1000,
      'ownedTokens': 120,
      'marketPrice': 45.75,
      'imageUrl': 'assets/1.jpg',
      'lastTraded': '2025-04-28',
      'priceChange': '+2.4%',
    },
    {
      'id': 'TOK-SR-2024',
      'name': 'Sunset Residences',
      'location': 'Miami, Florida',
      'totalTokens': 500,
      'ownedTokens': 75,
      'marketPrice': 62.30,
      'imageUrl': 'assets/2.jpg',
      'lastTraded': '2025-04-30',
      'priceChange': '+1.2%',
    },
    {
      'id': 'TOK-MP-2024',
      'name': 'Mountain Peak Development',
      'location': 'Denver, Colorado',
      'totalTokens': 800,
      'ownedTokens': 50,
      'marketPrice': 38.25,
      'imageUrl': 'assets/3.jpg',
      'lastTraded': '2025-04-26',
      'priceChange': '-0.8%',
    },
    {
      'id': 'TOK-MP-2024',
      'name': 'Mountain Peak Development',
      'location': 'Denver, Colorado',
      'totalTokens': 800,
      'ownedTokens': 50,
      'marketPrice': 38.25,
      'imageUrl': 'assets/3.jpg',
      'lastTraded': '2025-04-26',
      'priceChange': '-0.8%',
    },
    {
      'id': 'TOK-MP-2024',
      'name': 'Mountain Peak Development',
      'location': 'Denver, Colorado',
      'totalTokens': 800,
      'ownedTokens': 50,
      'marketPrice': 38.25,
      'imageUrl': 'assets/3.jpg',
      'lastTraded': '2025-04-26',
      'priceChange': '-0.8%',
    },
    {
      'id': 'TOK-MP-2024',
      'name': 'Mountain Peak Development',
      'location': 'Denver, Colorado',
      'totalTokens': 800,
      'ownedTokens': 50,
      'marketPrice': 38.25,
      'imageUrl': 'assets/3.jpg',
      'lastTraded': '2025-04-26',
      'priceChange': '-0.8%',
    },
  ];

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
    _updateSelectedToken();
  }

  void _updateSelectedToken() {
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
    final maxValue = _ownedTokens[_selectedTokenIndex]['ownedTokens'];
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
      if (_isMarketPrice) {
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
    // This would be replaced with actual logic to process the token sale
    final tokenCount = int.tryParse(_tokensToSellController.text) ?? 0;
    final price =
        double.tryParse(_pricePerTokenController.text.replaceAll(',', '')) ?? 0;
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
    );
  }

  void _saveDraft() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Draft saved successfully'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    return BasePage(
      title: 'Sell Tokens',
      currentRoute: '/token-selling',
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HeroBannerWidget(),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Tokens to Sell',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 16),
                  TokenSelectionWidget(
                    tokens: _ownedTokens,
                    selectedIndex: _selectedTokenIndex,
                    onTokenSelected: _handleSelectToken,
                    formatter: formatter,
                  ),
                  const SizedBox(height: 32),
                  if (isDesktop || isTablet)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: TokenSellingFormWidget(
                            tokensToSellController: _tokensToSellController,
                            pricePerTokenController: _pricePerTokenController,
                            descriptionController: _descriptionController,
                            selectedToken: _ownedTokens[_selectedTokenIndex],
                            durations: _durations,
                            selectedDuration: _selectedDuration,
                            isMarketPrice: _isMarketPrice,
                            currentDate: currentDate,
                            username: username,
                            formatter: formatter,
                            totalAmount: _totalAmount,
                            onTokensChanged: _handleTokensChange,
                            onPriceChanged: _handlePriceChange,
                            onIncrementTokens: _incrementTokens,
                            onDecrementTokens: _decrementTokens,
                            onMarketPriceToggled: _toggleMarketPrice,
                            onDurationChanged: _handleDurationChange,
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 2,
                          child: SaleSummaryWidget(
                            selectedToken: _ownedTokens[_selectedTokenIndex],
                            tokensToSell:
                                double.tryParse(_tokensToSellController.text) ??
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
                            onSellPressed: _handleTokenSale,
                            onCancelPressed: () => Navigator.pop(context),
                            onSaveDraftPressed: _saveDraft,
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        TokenSellingFormWidget(
                          tokensToSellController: _tokensToSellController,
                          pricePerTokenController: _pricePerTokenController,
                          descriptionController: _descriptionController,
                          selectedToken: _ownedTokens[_selectedTokenIndex],
                          durations: _durations,
                          selectedDuration: _selectedDuration,
                          isMarketPrice: _isMarketPrice,
                          currentDate: currentDate,
                          username: username,
                          formatter: formatter,
                          totalAmount: _totalAmount,
                          onTokensChanged: _handleTokensChange,
                          onPriceChanged: _handlePriceChange,
                          onIncrementTokens: _incrementTokens,
                          onDecrementTokens: _decrementTokens,
                          onMarketPriceToggled: _toggleMarketPrice,
                          onDurationChanged: _handleDurationChange,
                        ),
                        const SizedBox(height: 24),
                        SaleSummaryWidget(
                          selectedToken: _ownedTokens[_selectedTokenIndex],
                          tokensToSell:
                              double.tryParse(_tokensToSellController.text) ??
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
                          onSellPressed: _handleTokenSale,
                          onCancelPressed: () => Navigator.pop(context),
                          onSaveDraftPressed: _saveDraft,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
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
