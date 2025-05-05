// lib/presentation/widgets/metamask_investment_button.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/metamask_provider.dart';
import 'dart:developer' as developer;

class MetamaskInvestmentButton extends StatelessWidget {
  const MetamaskInvestmentButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Log when the button is being built
    developer.log('Building MetaMask investment button');
    
    return Consumer<MetamaskProvider>(
      builder: (context, provider, _) {
        // Debug logs to track provider state
        developer.log('MetaMask state: available=${provider.isMetaMaskAvailable}, '
            'connected=${provider.currentAddress.isNotEmpty}, '
            'loading=${provider.isLoading}, '
            'error=${provider.error}');
        
        // When connecting/loading
        if (provider.isLoading) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                ),
                SizedBox(width: 8),
                Text('Connecting...'),
              ],
            ),
          );
        }

        // When connected
        if (provider.currentAddress.isNotEmpty) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: InkWell(
              onTap: () => _showWalletOptions(context, provider),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.account_balance_wallet, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${provider.currentAddress.substring(0, 4)}...${provider.currentAddress.substring(provider.currentAddress.length - 4)}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (provider.success) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.check_circle, color: Colors.green, size: 16),
                  ],
                ],
              ),
            ),
          );
        }

        // Show error if there is one
        if (provider.error.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('MetaMask error: ${provider.error}'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
                action: SnackBarAction(
                  label: 'Dismiss',
                  textColor: Colors.white,
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  },
                ),
              ),
            );
          });
        }

        // Not connected - default state
        return ElevatedButton.icon(
          icon: const Icon(Icons.account_balance_wallet),
          label: const Text('Connect Wallet'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 2,
          ),
          onPressed: () {
            developer.log('MetaMask connect button clicked');
            
            try {
              provider.connect().then((success) {
                developer.log('MetaMask connect result: $success');
                
                if (!success && provider.error.isNotEmpty) {
                  developer.log('MetaMask error: ${provider.error}');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('MetaMask error: ${provider.error}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }).catchError((error) {
                developer.log('MetaMask connect error: $error');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to connect to MetaMask: $error'),
                    backgroundColor: Colors.red,
                  ),
                );
              });
            } catch (e) {
              developer.log('Exception during MetaMask connection: $e');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to connect to MetaMask: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        );
      },
    );
  }

  void _showWalletOptions(BuildContext context, MetamaskProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Wallet Connected'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your Ethereum Address:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            SelectableText(provider.currentAddress), // Made selectable for copying
            const SizedBox(height: 16),
            if (provider.publicKey.isNotEmpty) ...[
              const Text('Public Key Status:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 16),
                  const SizedBox(width: 4),
                  const Text('Public Key Saved'),
                ],
              ),
            ],
          ],
        ),
        actions: [
          if (!provider.success && provider.publicKey.isEmpty)
            TextButton(
              onPressed: () {
                developer.log('Getting encryption public key');
                Navigator.pop(context);
                provider.getEncryptionPublicKey().then((success) {
                  developer.log('Get public key result: $success');
                  if (!success && provider.error.isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to get public key: ${provider.error}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } else if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Public key obtained successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                });
              },
              child: const Text('Get Public Key'),
            ),
          TextButton(
            onPressed: () {
              developer.log('Disconnecting MetaMask');
              Navigator.pop(context);
              provider.disconnect();
            },
            child: const Text('Disconnect'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}