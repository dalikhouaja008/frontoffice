import 'package:equatable/equatable.dart';

abstract class MarketplaceEvent extends Equatable {
  const MarketplaceEvent();

  @override
  List<Object> get props => [];
}

class ListTokenEvent extends MarketplaceEvent {
  final int tokenId;
  final String price;

  const ListTokenEvent({
    required this.tokenId,
    required this.price,
  });

  @override
  List<Object> get props => [tokenId, price];
}

class ListMultipleTokensEvent extends MarketplaceEvent {
  final List<int> tokenIds;
  final List<String> prices;

  const ListMultipleTokensEvent({
    required this.tokenIds,
    required this.prices,
  });

  @override
  List<Object> get props => [tokenIds, prices];
}

class CancelListingEvent extends MarketplaceEvent {
  final int tokenId;

  const CancelListingEvent({
    required this.tokenId,
  });

  @override
  List<Object> get props => [tokenId];
}