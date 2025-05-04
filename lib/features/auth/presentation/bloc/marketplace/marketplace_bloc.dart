import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_boost/features/auth/domain/use_cases/marketplace/cancel_listing_usecase.dart';
import 'package:the_boost/features/auth/domain/use_cases/marketplace/list_multiple_tokens_usecase.dart';
import 'package:the_boost/features/auth/domain/use_cases/marketplace/list_token_usecase.dart';

import 'marketplace_event.dart';
import 'marketplace_state.dart';

class MarketplaceBloc extends Bloc<MarketplaceEvent, MarketplaceState> {
  final ListTokenUseCase listTokenUseCase;
  final ListMultipleTokensUseCase listMultipleTokensUseCase;
  final CancelListingUseCase cancelListingUseCase;

  MarketplaceBloc({
    required this.listTokenUseCase,
    required this.listMultipleTokensUseCase,
    required this.cancelListingUseCase,
  }) : super(MarketplaceInitial()) {
    on<ListTokenEvent>(_onListToken);
    on<ListMultipleTokensEvent>(_onListMultipleTokens);
    on<CancelListingEvent>(_onCancelListing);
  }

Future<void> _onListToken(
    ListTokenEvent event, Emitter<MarketplaceState> emit) async {
  emit(MarketplaceLoading());
  final result = await listTokenUseCase(event.tokenId, event.price);
  
  emit(result.fold(
    (failure) {
      // Analysons le message d'erreur pour fournir un message plus convivial
      final errorMessage = failure.message!.toLowerCase();
      
      if (errorMessage.contains('execution reverted') || 
          errorMessage.contains('estimategas')) {
        // Erreur liée aux gas fees
        return const MarketplaceError('Insufficient funds to pay for network fees. Please add more ETH to your wallet.');
      } else if (errorMessage.contains('unauthori') || 
                 errorMessage.contains('not owner')) {
        // Erreur d'autorisation
        return const MarketplaceError('You are not authorized to sell this token. Only the owner can list it for sale.');
      } else if (errorMessage.contains('already listed')) {
        // Token déjà listé
        return const MarketplaceError('This token is already listed for sale.');
      } else if (errorMessage.contains('connect')) {
        // Erreur de connexion
        return const MarketplaceError('Cannot connect to the blockchain network. Please check your internet connection and try again.');
      } else {
        // Erreur générique
        return MarketplaceError('An error occurred: ${failure.message}');
      }
    },
    (response) => TokenListingSuccess(response),
  ));
}

Future<void> _onListMultipleTokens(
    ListMultipleTokensEvent event, Emitter<MarketplaceState> emit) async {
  emit(MarketplaceLoading());
  
  // Date actuelle pour le logging
  final currentDateTime = '2025-05-04 21:03:55';
  print('[$currentDateTime] - Tentative de liste multiple de ${event.tokenIds.length} tokens');
  
  // Vérification des données d'entrée
  if (event.tokenIds.isEmpty || event.prices.isEmpty) {
    emit(MarketplaceError('No tokens or prices provided'));
    return;
  }
  
  if (event.tokenIds.length != event.prices.length) {
    emit(MarketplaceError('The number of tokens and prices must match'));
    return;
  }
  
  final result = await listMultipleTokensUseCase(event.tokenIds, event.prices);
  
  emit(result.fold(
    (failure) {
      // Analysons le message d'erreur pour fournir un message plus convivial
      final errorMessage = failure.message!.toLowerCase();
      
      if (errorMessage.contains('execution reverted') || 
          errorMessage.contains('estimategas')) {
        return const MarketplaceError('Insufficient funds to pay for network fees. Please add more ETH to your wallet.');
      } else if (errorMessage.contains('unauthori') || 
                 errorMessage.contains('not owner')) {
        return const MarketplaceError('You are not authorized to sell these tokens. Only the owner can list them for sale.');
      } else if (errorMessage.contains('already listed')) {
        return const MarketplaceError('One or more tokens are already listed for sale.');
      } else if (errorMessage.contains('connect')) {
        return const MarketplaceError('Cannot connect to the blockchain network. Please check your internet connection and try again.');
      } else if (errorMessage.contains('exceed') || errorMessage.contains('limit')) {
        return const MarketplaceError('Transaction exceeds gas limit. Try selling fewer tokens at once.');
      } else {
        // Add detailed debugging info in logs but simplified message for user
        print('[$currentDateTime] Error details: ${failure.message}');
        return const MarketplaceError('An error occurred while listing multiple tokens. Please try again with fewer tokens or contact support.');
      }
    },
    (response) => MultipleTokensListingSuccess(response),
  ));
}

  Future<void> _onCancelListing(
      CancelListingEvent event, Emitter<MarketplaceState> emit) async {
    emit(MarketplaceLoading());
    final result = await cancelListingUseCase(event.tokenId);
    emit(result.fold(
      (failure) => MarketplaceError(failure.message!),
      (response) => CancelListingSuccess(response),
    ));
  }
}