import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/constants/colors.dart';
import '../../domain/entities/valuation_result.dart';
import 'evaluation_detail_card.dart';

class EvaluationStep extends StatelessWidget {
  final String totalTokens;
  final Map<String, dynamic>? ethPriceData;
  final ValuationResult? evaluationResult;
  final bool isEvaluating;
  final bool hasEvaluated;
  final Function(String) onTotalTokensChanged;
  final Function() onEvaluateLand;
  final Function() onFetchEthPrice;

  const EvaluationStep({
    Key? key,
    required this.totalTokens,
    this.ethPriceData,
    this.evaluationResult,
    required this.isEvaluating,
    required this.hasEvaluated,
    required this.onTotalTokensChanged,
    required this.onEvaluateLand,
    required this.onFetchEthPrice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Land Value Evaluation',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          'Get an estimated value for your land before tokenization',
          style: TextStyle(color: Colors.grey[600], fontSize: 16),
        ),
        SizedBox(height: 32),

        // ETH Price indicator
        if (ethPriceData != null)
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[50]!, Colors.blue[100]!],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.currency_exchange,
                    color: Colors.blue[700], size: 28),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current ETH Price',
                        style: TextStyle(
                          color: Colors.blue[900],
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${ethPriceData!['ethPriceTND'].toStringAsFixed(2)} TND',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900],
                          fontSize: 24,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.refresh, color: Colors.blue[700]),
                  onPressed: onFetchEthPrice,
                  tooltip: 'Refresh ETH price',
                ),
              ],
            ),
          ),
        SizedBox(height: 24),

        // Token configuration
        Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Token Configuration',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                initialValue: totalTokens,
                decoration: InputDecoration(
                  labelText: 'Total Tokens',
                  hintText: 'Number of tokens to create',
                  prefixIcon: Icon(Icons.token, color: AppColors.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  helperText:
                      'How many tokens do you want to create for your land?',
                ),
                keyboardType: TextInputType.number,
                onChanged: onTotalTokensChanged,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the total number of tokens';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Please enter a valid number of tokens';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        SizedBox(height: 32),

        // Evaluation Button or Results
        if (isEvaluating)
          Center(
            child: Column(
              children: [
                SizedBox(height: 40),
                CircularProgressIndicator(
                  color: AppColors.primary,
                ),
                SizedBox(height: 24),
                Text(
                  'Evaluating your land...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 40),
              ],
            ),
          )
        else if (hasEvaluated && evaluationResult != null)
          _buildValuationResultDisplay(evaluationResult!)
        else
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  Icon(Icons.analytics, size: 48, color: AppColors.primary),
                  SizedBox(height: 16),
                  Text(
                    'Ready to evaluate your land?',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: onEvaluateLand,
                    icon: Icon(Icons.calculate),
                    label: Text('Evaluate Land Value'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // Display for the valuation result
  Widget _buildValuationResultDisplay(ValuationResult result) {
    final valuation = result.valuation;
    final ethPrice = valuation.currentEthPriceTND ??
        (ethPriceData != null ? ethPriceData!['ethPriceTND'] : 3000.0);

    return Container(
      padding: EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[50]!, Colors.blue[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle,
                    color: Colors.green[700], size: 32),
              ),
              SizedBox(width: 16),
              Text(
                'Evaluation Complete',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
              ),
            ],
          ),
          SizedBox(height: 32),

          // Main value display
          Center(
            child: Container(
              padding: EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Estimated Land Value',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${NumberFormat('#,###').format(valuation.estimatedValue)}',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'TND',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  if (valuation.estimatedValueETH != null) ...[
                    SizedBox(height: 8),
                    Text(
                      '≈ ${valuation.estimatedValueETH!.toStringAsFixed(4)} ETH',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          SizedBox(height: 32),

          // Token info grid
          Row(
            children: [
              Expanded(
                child: EvaluationDetailCard(
                  label: 'Total Tokens',
                  value: totalTokens,
                  icon: Icons.token,
                  color: Colors.purple,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: EvaluationDetailCard(
                  label: 'Price Per Token (TND)',
                  value: NumberFormat('#,###').format(valuation.estimatedValue /
                      double.parse(totalTokens)),
                  icon: Icons.price_check,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: EvaluationDetailCard(
                  label: 'Price Per Token (ETH)',
                  value: ((valuation.estimatedValueETH ??
                              valuation.estimatedValue / ethPrice) /
                          double.parse(totalTokens))
                      .toStringAsFixed(6),
                  icon: Icons.currency_exchange,
                  color: Colors.blue,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: EvaluationDetailCard(
                  label: 'Land Area',
                  value: '${valuation.areaInSqFt} sq m',
                  icon: Icons.square_foot,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          SizedBox(height: 32),

          // Re-evaluate button
          Center(
            child: TextButton.icon(
              onPressed: onEvaluateLand,
              icon: Icon(Icons.refresh),
              label: Text('Re-evaluate'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
