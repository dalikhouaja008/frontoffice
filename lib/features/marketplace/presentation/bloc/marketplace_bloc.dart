import 'package:flutter/foundation.dart';
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
    on<ClearErrorEvent>(_onClearError);
  }

  Future<void> _onGetAllListings(
      GetAllListingsEvent event, Emitter<MarketplaceState> emit) async {
    emit(MarketplaceLoading());
    debugPrint('[${DateTime.now()}] MarketplaceBloc: Loading all listings');
    
    final result = await getAllListings(NoParams());
    
    result.fold(
      (failure) {
        debugPrint('[${DateTime.now()}] MarketplaceBloc: Error loading listings: ${failure.message}');
        emit(MarketplaceError(_mapFailureToMessage(failure)));
      },
      (listings) {
        debugPrint('[${DateTime.now()}] MarketplaceBloc: Loaded ${listings.length} listings');
        emit(ListingsLoaded(listings));
      },
    );
  }

  Future<void> _onGetFilteredListings(
      GetFilteredListingsEvent event, Emitter<MarketplaceState> emit) async {
    emit(MarketplaceLoading());
    debugPrint('[${DateTime.now()}] MarketplaceBloc: Loading filtered listings');
    
    final result = await getFilteredListings(FilteredListingsParams(
      query: event.query,
      minPrice: event.minPrice,
      maxPrice: event.maxPrice,
      category: event.category,
      sortBy: event.sortBy,
    ));
    
    result.fold(
      (failure) {
        debugPrint('[${DateTime.now()}] MarketplaceBloc: Error loading filtered listings: ${failure.message}');
        emit(MarketplaceError(_mapFailureToMessage(failure)));
      },
      (listings) {
        debugPrint('[${DateTime.now()}] MarketplaceBloc: Loaded ${listings.length} filtered listings');
        emit(ListingsLoaded(listings));
      },
    );
  }

  Future<void> _onGetListingDetails(
      GetListingDetailsEvent event, Emitter<MarketplaceState> emit) async {
    emit(MarketplaceLoading());
    debugPrint('[${DateTime.now()}] MarketplaceBloc: Loading details for token ${event.tokenId}');
    
    final result = await getListingDetails(ListingDetailsParams(
      tokenId: event.tokenId,
    ));
    
    result.fold(
      (failure) {
        debugPrint('[${DateTime.now()}] MarketplaceBloc: Error loading token details: ${failure.message}');
        emit(MarketplaceError(_mapFailureToMessage(failure)));
      },
      (token) {
        debugPrint('[${DateTime.now()}] MarketplaceBloc: Loaded details for token ${token.tokenId}');
        emit(ListingDetailsLoaded(token));
      },
    );
  }

 Future<void> _onPurchaseToken(
    PurchaseTokenEvent event, Emitter<MarketplaceState> emit) async {
  emit(MarketplaceLoading());
  debugPrint('[${DateTime.now()}] MarketplaceBloc: Purchasing token ${event.tokenId}');
  
  final result = await purchaseToken(PurchaseTokenParams(
    tokenId: event.tokenId,
    price: event.price, 
  ));
  
  result.fold(
    (failure) {
      debugPrint('[${DateTime.now()}] MarketplaceBloc: Error purchasing token: ${failure.message}');
      emit(MarketplaceError(_mapFailureToMessage(failure)));
    },
    (transaction) {
      // Maintenant on reçoit une Transaction au lieu d'un bool
      debugPrint('[${DateTime.now()}] MarketplaceBloc: Purchase successful with hash: ${transaction.transactionHash}');
      emit(PurchaseSuccess(transaction)); 
    },
  );
}
  
  Future<void> _onClearError(
      ClearErrorEvent event, Emitter<MarketplaceState> emit) async {
    debugPrint('[${DateTime.now()}] MarketplaceBloc: Clearing error state');
    emit(MarketplaceInitial());
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure _:
        return failure.message;
      case CacheFailure _:
        return failure.message;
      case NetworkFailure _:
        return failure.message;
      default:
        return 'Unexpected error occurred. Please try again.';
    }
  }
}