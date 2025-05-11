import 'package:equatable/equatable.dart';

class Token extends Equatable {
  final int tokenId;
  final int landId;
  final String price;
  final String seller;
  final int tokenNumber;
  final String purchasePrice;
  final String mintDate;
  final Land land;
  final String listingDate;
  final String listingDateFormatted;
  final int listingTimestamp;
  final int daysSinceListing;
  final String etherscanUrl;
  final String formattedPrice;
  final String formattedPurchasePrice;
  final String mintDateFormatted;
  final PriceChangePercentage priceChangePercentage;
  final bool isRecentlyListed;
  final bool isHighlyProfitable;
  final int investmentPotential;
  final String investmentRating;

  const Token({
    required this.tokenId,
    required this.landId,
    required this.price,
    required this.seller,
    required this.tokenNumber,
    required this.purchasePrice,
    required this.mintDate,
    required this.land,
    required this.listingDate,
    required this.listingDateFormatted,
    required this.listingTimestamp,
    required this.daysSinceListing,
    required this.etherscanUrl,
    required this.formattedPrice,
    required this.formattedPurchasePrice,
    required this.mintDateFormatted,
    required this.priceChangePercentage,
    required this.isRecentlyListed,
    required this.isHighlyProfitable,
    required this.investmentPotential,
    required this.investmentRating,
  });

  @override
  List<Object> get props => [
        tokenId,
        landId,
        price,
        seller,
        tokenNumber,
        purchasePrice,
        mintDate,
        land,
        listingDate,
        listingDateFormatted,
        listingTimestamp,
        daysSinceListing,
        etherscanUrl,
        formattedPrice,
        formattedPurchasePrice,
        mintDateFormatted,
        priceChangePercentage,
        isRecentlyListed,
        isHighlyProfitable,
        investmentPotential,
        investmentRating,
      ];
}

class Land extends Equatable {
  final String location;
  final int surface;
  final String owner;
  final bool isRegistered;
  final String status;
  final int totalTokens;
  final int availableTokens;
  final String pricePerToken;

  const Land({
    required this.location,
    required this.surface,
    required this.owner,
    required this.isRegistered,
    required this.status,
    required this.totalTokens,
    required this.availableTokens,
    required this.pricePerToken,
  });

  @override
  List<Object> get props => [
        location,
        surface,
        owner,
        isRegistered,
        status,
        totalTokens,
        availableTokens,
        pricePerToken,
      ];
}

class PriceChangePercentage extends Equatable {
  final double percentage;
  final String formatted;
  final bool isPositive;

  const PriceChangePercentage({
    required this.percentage,
    required this.formatted,
    required this.isPositive,
  });

  @override
  List<Object> get props => [percentage, formatted, isPositive];
}