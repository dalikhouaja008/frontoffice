class MarketplaceResponse {
  final bool success;
  final dynamic data;
  final String message;

  MarketplaceResponse({
    required this.success,
    required this.data,
    required this.message,
  });
}

class ListingResponse extends MarketplaceResponse {
  ListingResponse({
    required bool success,
    required dynamic data,
    required String message,
  }) : super(success: success, data: data, message: message);
}

class MultipleListingResponse extends MarketplaceResponse {
  final int count;
  
  MultipleListingResponse({
    required bool success,
    required dynamic data,
    required String message,
    required this.count,
  }) : super(success: success, data: data, message: message);
}