import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:the_boost/core/constants/colors.dart';
import 'package:the_boost/features/auth/data/models/land_model.dart';
import 'package:url_launcher/url_launcher.dart';

class LandValidationWidget extends StatelessWidget {
  final Land land;

  const LandValidationWidget({Key? key, required this.land}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (land.validations == null || land.validations!.isEmpty) {
      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Validation Process',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text('No validation information available'),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Validation Process',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                _buildValidationStatusBadge(land.status),
              ],
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: land.validations!.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final validation = land.validations![index];
                return _buildValidationEntry(context, validation, index + 1);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValidationEntry(BuildContext context, ValidationEntry validation, int step) {
    final validatorAddress = validation.validator ?? 'Unknown';
    final isValidated = validation.isValidated ?? false;
    final timestamp = validation.timestamp != null 
        ? DateTime.fromMillisecondsSinceEpoch(validation.timestamp! * 1000)
        : null;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isValidated ? AppColors.primary : Colors.grey,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$step',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Validation by ${_getValidatorTypeText(validation.validatorType)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Icon(
                isValidated ? Icons.check_circle : Icons.pending,
                color: isValidated ? Colors.green : Colors.orange,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.person, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Validator: ${_formatAddress(validatorAddress)}',
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),
                  ],
                ),
                
                if (timestamp != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        'Date: ${DateFormat('MMM dd, yyyy HH:mm').format(timestamp)}',
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ],
                  ),
                ],
                
                if (validation.cidComments != null && validation.cidComments!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Comments:',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    validation.cidComments!,
                    style: const TextStyle(color: Colors.black87),
                  ),
                ],
                
                // Signature Section (New)
                if (validation.signature != null && validation.signature!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Digital Signature:',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildSignatureCard(context, validation),
                ],
                
                if (validation.txHash != null && validation.txHash!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.link, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      const Text(
                        'Transaction: ',
                        style: TextStyle(color: Colors.black87),
                      ),
                      GestureDetector(
                        onTap: () => _launchEtherscanTx(validation.txHash!),
                        child: Text(
                          _formatAddress(validation.txHash!),
                          style: const TextStyle(
                            color: AppColors.primary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Nouvelle méthode pour afficher les détails de signature
  Widget _buildSignatureCard(BuildContext context, ValidationEntry validation) {
    final signatureType = validation.signatureType ?? 'Unknown';
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified, size: 16, color: AppColors.primary),
              const SizedBox(width: 4),
              Text(
                'Type: $signatureType',
                style: const TextStyle(
                  fontSize: 14, 
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  _formatAddress(validation.signature!, showMore: true),
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: 'Courier',
                    color: Colors.grey[800],
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy, size: 16),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: validation.signature!));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Signature copied to clipboard')),
                  );
                },
              ),
            ],
          ),
          
          // Afficher le message signé si disponible
          if (validation.signedMessage != null && validation.signedMessage!.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text(
              'Signed Message:',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () {
                _showSignedMessageDialog(context, validation.signedMessage!);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'View message content',
                      style: TextStyle(fontSize: 12, color: AppColors.primary),
                    ),
                    Icon(Icons.visibility, size: 14, color: AppColors.primary),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Méthode pour afficher le message signé dans une boîte de dialogue
  void _showSignedMessageDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Signed Message'),
          content: SingleChildScrollView(
            child: SelectableText(
              message,
              style: const TextStyle(fontFamily: 'Courier', fontSize: 12),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Copy'),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: message));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Message copied to clipboard')),
                );
              },
            ),
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildValidationStatusBadge(String status) {
    Color color;
    String text;
    
    switch (status.toLowerCase()) {
      case 'validated':
        color = Colors.green;
        text = 'VALIDATED';
        break;
      case 'pending':
      case 'pending_validation':
      case 'partially_validated':
        color = Colors.orange;
        text = status.toUpperCase().replaceAll('_', ' ');
        break;
      case 'rejected':
        color = Colors.red;
        text = 'REJECTED';
        break;
      default:
        color = Colors.grey;
        text = status.toUpperCase();
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatAddress(String address, {bool showMore = false}) {
    if (address.isEmpty) return 'N/A';
    if (address.length <= 14) return address;
    return showMore 
        ? '${address.substring(0, 12)}...${address.substring(address.length - 12)}'
        : '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }

  String _getValidatorTypeText(int? validatorType) {
    switch (validatorType) {
      case 0:
        return 'Notary';
      case 1:
        return 'Surveyor';
      case 2:
        return 'Legal Expert';
      default:
        return 'Validator';
    }
  }

  void _launchEtherscanTx(String txHash) async {
  final url = 'https://sepolia.etherscan.io/tx/$txHash';
  final uri = Uri.parse(url);
  
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}