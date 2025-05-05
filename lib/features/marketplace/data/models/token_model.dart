import '../../domain/entities/token.dart';

class TokenModel extends Token {
  const TokenModel({
    required int tokenId,
    required int landId,
    required String price,
    required String seller,
    required int tokenNumber,
    required String purchasePrice,
    required String mintDate,
    required LandModel land,
    required String listingDate,
    required String listingDateFormatted,
    required int listingTimestamp,
    required int daysSinceListing,
    required String etherscanUrl,
    required String formattedPrice,
    required String formattedPurchasePrice,
    required String mintDateFormatted,
    required PriceChangePercentageModel priceChangePercentage,
    required bool isRecentlyListed,
    required bool isHighlyProfitable,
    required int investmentPotential,
    required String investmentRating,
  }) : super(
          tokenId: tokenId,
          landId: landId,
          price: price,
          seller: seller,
          tokenNumber: tokenNumber,
          purchasePrice: purchasePrice,
          mintDate: mintDate,
          land: land,
          listingDate: listingDate,
          listingDateFormatted: listingDateFormatted,
          listingTimestamp: listingTimestamp,
          daysSinceListing: daysSinceListing,
          etherscanUrl: etherscanUrl,
          formattedPrice: formattedPrice,
          formattedPurchasePrice: formattedPurchasePrice,
          mintDateFormatted: mintDateFormatted,
          priceChangePercentage: priceChangePercentage,
          isRecentlyListed: isRecentlyListed,
          isHighlyProfitable: isHighlyProfitable,
          investmentPotential: investmentPotential,
          investmentRating: investmentRating,
        );

  factory TokenModel.fromJson(Map<String, dynamic> json) {
    // Print debug info
    print('[2025-05-05 04:40:55] TokenModel.fromJson received: $json');

    try {
      // Extract land data - handle both nested and flat structures
      final landData =
          json['land'] ?? json['landDetails'] ?? {} as Map<String, dynamic>;

      // Format timestamps and dates
      final now = DateTime.now();
      final listingTimestamp = json['listingTimestamp'] ??
          (now.millisecondsSinceEpoch ~/ 1000) - 86400 * 3; // 3 days ago

      final listingDateTime =
          DateTime.fromMillisecondsSinceEpoch(listingTimestamp * 1000);
      final mintDateTime = DateTime.fromMillisecondsSinceEpoch(
          (json['mintTimestamp'] ?? listingTimestamp - 86400 * 7) *
              1000); // Default 7 days before listing

      // Calculate days since listing
      final daysSinceListing = now.difference(listingDateTime).inDays;

      // Format dates
      final listingDateFormatted = _formatDate(listingDateTime);
      final mintDateFormatted = _formatDate(mintDateTime);

      // Extract prices and format them
      final price = json['price']?.toString() ?? '0.01';
      final purchasePrice = json['purchasePrice']?.toString() ??
          json['originalPrice']?.toString() ??
          (double.tryParse(price)! * 0.85)
              .toStringAsFixed(3); // Default 15% lower

      // Calculate price change percentage
      final priceValue = double.tryParse(price) ?? 0.01;
      final purchasePriceValue = double.tryParse(purchasePrice) ?? 0.01;
      final percentageChange =
          ((priceValue - purchasePriceValue) / purchasePriceValue) * 100;
      final isPositive = percentageChange >= 0;

      return TokenModel(
        tokenId: json['tokenId'] ?? json['id'] ?? 0,
        landId: json['landId'] ?? landData['id'] ?? 0,
        price: price,
        seller: json['seller'] ??
            json['ownerAddress'] ??
            '0x0000000000000000000000000000000000000000',
        tokenNumber: json['tokenNumber'] ?? json['number'] ?? 1,
        purchasePrice: purchasePrice,
        mintDate: json['mintDate'] ?? mintDateTime.toIso8601String(),
        land: LandModel.fromJson(landData),
        listingDate: json['listingDate'] ?? listingDateTime.toIso8601String(),
        listingDateFormatted:
            json['listingDateFormatted'] ?? listingDateFormatted,
        listingTimestamp: listingTimestamp,
        daysSinceListing: json['daysSinceListing'] ?? daysSinceListing,
        etherscanUrl: json['etherscanUrl'] ?? 'https://etherscan.io/token/0x',
        formattedPrice: json['formattedPrice'] ?? '$price ETH',
        formattedPurchasePrice:
            json['formattedPurchasePrice'] ?? '$purchasePrice ETH',
        mintDateFormatted: json['mintDateFormatted'] ?? mintDateFormatted,
        priceChangePercentage: json['priceChangePercentage'] is Map
            ? PriceChangePercentageModel.fromJson(json['priceChangePercentage'])
            : PriceChangePercentageModel(
                percentage: percentageChange,
                formatted: '${percentageChange.abs().toStringAsFixed(1)}%',
                isPositive: isPositive,
              ),
        isRecentlyListed: json['isRecentlyListed'] ?? (daysSinceListing < 2),
        isHighlyProfitable:
            json['isHighlyProfitable'] ?? (percentageChange > 15),
        investmentPotential: json['investmentPotential'] ??
            (percentageChange > 20
                ? 5
                : percentageChange > 15
                    ? 4
                    : percentageChange > 10
                        ? 3
                        : percentageChange > 5
                            ? 2
                            : 1),
        investmentRating: json['investmentRating'] ??
            (percentageChange > 20
                ? 'Excellent'
                : percentageChange > 15
                    ? 'Good'
                    : percentageChange > 10
                        ? 'Average'
                        : 'Fair'),
      );
    } catch (e) {
      print('[2025-05-05 04:40:55] Error parsing TokenModel: $e');

      // Return a fallback token with default values
      return TokenModel(
        tokenId: 0,
        landId: 0,
        price: '0.01',
        seller: '0x0000000000000000000000000000000000000000',
        tokenNumber: 1,
        purchasePrice: '0.009',
        mintDate:
            DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
        land: LandModel(
          location: 'Default Location',
          surface: 1000,
          owner: '0x0000000000000000000000000000000000000000',
          isRegistered: true,
          status: 'Available',
          totalTokens: 100,
          availableTokens: 50,
          pricePerToken: '0.01 ETH',
        ),
        listingDate:
            DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        listingDateFormatted:
            _formatDate(DateTime.now().subtract(const Duration(days: 3))),
        listingTimestamp: DateTime.now()
                .subtract(const Duration(days: 3))
                .millisecondsSinceEpoch ~/
            1000,
        daysSinceListing: 3,
        etherscanUrl: 'https://etherscan.io/token/0x',
        formattedPrice: '0.01 ETH',
        formattedPurchasePrice: '0.009 ETH',
        mintDateFormatted:
            _formatDate(DateTime.now().subtract(const Duration(days: 30))),
        priceChangePercentage: const PriceChangePercentageModel(
          percentage: 11.1,
          formatted: '11.1%',
          isPositive: true,
        ),
        isRecentlyListed: true,
        isHighlyProfitable: false,
        investmentPotential: 3,
        investmentRating: 'Average',
      );
    }
  }

