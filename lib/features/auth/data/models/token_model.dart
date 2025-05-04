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
    required LandInfoModel land,
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
        );

  factory TokenModel.fromJson(Map<String, dynamic> json) {
    return TokenModel(
      tokenId: json['tokenId'],
      landId: json['landId'],
      tokenNumber: json['tokenNumber'],
      owner: json['owner'],
      purchaseInfo: PurchaseInfoModel.fromJson(json['purchaseInfo']),
      currentMarketInfo: MarketInfoModel.fromJson(json['currentMarketInfo']),
      listingInfo: json['listingInfo'] != null
          ? MarketInfoModel.fromJson(json['listingInfo'])
          : null,
      isListed: json['isListed'],
      land: LandInfoModel.fromJson(json['land']),
    );
  }
}

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
      price: json['price'],
      date: DateTime.parse(json['date']),
      formattedPrice: json['formattedPrice'],
    );
  }
}

class MarketInfoModel extends MarketInfo {
  MarketInfoModel({
    required String price,
    required double change,
    required String changeFormatted,
    required String formattedPrice,
    String? seller,
  }) : super(
          price: price,
          change: change,
          changeFormatted: changeFormatted,
          formattedPrice: formattedPrice,
          seller: seller,
        );

  factory MarketInfoModel.fromJson(Map<String, dynamic> json) {
    return MarketInfoModel(
      price: json['price'],
      change: json['change'].toDouble(),
      changeFormatted: json['changeFormatted'],
      formattedPrice: json['formattedPrice'],
      seller: json['seller'],
    );
  }
}

class LandInfoModel extends LandInfo {
  LandInfoModel({
    required String id,
    required String title,
    required String location,
    required int surface,
    String? imageUrl,
  }) : super(
          id: id,
          title: title,
          location: location,
          surface: surface,
          imageUrl: imageUrl,
        );

  factory LandInfoModel.fromJson(Map<String, dynamic> json) {
    return LandInfoModel(
      id: json['id'],
      title: json['title'],
      location: json['location'],
      surface: json['surface'],
      imageUrl: json['imageUrl'],
    );
  }
}