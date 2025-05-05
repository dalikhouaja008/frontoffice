import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_boost/core/error/failure.dart';
import 'package:the_boost/core/use_cases/usecase.dart';
import '../../domain/usecases/get_all_listings.dart';
import '../../domain/usecases/get_filtered_listings.dart';
import '../../domain/usecases/get_listing_details.dart';
import '../../domain/usecases/purchase_token.dart';
import 'marketplace_event.dart';
import 'marketplace_state.dart';

class MarketplaceBloc extends Bloc<MarketplaceEvent, MarketplaceState> {
  final GetAllListings getAllListings;
  final GetFilteredListings getFilteredListings;
  final GetListingDetails getListingDetails;
  final PurchaseToken purchaseToken;

  MarketplaceBloc({
    required this.getAllListings,
    required this.getFilteredListings,
    required this.getListingDetails,
    required this.purchaseToken,
  }) : super(MarketplaceInitial()) {
    on<GetAllListingsEvent>(_onGetAllListings);
    on<GetFilteredListingsEvent>(_onGetFilteredListings);
    on<GetListingDetailsEvent>(_onGetListingDetails);
    on<PurchaseTokenEvent>(_onPurchaseToken);
  }

  Future<void> _onGetAllListings(
      GetAllListingsEvent event, Emitter<MarketplaceState> emit) async {
    emit(MarketplaceLoading());
    final result = await getAllListings(NoParams());
    result.fold(
      (failure) => emit(MarketplaceError(_mapFailureToMessage(failure))),
      (listings) => emit(ListingsLoaded(listings)),
    );
  }

  Future<void> _onGetFilteredListings(
      GetFilteredListingsEvent event, Emitter<MarketplaceState> emit) async {
    emit(MarketplaceLoading());
    final result = await getFilteredListings(FilteredListingsParams(
      query: event.query,
      minPrice: event.minPrice,
      maxPrice: event.maxPrice,
      category: event.category,
      sortBy: event.sortBy,
    ));
    result.fold(
      (failure) => emit(MarketplaceError(_mapFailureToMessage(failure))),
      (listings) => emit(ListingsLoaded(listings)),
    );
  }

  Future<void> _onGetListingDetails(
      GetListingDetailsEvent event, Emitter<MarketplaceState> emit) async {
    emit(MarketplaceLoading());
    final result = await getListingDetails(ListingDetailsParams(
      tokenId: event.tokenId,
    ));
    result.fold(
      (failure) => emit(MarketplaceError(_mapFailureToMessage(failure))),
      (token) => emit(ListingDetailsLoaded(token)),
    );
  }

  Future<void> _onPurchaseToken(
      PurchaseTokenEvent event, Emitter<MarketplaceState> emit) async {
    emit(MarketplaceLoading());
    final result = await purchaseToken(PurchaseTokenParams(
      tokenId: event.tokenId,
      buyerAddress: event.buyerAddress,
    ));
    result.fold(
      (failure) => emit(MarketplaceError(_mapFailureToMessage(failure))),
      (_) => emit(PurchaseSuccess()),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Server error occurred. Please try again later.';
      case CacheFailure:
        return 'Cache error occurred. Please try again.';
      case NetworkFailure:
        return 'Network error. Please check your connection.';
      default:
        return 'Unexpected error occurred.';
    }
  }
}