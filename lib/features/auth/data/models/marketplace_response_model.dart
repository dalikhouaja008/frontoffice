import '../../domain/entities/marketplace_response.dart';

class MarketplaceResponseModel extends MarketplaceResponse {
  MarketplaceResponseModel({
    required bool success,
    required dynamic data,
    required String message,
  }) : super(success: success, data: data, message: message);

  factory MarketplaceResponseModel.fromJson(Map<String, dynamic> json) {
    return MarketplaceResponseModel(
      success: json['success'] ?? false,
      data: json['data'],
      message: json['message'] ?? 'No message provided',
    );
  }
}

class ListingResponseModel extends ListingResponse {
  ListingResponseModel({
    required bool success,
    required dynamic data,
    required String message,
  }) : super(success: success, data: data, message: message);

  factory ListingResponseModel.fromJson(Map<String, dynamic> json) {
    return ListingResponseModel(
      success: json['success'] ?? false,
      data: json['data'],
      message: json['message'] ?? 'No message provided',
    );
  }
}

class MultipleListingResponseModel extends MultipleListingResponse {
  MultipleListingResponseModel({
    required bool success,
    required dynamic data,
    required String message,
    required int count,
  }) : super(success: success, data: data, message: message, count: count);

  factory MultipleListingResponseModel.fromJson(Map<String, dynamic> json) {
    return MultipleListingResponseModel(
      success: json['success'] ?? false,
      data: json['data'],
      message: json['message'] ?? 'No message provided',
      count: json['data']?['count'] ?? 0,
    );
  }
}