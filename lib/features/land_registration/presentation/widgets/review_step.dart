import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/constants/colors.dart';
import '../../domain/entities/valuation_result.dart';
import 'review_section.dart';

class ReviewStep extends StatelessWidget {
  final String title;
  final String description;
  final String location;
  final String surface;
  final String? landType;
  final String totalTokens;
  final Map<String, bool> amenities;
  final List<PlatformFile> documents;
  final List<PlatformFile> images;
  final ValuationResult? evaluationResult;
  final bool isAcceptingPrice;
  final Function(bool) onAcceptPrice;
  final Function() onSubmitRegistration;
  final bool isLoading;

  const ReviewStep({
    Key? key,
    required this.title,
    required this.description,
    required this.location,
    required this.surface,
    required this.landType,
    required this.totalTokens,
    required this.amenities,
    required this.documents,
    required this.images,
    required this.evaluationResult,
    required this.isAcceptingPrice,
    required this.onAcceptPrice,
    required this.onSubmitRegistration,
    required this.isLoading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (evaluationResult == null) {
      return Center(
        child: Container(
          padding: EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.warning_amber_rounded,
                  size: 64, color: Colors.orange[700]),
              SizedBox(height: 24),
              Text(
                'Please complete the evaluation step first',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'You need to evaluate your land before proceeding to the final review',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  // This will be handled by the bloc
                },
                child: Text('Go to Evaluation'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final ethPrice = evaluationResult!.valuation.currentEthPriceTND ?? 3000.0;
    final ethValue = evaluationResult!.valuation.estimatedValueETH ??
        evaluationResult!.valuation.estimatedValue / ethPrice;
    final pricePerToken = ethValue / double.parse(totalTokens);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review & Submit',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Review your land details and submit for registration',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          SizedBox(height: 32),

          // Land details summary
          ReviewSection(
            title: 'Land Details',
            icon: Icons.landscape,
            items: [
              {'label': 'Title', 'value': title},
              {
                'label': 'Description',
                'value': description.isNotEmpty
                    ? description
                    : 'Not provided'
              },
              {'label': 'Location', 'value': location},
              {
                'label': 'Surface Area',
                'value': '$surface sq m'
              },
              {
                'label': 'Land Type',
                'value': landType ?? 'Not specified'
              },
              {'label': 'Status', 'value': 'Pending Validation'},
            ],
          ),
          SizedBox(height: 24),

          // Amenities summary
          ReviewSection(
            title: 'Amenities',
            icon: Icons.check_circle,
            items: amenities.entries
                .where((entry) => entry.value)
                .map((entry) => {
                      'label': _formatAmenityName(entry.key),
                      'value': 'Available'
                    })
                .toList(),
          ),
          SizedBox(height: 24),

          // Tokenization details summary
          ReviewSection(
            title: 'Tokenization Details',
            icon: Icons.token,
            items: [
              {'label': 'Total Tokens', 'value': totalTokens},
              {
                'label': 'Price Per Token',
                'value': '${pricePerToken.toStringAsFixed(6)} ETH'
              },
              {
                'label': 'Total Land Value (TND)',
                'value':
                    '${NumberFormat('#,###').format(evaluationResult!.valuation.estimatedValue)}'
              },
              {
                'label': 'Total Land Value (ETH)',
                'value': '${ethValue.toStringAsFixed(4)}'
              },
            ],
          ),
          SizedBox(height: 24),

          // Documentation summary
          ReviewSection(
            title: 'Documentation',
            icon: Icons.folder_special,
            items: [
              {
                'label': 'Documents Uploaded',
                'value': '${documents.length} files'
              },
              {
                'label': 'Images Uploaded',
                'value': '${images.length} files'
              },
            ],
          ),
          SizedBox(height: 32),

          // Price acceptance section
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isAcceptingPrice
                    ? [Colors.green[50]!, Colors.green[100]!]
                    : [Colors.amber[50]!, Colors.amber[100]!],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color:
                    isAcceptingPrice ? Colors.green[300]! : Colors.amber[300]!,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isAcceptingPrice
                          ? Icons.check_circle
                          : Icons.info_outline,
                      color: isAcceptingPrice
                          ? Colors.green[700]
                          : Colors.amber[800],
                      size: 28,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Price Acceptance',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isAcceptingPrice
                            ? Colors.green[800]
                            : Colors.amber[900],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  isAcceptingPrice
                      ? 'You have accepted the proposed price for your land.'
                      : 'You must accept the proposed price to proceed with registration.',
                  style: TextStyle(
                    color: isAcceptingPrice
                        ? Colors.green[700]
                        : Colors.amber[800],
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 24),
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Proposed Price',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '${ethValue.toStringAsFixed(4)}',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'ETH',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        '≈ ${NumberFormat('#,###').format(evaluationResult!.valuation.estimatedValue)} TND',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      Divider(height: 32),
                      Text(
                        'Price per token: ${pricePerToken.toStringAsFixed(6)} ETH',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                Row(
                  children: [
                    Checkbox(
                      value: isAcceptingPrice,
                      onChanged: (value) {
                        onAcceptPrice(value ?? false);
                      },
                      activeColor: Colors.green[700],
                    ),
                    Expanded(
                      child: Text(
                        'I accept the proposed price for my land and wish to proceed with registration.',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 32),

          // Disclaimer section
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.security, color: Colors.grey[700]),
                    SizedBox(width: 12),
                    Text(
                      'Important Information',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  '• All provided information must be accurate and verifiable\n'
                  '• You must be the legal owner of the land\n'
                  '• Documents will be validated by certified validators\n'
                  '• The tokenization process is irreversible once completed',
                  style: TextStyle(fontSize: 15, height: 1.5),
                ),
              ],
            ),
          ),
          
          // Submit button will be part of the main layout navigation buttons
        ],
      ),
    );
  }

  String _formatAmenityName(String amenity) {
    // Convert camelCase to words
    String result = amenity.replaceAllMapped(
      RegExp(r'([A-Z]|[0-9]+)'),
      (Match match) => ' ${match.group(0)}',
    );

    // Capitalize first letter
    return result[0].toUpperCase() + result.substring(1);
  }
}