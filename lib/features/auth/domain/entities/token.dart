// lib/features/investment/domain/entities/token.dart
class Token {
  final int tokenId;
  final int landId;
  final int tokenNumber;
  final String owner;
  final PurchaseInfo purchaseInfo;
  final MarketInfo currentMarketInfo;
  final MarketInfo? listingInfo;
  final bool isListed;
  final LandInfo land;

  Token({
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
}

class PurchaseInfo {
  final String price;
  final DateTime date;
  final String formattedPrice;

  PurchaseInfo({
    required this.price,
    required this.date,
    required this.formattedPrice,
  });
}

class MarketInfo {
  final String price;
  final double change;
  final String changeFormatted;
  final String formattedPrice;
  final String? seller;

  MarketInfo({
    required this.price,
    required this.change,
    required this.changeFormatted,
    required this.formattedPrice,
    this.seller,
  });
}

class LandInfo {
  final String id;
  final String title;
  final String location;
  final int surface;
  final String? imageUrl;

  LandInfo({
    required this.id,
    required this.title,
    required this.location,
    required this.surface,
    this.imageUrl,
  });
}