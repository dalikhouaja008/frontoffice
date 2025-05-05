import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_boost/core/constants/colors.dart';
import 'package:the_boost/features/auth/data/models/land_model.dart';
import 'package:the_boost/features/auth/presentation/bloc/tokenization/tokenization_bloc.dart';

class LandTokenizationWidget extends StatefulWidget {
  final Land land;

  const LandTokenizationWidget({super.key, required this.land});

  @override
  State<LandTokenizationWidget> createState() => _LandTokenizationWidgetState();
}

class _LandTokenizationWidgetState extends State<LandTokenizationWidget> {
  final TextEditingController _quantityController = TextEditingController(text: '1');
  double _platformFeePercentage = 0.0;
  bool _isLoading = false;
  
  // Stockage local des données
  bool? _isTokenized;
  int? _landId;
  int? _totalTokens;
  int? _availableTokens;
  String? _pricePerToken;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }
  
  void _loadData() {
    if (widget.land.blockchainLandId != null) {
      setState(() {
        _isLoading = true;
      });
      
      context.read<TokenizationBloc>().add(
        LoadLandTokens(landId: int.parse(widget.land.blockchainLandId!))
      );
      context.read<TokenizationBloc>().add(LoadPlatformFeeInfo());
    }
  }
  
  String _calculateTotalPrice(String pricePerToken, int quantity) {
    try {
      final price = double.parse(pricePerToken);
      final feeAmount = price * quantity * (_platformFeePercentage / 100);
      final totalPrice = (price * quantity) + feeAmount;
      return totalPrice.toStringAsFixed(4);
    } catch (e) {
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TokenizationBloc, TokenizationState>(
      listener: (context, state) {
        if (state is TokenizationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message), 
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            )
          );
          setState(() {
            _isLoading = false;
          });
        } 
        else if (state is TokensMinted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 10),
                  Text('Successfully minted ${state.tokenIds.length} tokens!'),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            )
          );
          
          // Rechargement pour actualiser les données
          _loadData();
        }
        else if (state is PlatformFeeInfoLoaded) {
          setState(() {
            _platformFeePercentage = state.feePercentage;
          });
        }
        else if (state is TokenizationLoading) {
          setState(() {
            _isLoading = true;
          });
        }
        else if (state is LandTokensLoaded) {
          // Stocker les données localement (sans les tokens)
          setState(() {
            _isLoading = false;
            _isTokenized = state.isTokenized;
            _landId = state.landId;
            _totalTokens = state.totalTokens;
            _availableTokens = state.availableTokens;
            _pricePerToken = state.pricePerToken;
            // Nous ne stockons plus state.tokenIds
          });
        }
      },
      child: _isLoading 
        ? _buildLoadingState()
        : _isTokenized == null
          ? _buildInitialState()
          : _buildTokenizationContent(),
    );
  }
  
  Widget _buildLoadingState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              strokeWidth: 3,
            ),
            const SizedBox(height: 24),
            Text(
              'Loading tokenization details...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInitialState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.token_outlined,
                size: 60,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Tokenization information not available',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[700],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Load information to see if this land is tokenized',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Load Information', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 2,
              ),
              onPressed: _loadData,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTokenizationContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status Banner
        _buildStatusBanner(),
        const SizedBox(height: 24),
        
        // Overview stats
        _buildTokenizationOverview(),
        const SizedBox(height: 30),
        
        // Mint New Tokens Section
        if (_isTokenized == true) _buildMintTokensSection(),
      ],
    );
  }
  
  Widget _buildStatusBanner() {
    final bool isTokenized = _isTokenized ?? false;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isTokenized 
            ? [Colors.green.shade400, Colors.green.shade700]
            : [Colors.orange.shade300, Colors.orange.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isTokenized ? Colors.green.withOpacity(0.3) : Colors.orange.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isTokenized ? Icons.verified : Icons.pending_outlined,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isTokenized ? 'Tokenized Land' : 'Pending Tokenization',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isTokenized 
                    ? 'This land has been tokenized and is available for investment'
                    : 'This land is in the process of being tokenized',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTokenizationOverview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.bar_chart, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              const Text(
                'Tokenization Overview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Stats in cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Price',
                  value: '${_pricePerToken ?? "N/A"} ETH',
                  icon: Icons.attach_money,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildStatCard(
                  title: 'Available',
                  value: '${_availableTokens ?? "N/A"}/${_totalTokens ?? "N/A"}',
                  icon: Icons.inventory_2,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          
          if (_platformFeePercentage > 0) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.grey, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Platform fee of $_platformFeePercentage% applies to all token purchases',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: color.withOpacity(0.8),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMintTokensSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add_circle, color: Colors.green),
              ),
              const SizedBox(width: 10),
              const Text(
                'Purchase New Tokens',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Quantity and cost row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quantity',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.1),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Enter amount',
                          prefixIcon: const Icon(Icons.tag, color: Colors.green),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                        ),
                        style: const TextStyle(fontSize: 16),
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 4,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.green.shade50,
                        Colors.green.shade100,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.1),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Cost:',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.account_balance_wallet, 
                            color: Colors.green, size: 20),
                          const SizedBox(width: 6),
                          Text(
                            '${_calculateTotalPrice(_pricePerToken ?? "0", int.tryParse(_quantityController.text) ?? 0)} ETH',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      if (_platformFeePercentage > 0) ...[
                        const SizedBox(height: 6),
                        Text(
                          'Includes $_platformFeePercentage% platform fee',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Purchase button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('Purchase Tokens', 
                style: TextStyle(fontSize: 16, letterSpacing: 0.5)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 2,
              ),
              onPressed: (_availableTokens ?? 0) > 0 
                ? () {
                    final quantity = int.tryParse(_quantityController.text) ?? 0;
                    if (quantity <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a valid quantity'), 
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                        )
                      );
                      return;
                    }
                    
                    if (quantity > (_availableTokens ?? 0)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Not enough available tokens'), 
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                        )
                      );
                      return;
                    }
                    
                    // Calculate total price with fee
                    final totalPrice = _calculateTotalPrice(_pricePerToken ?? "0", quantity);
                    
                    // Mint tokens
                    if (_landId != null) {
                      context.read<TokenizationBloc>().add(
                        MintTokens(
                          landId: _landId!,
                          quantity: quantity,
                          value: totalPrice,
                        )
                      );
                    }
                  }
                : null,
            ),
          ),
          
          // Information about tokens
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withOpacity(0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.info_outline, color: Colors.blue[400], size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'About Tokenization',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'By purchasing tokens, you are acquiring a share of this land that is represented as a digital asset on the blockchain. Each token represents partial ownership of the property.',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}