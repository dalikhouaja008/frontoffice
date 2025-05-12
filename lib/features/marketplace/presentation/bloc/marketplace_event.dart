import 'package:equatable/equatable.dart';

abstract class MarketplaceEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class GetAllListingsEvent extends MarketplaceEvent {}

class GetFilteredListingsEvent extends MarketplaceEvent {
  final String? query;
  final double? minPrice;
  final double? maxPrice;
  final String? category;
  final String? sortBy;

  GetFilteredListingsEvent({
    this.query,
    this.minPrice,
    this.maxPrice,
    this.category,
    this.sortBy,
  });

  @override
  List<Object?> get props => [query, minPrice, maxPrice, category, sortBy];
}

class GetListingDetailsEvent extends MarketplaceEvent {
  final int tokenId;

  GetListingDetailsEvent({required this.tokenId});

  @override
  List<Object?> get props => [tokenId];
}

class PurchaseTokenEvent extends MarketplaceEvent {
  final int tokenId;
  final String price;

  PurchaseTokenEvent({
    required this.tokenId,
    required this.price, 
  });

  @override
  List<Object?> get props => [tokenId, price];
}

class ClearErrorEvent extends MarketplaceEvent {}