import 'package:equatable/equatable.dart';
import '../../../domain/entities/marketplace_response.dart';

abstract class MarketplaceState extends Equatable {
  const MarketplaceState();

  @override
  List<Object?> get props => [];
}

class MarketplaceInitial extends MarketplaceState {}

class MarketplaceLoading extends MarketplaceState {}

class TokenListingSuccess extends MarketplaceState {
  final ListingResponse response;

  const TokenListingSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

class MultipleTokensListingSuccess extends MarketplaceState {
  final MultipleListingResponse response;

  const MultipleTokensListingSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

class CancelListingSuccess extends MarketplaceState {
  final MarketplaceResponse response;

  const CancelListingSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

class MarketplaceError extends MarketplaceState {
  final String message;

  const MarketplaceError(this.message);

  @override
  List<Object?> get props => [message];
}