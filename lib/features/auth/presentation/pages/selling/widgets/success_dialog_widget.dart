import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:the_boost/core/constants/colors.dart';

class TokenSaleSuccessDialog extends StatelessWidget {
  final String tokenName;
  final int tokenCount;
  final double price;
  final double totalAmount;
  final String selectedDuration;
  final NumberFormat formatter;

  const TokenSaleSuccessDialog({
    Key? key,
    required this.tokenName,
    required this.tokenCount,
    required this.price,
    required this.totalAmount,
    required this.selectedDuration,
    required this.formatter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final platformFee = totalAmount * 0.02;
    final gasFee = 2.5;
    final youReceive = totalAmount - platformFee - gasFee;

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.success),
          const SizedBox(width: 8),
          const Text('Tokens Listed Successfully'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'You have successfully listed $tokenCount $tokenName tokens for sale at \$${formatter.format(price)} per token.',
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                _buildInfoRow('Total Sale Value',
                    '\$${formatter.format(totalAmount)}'),
                const SizedBox(height: 8),
                _buildInfoRow(
                    'Platform Fee', '\$${formatter.format(platformFee)}'),
                const SizedBox(height: 8),
                _buildInfoRow('Gas Fee', '\$2.50'),
                const Divider(height: 16),
                _buildInfoRow(
                  'You Will Receive',
                  '\$${formatter.format(youReceive)}',
                  isBold: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Your tokens will be listed for $selectedDuration. You can track your listing in the "My Listings" section of your dashboard.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop(); // Return to previous screen
          },
          child: const Text('View My Listings'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop(); // Return to previous screen
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
          ),
          child: const Text('Done'),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? AppColors.primary : Colors.black,
          ),
        ),
      ],
    );
  }
}