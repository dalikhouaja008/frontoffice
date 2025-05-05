import 'package:equatable/equatable.dart';
import '../../domain/entities/token.dart';

abstract class MarketplaceState extends Equatable {
  const MarketplaceState();
  
  @override
  List<Object?> get props => [];
}

class MarketplaceInitial extends MarketplaceState {}

class MarketplaceLoading extends MarketplaceState {}

class ListingsLoaded extends MarketplaceState {
  final List<Token> listings;

  const ListingsLoaded(this.listings);

  @override
  List<Object?> get props => [listings];
}

class ListingDetailsLoaded extends MarketplaceState {
  final Token token;

  const ListingDetailsLoaded(this.token);

  @override
  List<Object?> get props => [token];
}

class PurchaseSuccess extends MarketplaceState {}

class MarketplaceError extends MarketplaceState {
  final String message;

  const MarketplaceError(this.message);

  @override
  List<Object?> get props => [message];
}