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
  final LandInfo land;

  const Token({
    required this.tokenId,
    required this.landId,
    required this.tokenNumber,
    required this.owner,
    required this.purchaseInfo,
    required this.currentMarketInfo,
    this.listingInfo,
    required this.isListed,
    required this.land,
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
  final String? seller;

  const MarketInfo({
    required this.price,
    required this.change,
    required this.changeFormatted,
    required this.formattedPrice,
    this.seller,
  });

  @override
  List<Object?> get props => [price, change, changeFormatted, formattedPrice, seller];
}

class LandInfo extends Equatable {
  final String id;
  final String title;
  final String location;
  final int surface;
  final String? imageUrl;

  const LandInfo({
    required this.id,
    required this.title,
    required this.location,
    required this.surface,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [id, title, location, surface, imageUrl];
}