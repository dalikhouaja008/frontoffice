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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.verified_user, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Validation Process',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(width: 8),
                  _buildTooltipIcon(
                    'Validations are conducted according to ISO 17024 standards for Land Registry. Each validation requires verification from multiple qualified authorities.',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.pending_actions,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Pending Validation',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This property has not yet been validated by any authorities',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    _buildValidationStatusChip('pending_validation'),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.verified_user, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Validation Process',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(width: 8),
                _buildTooltipIcon(
                  'Validations follow the ISO 17024 and RFC 3161 standards for Land Registry. All signatures are cryptographically verified on the blockchain.',
                ),
              ],
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: _buildValidationStatusBadge(land.status),
            ),
            const SizedBox(height: 8),
            _buildValidationProgress(),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: land.validations!.length,
              separatorBuilder: (context, index) => const Divider(height: 32),
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
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: isValidated ? AppColors.primary : Colors.grey[400],
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$step',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Validation by ${_getValidatorTypeText(validation.validatorType)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isValidated ? Colors.black87 : Colors.grey[700],
                      ),
                    ),
                    if (timestamp != null)
                      Text(
                        DateFormat('MMM dd, yyyy HH:mm').format(timestamp),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                  ],
                ),
              ),
              if (validation.txHash != null && validation.txHash!.isNotEmpty) ...[
                _buildEtherscanButton(validation.txHash!),
              ],
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isValidated ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isValidated ? Icons.check_circle : Icons.pending,
                  color: isValidated ? Colors.green : Colors.orange,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 46),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.account_circle, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            'Validator: ',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            _formatAddress(validatorAddress),
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontSize: 14,
                              fontFamily: 'Courier',
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.copy, size: 14, color: Colors.grey[600]),
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(),
                            onPressed: () => _copyToClipboard(context, validatorAddress, 'Validator address'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                // Le standard de validation utilisé avec tooltip
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.verified, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Text(
                      'Standard: ',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      _getValidationStandard(validation.validatorType),
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildTooltipIcon(
                      _getValidationStandardDescription(validation.validatorType),
                      size: 14,
                    ),
                  ],
                ),
                
                if (validation.cidComments != null && validation.cidComments!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.comment, size: 16, color: Colors.grey[700]),
                            const SizedBox(width: 6),
                            Text(
                              'Validation Comments',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[800],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          validation.cidComments!,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                // Signature Section (Enhanced)
                if (validation.signature != null && validation.signature!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildSignatureCard(context, validation),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Méthode remplacée pour utiliser un Tooltip au lieu d'un Dialog
  Widget _buildTooltipIcon(String message, {double size = 18}) {
    return Tooltip(
      message: message,
      preferBelow: false,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(
        color: Colors.white,
        fontSize: 13,
      ),
      showDuration: const Duration(seconds: 5),
      waitDuration: const Duration(milliseconds: 100),
      child: Icon(
        Icons.info_outline,
        size: size,
        color: AppColors.primary,
      ),
    );
  }

  // Nouvelle méthode pour afficher les détails de signature avec style amélioré
  Widget _buildSignatureCard(BuildContext context, ValidationEntry validation) {
    final signatureType = validation.signatureType ?? 'Unknown';
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.security, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                'Digital Signature',
                style: TextStyle(
                  fontSize: 15, 
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(width: 6),
              _buildTooltipIcon(
                'Digital signatures provide cryptographic proof of validation according to industry standards. This signature can be independently verified on the blockchain.',
                size: 14,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  signatureType,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _formatAddress(validation.signature!, showMore: true),
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Courier',
                      color: Colors.grey[800],
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.copy, size: 16, color: Colors.grey[600]),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => _copyToClipboard(context, validation.signature!, 'Signature'),
                ),
              ],
            ),
          ),
          
          // Afficher le message signé si disponible
          if (validation.signedMessage != null && validation.signedMessage!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.description, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 6),
                const Text(
                  'Signed Message:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 6),
            InkWell(
              onTap: () => _showSignedMessageDialog(context, validation.signedMessage!),
              borderRadius: BorderRadius.circular(6),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'View complete message',
                      style: TextStyle(
                        fontSize: 13, 
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Icon(Icons.visibility, size: 16, color: AppColors.primary),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Nouvelle méthode pour afficher le bouton Etherscan
  Widget _buildEtherscanButton(String txHash) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: () => _launchEtherscanTx(txHash),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.open_in_new,
                size: 16,
                color: Colors.blue[700],
              ),
              const SizedBox(width: 4),
              Text(
                'Etherscan',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Nouvelle méthode pour afficher une barre de progression
  Widget _buildValidationProgress() {
    if (land.validations == null) return const SizedBox();
    
    final validatedCount = land.validations!.where((v) => v.isValidated == true).length;
    final totalRequired = _getRequiredValidationsCount();
    final double progress = validatedCount / totalRequired;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Validation Progress',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            Text(
              '$validatedCount/$totalRequired',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: progress >= 1 ? Colors.green : Colors.grey[800],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              progress >= 1 ? Colors.green : AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (progress < 1) ...[
              Icon(Icons.info_outline, size: 12, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                'Waiting for ${totalRequired - validatedCount} more validation(s)',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[600],
                ),
              ),
            ] else ...[
              const Icon(Icons.check_circle, size: 12, color: Colors.green),
              const SizedBox(width: 4),
              Text(
                'All required validations completed',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.green,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  // Amélioration du style des badges d'état
  Widget _buildValidationStatusBadge(String status) {
    return _buildValidationStatusChip(status);
  }

  Widget _buildValidationStatusChip(String status) {
    Color color;
    IconData icon;
    String text;
    
    switch (status.toLowerCase()) {
      case 'validated':
        color = Colors.green;
        icon = Icons.check_circle;
        text = 'VALIDATED';
        break;
      case 'pending':
      case 'pending_validation':
        color = Colors.orange;
        icon = Icons.pending;
        text = 'PENDING';
        break;
      case 'partially_validated':
        color = Colors.blue;
        icon = Icons.playlist_add_check;
        text = 'PARTIALLY VALIDATED';
        break;
      case 'rejected':
        color = Colors.red;
        icon = Icons.cancel;
        text = 'REJECTED';
        break;
      default:
        color = Colors.grey;
        icon = Icons.help_outline;
        text = status.toUpperCase().replaceAll('_', ' ');
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Méthode pour afficher le message signé dans une boîte de dialogue améliorée
  void _showSignedMessageDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(16),
          title: Row(
            children: [
              Icon(Icons.description, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text('Signed Message'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: SelectableText(
                    message,
                    style: TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 13,
                      color: Colors.grey[800],
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.info_outline, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'This message was signed with a cryptographic key to verify authenticity.',
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Copy'),
              onPressed: () => _copyToClipboard(context, message, 'Message'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                backgroundColor: AppColors.primary.withOpacity(0.1),
              ),
              child: const Text('Close'),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        );
      },
    );
  }

  // Méthode utilitaire pour copier du texte dans le presse-papiers
  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _formatAddress(String address, {bool showMore = false}) {
    if (address.isEmpty) return 'N/A';
    if (address.length <= 14) return address;
    return showMore 
        ? '${address.substring(0, 14)}...${address.substring(address.length - 14)}'
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
  
  // Nouvelles méthodes pour les standards de validation
  String _getValidationStandard(int? validatorType) {
    switch (validatorType) {
      case 0:
        return 'ISO 17024 (Notarial)';
      case 1:
        return 'ISO 19152 (Land Administration)';
      case 2:
        return 'RFC 3161 (Time-Stamping)';
      default:
        return 'General Validation';
    }
  }
  
  String _getValidationStandardDescription(int? validatorType) {
    switch (validatorType) {
      case 0:
        return 'ISO 17024 establishes requirements for certification of persons including notaries. This ensures the validation conforms to international standards for notarial certification.';
      case 1:
        return 'ISO 19152 is the Land Administration Domain Model (LADM) standard that establishes a reference model for land administration, ensuring proper surveying and land measurement protocols.';
      case 2:
        return 'RFC 3161 is the Internet X.509 Public Key Infrastructure Time-Stamp Protocol (TSP) that ensures cryptographic timestamps are properly created and verified, ensuring legal validity.';
      default:
        return 'This validation follows general blockchain validation protocols to ensure data integrity and authenticity.';
    }
  }
  
  // Fonction pour déterminer combien de validations sont requises
  int _getRequiredValidationsCount() {
    switch (land.landtype) {
      case LandType.residential:
      case LandType.commercial:
        return 3; // Exige les 3 types de validation
      case LandType.agricultural:
        return 2; // Exige seulement deux validations
      case LandType.industrial:
        return 3; // Exige les 3 types de validation
      default:
        return 3; // Par défaut, exige les 3 types de validation
    }
  }

  void _launchEtherscanTx(String txHash) async {
    final url = 'https://sepolia.etherscan.io/tx/$txHash';
    final uri = Uri.parse(url);
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // Gérer l'erreur silencieusement
      debugPrint('Could not launch $url');
    }
  }
}