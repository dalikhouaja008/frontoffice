import '../../domain/entities/token.dart';

class TokenModel extends Token {
  TokenModel({
    required int tokenId,
    required int landId,
    required int tokenNumber,
    required String owner,
    required PurchaseInfoModel purchaseInfo,
    required MarketInfoModel currentMarketInfo,
    MarketInfoModel? listingInfo,
    required bool isListed,
    LandInfoModel? land,
    InvestmentMetricsModel? investmentMetrics, 
  }) : super(
          tokenId: tokenId,
          landId: landId,
          tokenNumber: tokenNumber,
          owner: owner,
          purchaseInfo: purchaseInfo,
          currentMarketInfo: currentMarketInfo,
          listingInfo: listingInfo,
          isListed: isListed,
          land: land,
          investmentMetrics: investmentMetrics,
        );

  factory TokenModel.fromJson(Map<String, dynamic> json) {
    return TokenModel(
      tokenId: json['tokenId'] ?? 0,
      landId: json['landId'] ?? 0,
      tokenNumber: json['tokenNumber'] ?? 0,
      owner: json['owner'] ?? '',
      purchaseInfo: PurchaseInfoModel.fromJson(json['purchaseInfo'] ?? {}),
      currentMarketInfo: MarketInfoModel.fromJson(json['currentMarketInfo'] ?? {}),
      listingInfo: json['listingInfo'] != null
          ? MarketInfoModel.fromJson(json['listingInfo'])
          : null,
      isListed: json['isListed'] ?? false,
      land: json['land'] != null ? LandInfoModel.fromJson(json['land']) : null,
      investmentMetrics: json['investmentMetrics'] != null
          ? InvestmentMetricsModel.fromJson(json['investmentMetrics'])
          : null,
    );
  }

  // Ajout de la méthode toJson manquante
  Map<String, dynamic> toJson() {
    return {
      'tokenId': tokenId,
      'landId': landId,
      'tokenNumber': tokenNumber,
      'owner': owner,
      'purchaseInfo': (purchaseInfo as PurchaseInfoModel).toJson(),
      'currentMarketInfo': (currentMarketInfo as MarketInfoModel).toJson(),
      'listingInfo': listingInfo != null ? (listingInfo as MarketInfoModel).toJson() : null,
      'isListed': isListed,
      'land': land != null ? (land as LandInfoModel).toJson() : null,
      'investmentMetrics': investmentMetrics != null 
          ? (investmentMetrics as InvestmentMetricsModel).toJson() 
          : null,
    };
  }
}

// Ajout des méthodes toJson pour les sous-modèles
class PurchaseInfoModel extends PurchaseInfo {
  PurchaseInfoModel({
    required String price,
    required DateTime date,
    required String formattedPrice,
  }) : super(
          price: price,
          date: date,
          formattedPrice: formattedPrice,
        );

  factory PurchaseInfoModel.fromJson(Map<String, dynamic> json) {
    return PurchaseInfoModel(
      price: json['price'] ?? '0',
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      formattedPrice: json['formattedPrice'] ?? '0 ETH',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'price': price,
      'date': date.toIso8601String(),
      'formattedPrice': formattedPrice,
    };
  }
}

class MarketInfoModel extends MarketInfo {
  MarketInfoModel({
    required String price,
    required double change,
    required String changeFormatted,
    required String formattedPrice,
    required bool isPositive, // Ajouté pour correspondre au JSON
    String? seller,
  }) : super(
          price: price,
          change: change,
          changeFormatted: changeFormatted,
          formattedPrice: formattedPrice,
          isPositive: isPositive,
          seller: seller,
        );

  factory MarketInfoModel.fromJson(Map<String, dynamic> json) {
    return MarketInfoModel(
      price: json['price'] ?? '0',
      change: (json['change'] ?? 0).toDouble(),
      changeFormatted: json['changeFormatted'] ?? '0%',
      formattedPrice: json['formattedPrice'] ?? '0 ETH',
      isPositive: json['isPositive'] ?? false,
      seller: json['seller'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'price': price,
      'change': change,
      'changeFormatted': changeFormatted,
      'formattedPrice': formattedPrice,
      'isPositive': isPositive,
      'seller': seller,
    };
  }
}

class LandInfoModel extends LandInfo {
  LandInfoModel({
    String? id,
    String? title,
    required String location,
    required int surface,
    required String owner,
    required bool isRegistered,
    required String status,
    required int totalTokens,
    required int availableTokens,
    required String pricePerToken,
    String? imageUrl,
  }) : super(
          id: id ?? '',
          title: title ?? '',
          location: location,
          surface: surface,
          owner: owner,
          isRegistered: isRegistered,
          status: status,
          totalTokens: totalTokens,
          availableTokens: availableTokens,
          pricePerToken: pricePerToken,
          imageUrl: imageUrl,
        );

  factory LandInfoModel.fromJson(Map<String, dynamic> json) {
    return LandInfoModel(
      id: json['id'],
      title: json['title'],
      location: json['location'] ?? '',
      surface: json['surface'] ?? 0,
      owner: json['owner'] ?? '',
      isRegistered: json['isRegistered'] ?? false,
      status: json['status'] ?? '',
      totalTokens: json['totalTokens'] ?? 0,
      availableTokens: json['availableTokens'] ?? 0,
      pricePerToken: json['pricePerToken'] ?? '0',
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'location': location,
      'surface': surface,
      'owner': owner,
      'isRegistered': isRegistered,
      'status': status,
      'totalTokens': totalTokens,
      'availableTokens': availableTokens,
      'pricePerToken': pricePerToken,
      'imageUrl': imageUrl,
    };
  }
}

// Ajout d'une nouvelle classe pour gérer les métriques d'investissement
class InvestmentMetricsModel extends InvestmentMetrics {
  InvestmentMetricsModel({
    required int potential,
    required String rating,
  }) : super(
          potential: potential,
          rating: rating,
        );

  factory InvestmentMetricsModel.fromJson(Map<String, dynamic> json) {
    return InvestmentMetricsModel(
      potential: json['potential'] ?? 0,
      rating: json['rating'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'potential': potential,
      'rating': rating,
    };
  }
}