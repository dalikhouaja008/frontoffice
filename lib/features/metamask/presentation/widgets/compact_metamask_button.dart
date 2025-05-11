import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_boost/core/constants/colors.dart';
import 'package:the_boost/features/metamask/data/models/metamask_provider.dart';
import 'dart:developer' as developer;

typedef PublicKeyUpdateCallback = Future<void> Function(BuildContext context, String address);

class CompactMetamaskButton extends StatelessWidget {
  /// Callback function to be called when the user's public key needs to be updated
  final PublicKeyUpdateCallback? onUpdatePublicKey;
  
  /// Optional custom styling for the button
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Color? primaryColor;
  final Color? backgroundColor;
  
  const CompactMetamaskButton({
    super.key,
    this.onUpdatePublicKey,
    this.padding,
    this.borderRadius,
    this.primaryColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectivePrimaryColor = primaryColor ?? AppColors.primary;
    final effectiveBackgroundColor = backgroundColor ?? Colors.white;
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(8);
    final effectivePadding = padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 8);

    return Consumer<MetamaskProvider>(
      builder: (context, provider, _) {
        developer.log('Building CompactMetamaskButton - State: connected=${provider.currentAddress.isNotEmpty}, loading=${provider.isLoading}');
        
        // Version en chargement
        if (provider.isLoading) {
          return Container(
            padding: effectivePadding,
            decoration: BoxDecoration(
              color: effectiveBackgroundColor,
              borderRadius: effectiveBorderRadius,
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(effectivePrimaryColor),
              ),
            ),
          );
        }

        // Version connectée
        if (provider.currentAddress.isNotEmpty) {
          return Container(
            padding: effectivePadding,
            decoration: BoxDecoration(
              color: effectiveBackgroundColor,
              borderRadius: effectiveBorderRadius,
              border: Border.all(color: effectivePrimaryColor),
            ),
            child: InkWell(
              onTap: () => _showWalletOptions(context, provider),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.account_balance_wallet, color: effectivePrimaryColor, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    '${provider.currentAddress.substring(0, 4)}...${provider.currentAddress.substring(provider.currentAddress.length - 4)}',
                    style: TextStyle(
                      color: effectivePrimaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Version non connectée
        return ElevatedButton.icon(
          icon: const Icon(Icons.account_balance_wallet, size: 16),
          label: const Text('Connect Wallet', style: TextStyle(fontSize: 12)),
          style: ElevatedButton.styleFrom(
            backgroundColor: effectiveBackgroundColor,
            foregroundColor: effectivePrimaryColor,
            padding: effectivePadding,
            shape: RoundedRectangleBorder(
              borderRadius: effectiveBorderRadius,
              side: BorderSide(color: Colors.grey.shade300),
            ),
            elevation: 1,
          ),
          onPressed: () {
            developer.log('MetaMask connect button clicked');
            
            try {
              provider.connect().then((success) {
                developer.log('MetaMask connect result: $success');
                
                if (success && provider.currentAddress.isNotEmpty) {
                  if (onUpdatePublicKey != null) {
                    onUpdatePublicKey!(context, provider.currentAddress);
                  }
                } else if (!success && provider.error.isNotEmpty) {
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
            SelectableText(provider.currentAddress),
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
                Navigator.pop(context);
                provider.getEncryptionPublicKey().then((success) {
                  if (success && onUpdatePublicKey != null) {
                    onUpdatePublicKey!(context, provider.currentAddress);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Public key obtained successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else if (provider.error.isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to get public key: ${provider.error}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                });
              },
              child: const Text('Get Public Key'),
            ),
          TextButton(
            onPressed: () {
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