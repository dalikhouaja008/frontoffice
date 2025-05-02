import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_boost/core/di/dependency_injection.dart';
import 'package:the_boost/core/services/token_minting_service.dart';

part 'tokenization_event.dart';
part 'tokenization_state.dart';

class TokenizationBloc extends Bloc<TokenizationEvent, TokenizationState> {
  final TokenMintingService _tokenMintingService;

  TokenizationBloc()
      : _tokenMintingService = getIt<TokenMintingService>(),
        super(TokenizationInitial()) {
    on<LoadLandTokens>(_onLoadLandTokens);
    on<MintTokens>(_onMintTokens);
    on<LoadPlatformFeeInfo>(_onLoadPlatformFeeInfo);
  }

  Future<void> _onLoadLandTokens(
      LoadLandTokens event, Emitter<TokenizationState> emit) async {
    emit(TokenizationLoading());
    try {
      final response =
          await _tokenMintingService.getTokensForLand(event.landId);

      if (response['success'] == true) {
        // Stocker l'état actuel en cas d'erreur
        final currentState = state;
        
        emit(LandTokensLoaded(
          landId: event.landId,
          isTokenized: response['data']['isTokenized'] ?? false,
          totalTokens: response['data']['totalTokens'] ?? 0,
          availableTokens: response['data']['availableTokens'] ?? 0,
          pricePerToken: response['data']['pricePerToken'] ?? '0',
          tokenIds: List<int>.from(response['data']['tokenIds'] ?? []),
        ));
      } else {
        // Ne changez pas l'état si nous avons déjà des données
        if (state is! LandTokensLoaded) {
          emit(TokenizationError(
              message: response['message'] ?? 'Failed to load tokens'));
        }
      }
    } catch (e) {
      // Ne changez pas l'état si nous avons déjà des données
      if (state is! LandTokensLoaded) {
        emit(TokenizationError(message: 'Failed to load tokens: $e'));
      }
    }
  }

  Future<void> _onMintTokens(
      MintTokens event, Emitter<TokenizationState> emit) async {
    emit(TokenizationProcessing());
    try {
      final response = await _tokenMintingService.mintMultipleTokens(
        landId: event.landId,
        quantity: event.quantity,
        value: event.value,
      );

      if (response['success'] == true) {
        emit(TokensMinted(
          txHash: response['data']['txHash'] ?? '',
          tokenIds: List<int>.from(response['data']['tokenIds'] ?? []),
          landId: event.landId,
          availableTokens: response['data']['availableTokens'] ?? 0,
          totalTokens: response['data']['totalTokens'] ?? 0,
        ));

        // Load updated tokens after successful minting
        add(LoadLandTokens(landId: event.landId));
      } else {
        emit(TokenizationError(
            message: response['message'] ?? 'Failed to mint tokens'));
      }
    } catch (e) {
      emit(TokenizationError(message: 'Failed to mint tokens: $e'));
    }
  }

  Future<void> _onLoadPlatformFeeInfo(
      LoadPlatformFeeInfo event, Emitter<TokenizationState> emit) async {
    try {
      final response = await _tokenMintingService.getPlatformFeeInfo();

      if (response['success'] == true) {
        emit(PlatformFeeInfoLoaded(
          feePercentage: response['data']['feePercentage'] ?? 0,
          feeRecipient: response['data']['feeRecipient'] ?? '',
        ));
      } else {
        // Ne changez pas l'état principal si l'erreur est liée aux frais de plateforme
        // Cela évite de perdre l'état LandTokensLoaded
      }
    } catch (e) {
      // Ne changez pas l'état principal si l'erreur est liée aux frais de plateforme
      // Cela évite de perdre l'état LandTokensLoaded
    }
  }

}