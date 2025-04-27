import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:the_boost/core/constants/colors.dart';
import 'package:the_boost/features/auth/data/models/land_model.dart';
import 'package:url_launcher/url_launcher.dart';

class LandBlockchainWidget extends StatelessWidget {
  final Land land;
  final String? networkName;

  const LandBlockchainWidget({
    Key? key,
    required this.land,
    this.networkName = "ethereum",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Si aucune information blockchain n'est disponible
    if (land.blockchainLandId == null && land.ownerAddress == null) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.token,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Blockchain Information',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (land.blockchainLandId != null) ...[
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Land Token ID',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                land.blockchainLandId!,
                                style: const TextStyle(fontSize: 16),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy, size: 18),
                              onPressed: () => _copyToClipboard(
                                context,
                                land.blockchainLandId!,
                                'Token ID copied to clipboard',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () => _openEtherscanToken(land.blockchainLandId!, networkName),
                icon: const Icon(Icons.open_in_new),
                label: const Text('View on Etherscan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
            
            if (land.ownerAddress != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Owner Wallet Address',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                land.ownerAddress!,
                                style: const TextStyle(fontSize: 16),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy, size: 18),
                              onPressed: () => _copyToClipboard(
                                context,
                                land.ownerAddress!,
                                'Owner address copied to clipboard',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () => _openEtherscanAddress(land.ownerAddress!, networkName),
                icon: const Icon(Icons.account_balance_wallet),
                label: const Text('View Owner on Etherscan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
            
            if (land.totalTokens != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.pie_chart, size: 20, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Tokenization',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'This land has been divided into ${land.totalTokens} tokens${land.pricePerToken != null ? ' at ${land.pricePerToken} DT per token' : ''}.',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _openEtherscanToken(String tokenId, String? network) async {
    final baseUrl = _getEtherscanBaseUrl(network);
    final url = '$baseUrl/token/$tokenId'; // Ajustez selon le format approprié
    final uri = Uri.parse(url);
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _openEtherscanAddress(String address, String? network) async {
    final baseUrl = _getEtherscanBaseUrl(network);
    final url = '$baseUrl/address/$address';
    final uri = Uri.parse(url);
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String _getEtherscanBaseUrl(String? network) {
    switch (network?.toLowerCase()) {
      case 'polygon':
        return 'https://polygonscan.com';
      case 'optimism':
        return 'https://optimistic.etherscan.io';
      case 'arbitrum':
        return 'https://arbiscan.io';
      case 'goerli':
        return 'https://goerli.etherscan.io';
      case 'sepolia':
        return 'https://sepolia.etherscan.io';
      default:
        return 'https://etherscan.io';
    }
  }
}