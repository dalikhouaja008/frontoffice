// lib/features/auth/domain/entities/token.dart

import 'package:equatable/equatable.dart';

class Token extends Equatable {
  final int tokenId;
  final int landId;
  final int tokenNumber;
  final String owner;
  final PurchaseInfo purchaseInfo;
  final MarketInfo currentMarketInfo;
  final MarketInfo? listingInfo;
  final bool isListed;
  final LandInfo? land; // Changé pour être nullable
  final InvestmentMetrics? investmentMetrics; // Ajouté

  const Token({
    required this.tokenId,
    required this.landId,
    required this.tokenNumber,
    required this.owner,
    required this.purchaseInfo,
    required this.currentMarketInfo,
    this.listingInfo,
    required this.isListed,
    this.land,
    this.investmentMetrics,
  });

  double get returnPercentage {
    final purchasePrice = double.tryParse(purchaseInfo.price) ?? 0;
    final currentPrice = double.tryParse(currentMarketInfo.price) ?? 0;
    if (purchasePrice == 0) return 0;
    return ((currentPrice - purchasePrice) / purchasePrice) * 100;
  }

  @override
  List<Object?> get props => [
        tokenId,
        landId,
        tokenNumber,
        owner,
        purchaseInfo,
        currentMarketInfo,
        listingInfo,
        isListed,
        land,
        investmentMetrics,
      ];
}

class PurchaseInfo extends Equatable {
  final String price;
  final DateTime date;
  final String formattedPrice;

  const PurchaseInfo({
    required this.price,
    required this.date,
    required this.formattedPrice,
  });

  @override
  List<Object> get props => [price, date, formattedPrice];
}

class MarketInfo extends Equatable {
  final String price;
  final double change;
  final String changeFormatted;
  final String formattedPrice;
  final bool isPositive;
  final String? seller;
  final String? listingDate; // Ajout de la propriété listingDate

  const MarketInfo({
    required this.price,
    required this.change,
    required this.changeFormatted,
    required this.formattedPrice,
    required this.isPositive,
    this.seller,
    this.listingDate, // Paramètre optionnel
  });

  @override
  List<Object?> get props => [
    price, 
    change, 
    changeFormatted, 
    formattedPrice, 
    isPositive, 
    seller, 
    listingDate
  ];
}
class LandInfo extends Equatable {
  final String id;
  final String title;
  final String location;
  final int surface;
  final String owner; // Ajouté
  final bool isRegistered; // Ajouté
  final String status; // Ajouté
  final int totalTokens; // Ajouté
  final int availableTokens; // Ajouté
  final String pricePerToken; // Ajouté
  final String? imageUrl;

  const LandInfo({
    required this.id,
    required this.title,
    required this.location,
    required this.surface,
    required this.owner,
    required this.isRegistered,
    required this.status,
    required this.totalTokens,
    required this.availableTokens,
    required this.pricePerToken,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [id, title, location, surface, owner, isRegistered, status, totalTokens, availableTokens, pricePerToken, imageUrl];
}

// Nouvelle classe pour les métriques d'investissement
class InvestmentMetrics extends Equatable {
  final int potential;
  final String rating;

  const InvestmentMetrics({
    required this.potential,
    required this.rating,
  });

  @override
  List<Object> get props => [potential, rating];
}