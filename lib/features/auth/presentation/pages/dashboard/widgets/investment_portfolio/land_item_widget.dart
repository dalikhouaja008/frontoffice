import 'package:flutter/material.dart';
import 'package:the_boost/core/constants/dimensions.dart';
import 'package:the_boost/features/auth/domain/entities/token.dart';

import 'land_info_section_widget.dart';
import 'land_actions_section_widget.dart';

class LandItemWidget extends StatelessWidget {
  final int landId;
  final List<Token> tokens;
  final Function(int) onCancelListing;
  final Function(BuildContext, List<Token>) onShowCancelDialog;
  final String currentDate;
  final String userName;

  const LandItemWidget({
    Key? key,
    required this.landId,
    required this.tokens,
    required this.onCancelListing,
    required this.onShowCancelDialog,
    required this.currentDate,
    required this.userName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Chercher un token avec des infos de terrain (land non-null)
    Token? referenceTokenWithLand;
    for (var token in tokens) {
      if (token.land != null) {
        referenceTokenWithLand = token;
        break;
      }
    }
    
    // Utiliser le premier token comme référence si aucun n'a de terrain défini
    final Token referenceToken = referenceTokenWithLand ?? tokens.first;
    final land = referenceToken.land;
    
    // Titre et emplacement du terrain (par défaut si land est null)
    final landTitle = land?.title ?? 'Land #$landId';
    final landLocation = land?.location ?? 'Unknown Location';
    final landImageUrl = land?.imageUrl;

    // Calculer le nombre total de tokens et la valeur combinée
    final int tokenCount = tokens.length;
    final double totalValue = tokens.fold(
        0.0,
        (sum, token) =>
            sum + (double.tryParse(token.currentMarketInfo.price) ?? 0.0));
    final double totalOriginalValue = tokens.fold(
        0.0,
        (sum, token) =>
            sum + (double.tryParse(token.purchaseInfo.price) ?? 0.0));

    // Calculer le profit/perte global
    final double profitLoss = totalValue - totalOriginalValue;
    final double profitLossPercentage =
        totalOriginalValue > 0 ? (profitLoss / totalOriginalValue) * 100 : 0.0;

    // Formater les valeurs
    final formattedTotalValue = "${totalValue.toStringAsFixed(4)} ETH";
    final formattedPercentage =
        "${profitLossPercentage >= 0 ? '+' : ''}${profitLossPercentage.toStringAsFixed(2)}%";

    // Est-ce qu'un token de ce terrain est mis en vente?
    final bool anyListed = tokens.any((token) => token.isListed);
    
    // Récupérer les tokens mis en vente
    final listedTokens = tokens.where((token) => token.isListed).toList();

    return Column(
      children: [
        // Informations sur le terrain
        LandInfoSectionWidget(
          landId: landId,
          landTitle: landTitle,
          landLocation: landLocation,
          landImageUrl: landImageUrl,
          tokenCount: tokenCount,
          anyListed: anyListed,
          listedTokens: listedTokens,
          formattedTotalValue: formattedTotalValue,
          profitLoss: profitLoss,
          formattedPercentage: formattedPercentage,
        ),
        
        // Boutons d'action
        LandActionsSectionWidget(
          landTitle: landTitle,
          tokenCount: tokenCount,
          anyListed: anyListed,
          listedTokens: listedTokens,
          tokens: tokens,
          onShowCancelDialog: onShowCancelDialog,
          currentDate: currentDate,
          userName: userName,
        ),
      ],
    );
  }
}