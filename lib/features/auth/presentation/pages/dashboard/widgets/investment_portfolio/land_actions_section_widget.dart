import 'package:flutter/material.dart';
import 'package:the_boost/core/constants/colors.dart';
import 'package:the_boost/core/constants/dimensions.dart';
import 'package:the_boost/core/utils/responsive_helper.dart';
import 'package:the_boost/features/auth/domain/entities/token.dart';

import 'portfolio_utils.dart';

class LandActionsSectionWidget extends StatelessWidget {
  final String landTitle;
  final int tokenCount;
  final bool anyListed;
  final List<Token> listedTokens;
  final List<Token> tokens;
  final Function(BuildContext, List<Token>) onShowCancelDialog;
  final String currentDate;
  final String userName;

  const LandActionsSectionWidget({
    Key? key,
    required this.landTitle,
    required this.tokenCount,
    required this.anyListed,
    required this.listedTokens,
    required this.tokens,
    required this.onShowCancelDialog,
    required this.currentDate,
    required this.userName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppDimensions.paddingL,
        right: AppDimensions.paddingL,
        bottom: AppDimensions.paddingM,
      ),
      child: Row(
        children: [
          // Bouton de vente
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () {
                // Naviguer vers la page de vente
                final formattedTokens = PortfolioUtils.convertTokensToSellingFormat(
                  tokens, 
                  currentDate,
                  userName,
                );
                Navigator.pushNamed(
                  context,
                  '/token-selling',
                  arguments: {
                    'tokens': formattedTokens,
                    'selectedTokenIndex': 0,
                    'landName': landTitle,
                  },
                );
                
                print('[$currentDate] InvestmentPortfolio: 🔄 Navigating to token selling page'
                    '\n└─ User: $userName'
                    '\n└─ Land: $landTitle'
                    '\n└─ Total Tokens: $tokenCount');
              },
              icon: const Icon(Icons.sell, size: 16),
              label: Text(ResponsiveHelper.isMobile(context) 
                  ? "Sell" 
                  : "Sell Tokens"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          
          // N'afficher le bouton d'annulation que si des tokens sont mis en vente
          if (anyListed) ...[
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: ElevatedButton.icon(
                onPressed: () => onShowCancelDialog(context, listedTokens),
                icon: const Icon(Icons.cancel, size: 16),
                label: Text(ResponsiveHelper.isMobile(context) 
                    ? "Cancel Listing" 
                    : "Cancel ${listedTokens.length} Listing${listedTokens.length > 1 ? 's' : ''}"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}