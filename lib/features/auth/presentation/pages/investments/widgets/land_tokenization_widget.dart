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
  final ScrollController _scrollController = ScrollController();
  bool _expanded = true;
  double _platformFeePercentage = 0.0;
  bool _isLoading = false;
  
  // Stockage local des données
  bool? _isTokenized;
  int? _landId;
  int? _totalTokens;
  int? _availableTokens;
  String? _pricePerToken;
  List<int> _tokenIds = [];
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  @override
  void dispose() {
    _quantityController.dispose();
    _scrollController.dispose();
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
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: AppColors.primary.withOpacity(0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocListener<TokenizationBloc, TokenizationState>(
          listener: (context, state) {
            if (state is TokenizationError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red)
              );
              setState(() {
                _isLoading = false;
              });
            } 
            else if (state is TokensMinted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Successfully minted ${state.tokenIds.length} tokens!'),
                  backgroundColor: Colors.green
                )
              );
              // Mise à jour des données locales
              setState(() {
                _tokenIds.addAll(state.tokenIds);
                if (_availableTokens != null) {
                  _availableTokens = _availableTokens! - state.tokenIds.length;
                }
              });
              _loadData(); // Rechargement pour actualiser toutes les données
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
              // Stocker toutes les données localement
              setState(() {
                _isLoading = false;
                _isTokenized = state.isTokenized;
                _landId = state.landId;
                _totalTokens = state.totalTokens;
                _availableTokens = state.availableTokens;
                _pricePerToken = state.pricePerToken;
                _tokenIds = state.tokenIds;
              });
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header avec expand/collapse
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.divider,
                      width: 1.0,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.token, color: AppColors.primary, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'Tokenization',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                      onPressed: () {
                        setState(() {
                          _expanded = !_expanded;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              
              // Affichage du contenu basé sur l'état local
              if (_isLoading) ...[
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading tokenization details...'),
                      ],
                    ),
                  ),
                ),
              ] else if (_isTokenized != null) ...[
                // Tokenization status
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                  decoration: BoxDecoration(
                    color: _isTokenized! ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isTokenized! ? Icons.check_circle : Icons.pending,
                        color: _isTokenized! ? Colors.green : Colors.orange,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _isTokenized! ? 'Tokenized' : 'Pending tokenization',
                        style: TextStyle(
                          color: _isTokenized! ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Token information
                _buildTokenInfo(),
                
                if (_expanded && _isTokenized!) ...[
                  const Divider(height: 32, thickness: 1),
                  
                  // Token minting section
                  _buildTokenMintingSection(),
                ],
                
                // Show owned tokens
                if (_tokenIds.isNotEmpty && _expanded) ...[
                  const Divider(height: 32, thickness: 1),
                  
                  Container(
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: AppColors.backgroundLight,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    child: ListView(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      children: _tokenIds.map((tokenId) => 
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Chip(
                            label: Text('Token #$tokenId'),
                            backgroundColor: AppColors.primary.withOpacity(0.2),
                            labelStyle: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          ),
                        )
                      ).toList(),
                    ),
                  ),
                ],
              ] else ...[
                // Initial state or error state (no data)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Icon(Icons.info_outline, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Tokenization information not available',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.refresh),
                          label: const Text('Load information'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          onPressed: _loadData,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTokenInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Token Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            label: 'Price per token:',
            value: '${_pricePerToken ?? "N/A"} ETH',
            icon: Icons.attach_money,
          ),
          const Divider(height: 16),
          _buildInfoRow(
            label: 'Available tokens:',
            value: '${_availableTokens ?? "N/A"}/${_totalTokens ?? "N/A"}',
            icon: Icons.inventory_2,
          ),

          if (_platformFeePercentage > 0) ...[
            const Divider(height: 16),
            _buildInfoRow(
              label: 'Platform fee:',
              value: '$_platformFeePercentage%',
              icon: Icons.percent,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow({required String label, required String value, required IconData icon}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 15,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildTokenMintingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.add_circle, color: AppColors.primary),
            SizedBox(width: 8),
            Text(
              'Mint New Tokens',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Quantity selector with improved styling
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'How many tokens would you like to purchase?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Quantity',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        hintText: 'Enter number of tokens',
                        fillColor: Colors.white,
                        filled: true,
                        prefixIcon: const Icon(Icons.tag),
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 4,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundGreen,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Cost:',
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_calculateTotalPrice(_pricePerToken ?? "0", int.tryParse(_quantityController.text) ?? 0)} ETH',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          if (_platformFeePercentage > 0) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Includes $_platformFeePercentage% platform fee',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Mint button with improved styling
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.token),
            label: const Text('Mint Tokens Now', style: TextStyle(fontSize: 16)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 2,
            ),
            onPressed: (_availableTokens ?? 0) > 0 
              ? () {
                  final quantity = int.tryParse(_quantityController.text) ?? 0;
                  if (quantity <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a valid quantity'), backgroundColor: Colors.red)
                    );
                    return;
                  }
                  
                  if (quantity > (_availableTokens ?? 0)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Not enough available tokens'), backgroundColor: Colors.red)
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
        
        // Information about minting with improved styling
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[400], size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'By minting tokens, you are purchasing a share of this land that is represented as a digital asset on the blockchain.',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}