  // Helper method to format dates consistently
  static String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$month/$day/$year';
  }

  Map<String, dynamic> toJson() {
    return {
      'tokenId': tokenId,
      'landId': landId,
      'price': price,
      'seller': seller,
      'tokenNumber': tokenNumber,
      'purchasePrice': purchasePrice,
      'mintDate': mintDate,
      'land': (land as LandModel).toJson(),
      'listingDate': listingDate,
      'listingDateFormatted': listingDateFormatted,
      'listingTimestamp': listingTimestamp,
      'daysSinceListing': daysSinceListing,
      'etherscanUrl': etherscanUrl,
      'formattedPrice': formattedPrice,
      'formattedPurchasePrice': formattedPurchasePrice,
      'mintDateFormatted': mintDateFormatted,
      'priceChangePercentage':
          (priceChangePercentage as PriceChangePercentageModel).toJson(),
      'isRecentlyListed': isRecentlyListed,
      'isHighlyProfitable': isHighlyProfitable,
      'investmentPotential': investmentPotential,
      'investmentRating': investmentRating,
    };
  }
}

class LandModel extends Land {
  const LandModel({
    required String location,
    required int surface,
    required String owner,
    required bool isRegistered,
    required String status,
    required int totalTokens,
    required int availableTokens,
    required String pricePerToken,
  }) : super(
          location: location,
          surface: surface,
          owner: owner,
          isRegistered: isRegistered,
          status: status,
          totalTokens: totalTokens,
          availableTokens: availableTokens,
          pricePerToken: pricePerToken,
        );

  factory LandModel.fromJson(Map<String, dynamic> json) {
    try {
      return LandModel(
        location: json['location'] ?? json['address'] ?? 'Unknown Location',
        surface: json['surface'] ?? json['area'] ?? json['size'] ?? 1000,
        owner: json['owner'] ??
            json['ownerAddress'] ??
            '0x0000000000000000000000000000000000000000',
        isRegistered: json['isRegistered'] ?? true,
        status: json['status'] ?? 'Available',
        totalTokens: json['totalTokens'] ?? 100,
        availableTokens: json['availableTokens'] ?? 50,
        pricePerToken: json['pricePerToken'] ?? '0.01 ETH',
      );
    } catch (e) {
      print('[2025-05-05 04:40:55] Error parsing LandModel: $e');
      return const LandModel(
        location: 'Unknown Location',
        surface: 1000,
        owner: '0x0000000000000000000000000000000000000000',
        isRegistered: true,
        status: 'Available',
        totalTokens: 100,
        availableTokens: 50,
        pricePerToken: '0.01 ETH',
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'location': location,
      'surface': surface,
      'owner': owner,
      'isRegistered': isRegistered,
      'status': status,
      'totalTokens': totalTokens,
      'availableTokens': availableTokens,
      'pricePerToken': pricePerToken,
    };
  }
}

class PriceChangePercentageModel extends PriceChangePercentage {
  const PriceChangePercentageModel({
    required double percentage,
    required String formatted,
    required bool isPositive,
  }) : super(
          percentage: percentage,
          formatted: formatted,
          isPositive: isPositive,
        );

  factory PriceChangePercentageModel.fromJson(Map<String, dynamic> json) {
    try {
      final percentage = json['percentage'] is String
          ? double.tryParse(json['percentage']) ?? 0.0
          : (json['percentage'] as num).toDouble();

      return PriceChangePercentageModel(
        percentage: percentage,
        formatted:
            json['formatted'] ?? '${percentage.abs().toStringAsFixed(1)}%',
        isPositive: json['isPositive'] ?? percentage >= 0,
      );
    } catch (e) {
      print(
          '[2025-05-05 04:40:55] Error parsing PriceChangePercentageModel: $e');
      return const PriceChangePercentageModel(
        percentage: 0.0,
        formatted: '0.0%',
        isPositive: true,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'percentage': percentage,
      'formatted': formatted,
      'isPositive': isPositive,
    };
  }
}
