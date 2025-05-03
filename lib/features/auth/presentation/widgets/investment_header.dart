// presentation/pages/invest/widgets/investment_header.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../metamask/data/models/metamask_provider.dart';

class InvestmentHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal:
            isMobile ? AppDimensions.paddingL : AppDimensions.paddingXXL,
        vertical: isMobile ? AppDimensions.paddingXL : AppDimensions.paddingXXL,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundGreen,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add a row to contain both the title and the MetaMask button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Investment Opportunities",
                      style: AppTextStyles.h2.copyWith(
                        fontSize: isMobile ? 24 : 32,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Discover and invest in premium tokenized land assets",
                      style: AppTextStyles.body2.copyWith(
                        fontSize: isMobile ? 14 : 18,
                      ),
                    ),
                  ],
                ),
              ),

              // MetaMask button
              _MetamaskButton(),
            ],
          ),
          SizedBox(height: 20),
          _buildStatCards(context),
        ],
      ),
    );
  }

  Widget _buildStatCards(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return isMobile
        ? const Column(
            children: [
              _StatCard(
                value: '26',
                label: 'Available Properties',
                icon: Icons.location_on,
              ),
              SizedBox(height: 10),
              _StatCard(
                value: '\$100',
                label: 'Minimum Investment',
                icon: Icons.attach_money,
              ),
              SizedBox(height: 10),
              _StatCard(
                value: '8.4%',
                label: 'Avg. Annual Return',
                icon: Icons.trending_up,
              ),
            ],
          )
        : Row(
            children: [
              Expanded(
                child: _StatCard(
                  value: '26',
                  label: 'Available Properties',
                  icon: Icons.location_on,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  value: '\$100',
                  label: 'Minimum Investment',
                  icon: Icons.attach_money,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  value: '8.4%',
                  label: 'Avg. Annual Return',
                  icon: Icons.trending_up,
                ),
              ),
            ],
          );
  }
}

class _MetamaskButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return Consumer<MetamaskProvider>(
      builder: (context, provider, _) {
        // When connecting/loading
        if (provider.isLoading) {
          return Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingM,
              vertical: AppDimensions.paddingS,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'Connecting...',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: isMobile ? 12 : 14,
                  ),
                ),
              ],
            ),
          );
        }

        // When connected
        if (provider.currentAddress.isNotEmpty) {
          return InkWell(
            onTap: () => _showWalletOptions(context, provider),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingM,
                vertical: AppDimensions.paddingS,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                border: Border.all(color: AppColors.primary),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    color: AppColors.primary,
                    size: isMobile ? 18 : 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    '${provider.currentAddress.substring(0, 4)}...${provider.currentAddress.substring(provider.currentAddress.length - 4)}',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: isMobile ? 12 : 14,
                    ),
                  ),
                  if (provider.success) ...[
                    SizedBox(width: 4),
                    Icon(
                      Icons.check_circle,
                      color: AppColors.primary,
                      size: isMobile ? 14 : 16,
                    ),
                  ],
                ],
              ),
            ),
          );
        }

        // Not connected - default state
        return ElevatedButton.icon(
          icon: Icon(
            Icons.account_balance_wallet,
            size: isMobile ? 18 : 20,
          ),
          label: Text(
            'Connect Wallet',
            style: TextStyle(
              fontSize: isMobile ? 12 : 14,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.primary,
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingM,
              vertical: AppDimensions.paddingS,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
            ),
            elevation: 2,
          ),
          onPressed: () => provider.connect(),
        );
      },
    );
  }

  void _showWalletOptions(BuildContext context, MetamaskProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Wallet Connected'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your Ethereum Address:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text(provider.currentAddress),
            SizedBox(height: 16),
            if (provider.publicKey.isNotEmpty) ...[
              Text('Public Key Status:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.check_circle, color: AppColors.primary, size: 16),
                  SizedBox(width: 4),
                  Text('Public Key Saved'),
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
                provider.getEncryptionPublicKey();
              },
              child: Text('Get Public Key'),
            ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              provider.disconnect();
            },
            child: Text('Disconnect'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return Container(
      padding: EdgeInsets.all(
          isMobile ? AppDimensions.paddingM : AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.backgroundGreen,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: isMobile ? 18 : 24,
            ),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: isMobile ? 16 : 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: isMobile ? 10 : 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
