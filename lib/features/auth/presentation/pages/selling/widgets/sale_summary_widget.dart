import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:the_boost/core/constants/colors.dart';

class SaleSummaryWidget extends StatelessWidget {
  final Map<String, dynamic> selectedToken;
  final double tokensToSell;
  final double pricePerToken;
  final String selectedDuration;
  final double totalAmount;
  final bool termsAccepted;
  final NumberFormat formatter;
  final Function(bool?) onTermsAccepted;
  final VoidCallback onSellPressed;
  final VoidCallback onCancelPressed;
  final VoidCallback onSaveDraftPressed;

  const SaleSummaryWidget({
    Key? key,
    required this.selectedToken,
    required this.tokensToSell,
    required this.pricePerToken,
    required this.selectedDuration,
    required this.totalAmount,
    required this.termsAccepted,
    required this.formatter,
    required this.onTermsAccepted,
    required this.onSellPressed,
    required this.onCancelPressed,
    required this.onSaveDraftPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final canSell = termsAccepted && tokensToSell > 0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sale Preview',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            _buildSalePreview(),
            _buildMarketInsights(),
            const SizedBox(height: 24),
            _buildTotalAmount(),
            const SizedBox(height: 24),
            _buildTermsAcceptance(context),
            const SizedBox(height: 24),
            _buildActionButtons(canSell),
          ],
        ),
      ),
    );
  }

  Widget _buildSalePreview() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 3),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: AssetImage(selectedToken['imageUrl']),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedToken['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Token ID: ${selectedToken['id']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.backgroundGreen.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Quantity',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  tokensToSell > 0 ? tokensToSell.toStringAsFixed(0) : '-',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.backgroundGreen.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Price per token',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '\$${formatter.format(pricePerToken)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.backgroundGreen.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Listing period',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  selectedDuration,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketInsights() {
    final priceDifferenceText = _getPriceDifferenceText(
        pricePerToken, selectedToken['marketPrice']);
    final priceDifferenceColor = _getPriceDifferenceColor(
        pricePerToken, selectedToken['marketPrice']);

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.show_chart,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              const Text(
                'Market Insights',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildMarketInsightRow(
            'Recent sale price',
            '\$${formatter.format(selectedToken['marketPrice'])}',
          ),
          const SizedBox(height: 8),
          _buildMarketInsightRow(
            'Your price',
            '\$${formatter.format(pricePerToken)}',
          ),
          const SizedBox(height: 8),
          _buildMarketInsightRow(
            'Price difference',
            priceDifferenceText,
            valueColor: priceDifferenceColor,
          ),
        ],
      ),
    );
  }

  Widget _buildTotalAmount() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Total Sale Amount',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            '\$${formatter.format(totalAmount)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsAcceptance(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: termsAccepted,
          activeColor: AppColors.primary,
          onChanged: onTermsAccepted,
        ),
        Expanded(
          child: Text(
            'I agree to the terms and conditions of selling tokens on TheBoost platform.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(bool canSell) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: canSell ? onSellPressed : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey[300],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'List For Sale',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onCancelPressed,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: AppColors.divider),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            TextButton(
              onPressed: tokensToSell > 0 ? onSaveDraftPressed : null,
              child: const Text(
                'Save as Draft',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMarketInsightRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: valueColor ?? Colors.black,
          ),
        ),
      ],
    );
  }

  String _getPriceDifferenceText(double userPrice, double marketPrice) {
    if (userPrice == marketPrice) {
      return 'Equal to market';
    } else if (userPrice > marketPrice) {
      final diff =
          ((userPrice - marketPrice) / marketPrice * 100).toStringAsFixed(1);
      return '+$diff% (Above market)';
    } else {
      final diff =
          ((marketPrice - userPrice) / marketPrice * 100).toStringAsFixed(1);
      return '-$diff% (Below market)';
    }
  }

  Color _getPriceDifferenceColor(double userPrice, double marketPrice) {
    if (userPrice == marketPrice) {
      return Colors.black;
    } else if (userPrice > marketPrice) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}