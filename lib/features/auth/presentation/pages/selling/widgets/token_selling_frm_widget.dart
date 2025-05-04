import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:the_boost/core/constants/colors.dart';

class TokenSellingFormWidget extends StatelessWidget {
  final TextEditingController tokensToSellController;
  final TextEditingController pricePerTokenController;
  final TextEditingController descriptionController;
  final Map<String, dynamic> selectedToken;
  final List<String> durations;
  final String selectedDuration;
  final bool isMarketPrice;
  final String currentDate;
  final String username;
  final NumberFormat formatter;
  final double totalAmount;
  final Function(String) onTokensChanged;
  final Function(String) onPriceChanged;
  final VoidCallback onIncrementTokens;
  final VoidCallback onDecrementTokens;
  final Function(bool?) onMarketPriceToggled;
  final Function(String?) onDurationChanged;

  const TokenSellingFormWidget({
    Key? key,
    required this.tokensToSellController,
    required this.pricePerTokenController,
    required this.descriptionController,
    required this.selectedToken,
    required this.durations,
    required this.selectedDuration,
    required this.isMarketPrice,
    required this.currentDate,
    required this.username,
    required this.formatter,
    required this.totalAmount,
    required this.onTokensChanged,
    required this.onPriceChanged,
    required this.onIncrementTokens,
    required this.onDecrementTokens,
    required this.onMarketPriceToggled,
    required this.onDurationChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const Divider(height: 32),
            _buildTokensInput(context),
            const SizedBox(height: 24),
            _buildPriceInput(context),
            const SizedBox(height: 24),
            _buildDurationSelector(context),
            const SizedBox(height: 24),
            _buildDescriptionInput(context),
            const SizedBox(height: 24),
            _buildFeeInformation(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Token Selling Details',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
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
                    Icons.access_time,
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
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(
              Icons.person,
              size: 16,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              'Logged in as: $username',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTokensInput(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Number of Tokens to Sell',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(width: 8),
            Tooltip(
              message: 'Enter the quantity of tokens you want to sell',
              child: Icon(
                Icons.info_outline,
                color: Colors.grey[400],
                size: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: tokensToSellController,
                decoration: InputDecoration(
                  hintText: 'Enter quantity',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  helperText: 'Available: ${selectedToken['ownedTokens']} tokens',
                ),
                keyboardType: TextInputType.number,
                onChanged: onTokensChanged,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  InkWell(
                    onTap: onIncrementTokens,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      child: const Icon(
                        Icons.add,
                        size: 16,
                      ),
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: Colors.grey[300],
                  ),
                  InkWell(
                    onTap: onDecrementTokens,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      child: const Icon(
                        Icons.remove,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceInput(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Price Per Token',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(width: 8),
            Tooltip(
              message: 'Set your preferred selling price per token',
              child: Icon(
                Icons.info_outline,
                color: Colors.grey[400],
                size: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: pricePerTokenController,
          decoration: InputDecoration(
            hintText: 'Enter price per token',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            prefixIcon: const Icon(Icons.attach_money),
            enabled: !isMarketPrice,
          ),
          keyboardType: TextInputType.number,
          onChanged: onPriceChanged,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.backgroundGreen.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: isMarketPrice,
                    activeColor: AppColors.primary,
                    onChanged: onMarketPriceToggled,
                  ),
                  const Text('Use current market price'),
                ],
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Last traded: ${selectedToken['lastTraded']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: selectedToken['priceChange'].contains('+')
                            ? AppColors.success
                            : AppColors.error,
                      ),
                    ),
                    child: Text(
                      selectedToken['priceChange'],
                      style: TextStyle(
                        fontSize: 12,
                        color: selectedToken['priceChange'].contains('+')
                            ? AppColors.success
                            : AppColors.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDurationSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Sale Duration',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(width: 8),
            Tooltip(
              message: 'How long your tokens will be listed for sale',
              child: Icon(
                Icons.info_outline,
                color: Colors.grey[400],
                size: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedDuration,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            prefixIcon: const Icon(Icons.calendar_today),
          ),
          items: durations.map((duration) {
            return DropdownMenuItem(
              value: duration,
              child: Text(duration),
            );
          }).toList(),
          onChanged: onDurationChanged,
        ),
      ],
    );
  }

  Widget _buildDescriptionInput(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description (Optional)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: descriptionController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Add any additional information for potential buyers',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeeInformation(BuildContext context) {
    final platformFee = totalAmount * 0.02;
    final gasFee = 2.5;
    final youReceive = totalAmount - platformFee - gasFee;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.receipt, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Fee Information',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildFeeRow('Platform Fee (2%)', '\$${formatter.format(platformFee)}'),
          const SizedBox(height: 8),
          _buildFeeRow(
            'Gas Fee (Estimated)', 
            '\$2.50',
            showInfoIcon: true,
            tooltip: 'Gas fees vary based on network congestion',
          ),
          const Divider(height: 24),
          _buildFeeRow(
            'You Will Receive',
            '\$${formatter.format(youReceive)}',
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildFeeRow(
    String label, 
    String value, {
    bool isBold = false, 
    bool showInfoIcon = false, 
    String? tooltip,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (showInfoIcon) ...[
              const SizedBox(width: 4),
              Tooltip(
                message: tooltip ?? '',
                child: Icon(
                  Icons.info_outline,
                  size: 14,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? AppColors.primary : null,
          ),
        ),
      ],
    );
  }
}