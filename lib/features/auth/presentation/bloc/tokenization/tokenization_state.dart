
part of 'tokenization_bloc.dart';

abstract class TokenizationState {}

class TokenizationInitial extends TokenizationState {}

class TokenizationLoading extends TokenizationState {}

class TokenizationProcessing extends TokenizationState {}

class LandTokensLoaded extends TokenizationState {
  final int landId;
  final bool isTokenized;
  final int totalTokens;
  final int availableTokens;
  final String pricePerToken;
  final List<int> tokenIds;
  
  LandTokensLoaded({
    required this.landId,
    required this.isTokenized,
    required this.totalTokens,
    required this.availableTokens,
    required this.pricePerToken,
    required this.tokenIds,
  });
}

class TokensMinted extends TokenizationState {
  final String txHash;
  final List<int> tokenIds;
  final int landId;
  final int availableTokens;
  final int totalTokens;
  
  TokensMinted({
    required this.txHash,
    required this.tokenIds,
    required this.landId,
    required this.availableTokens,
    required this.totalTokens,
  });
}

class PlatformFeeInfoLoaded extends TokenizationState {
  final double feePercentage;
  final String feeRecipient;
  
  PlatformFeeInfoLoaded({
    required this.feePercentage,
    required this.feeRecipient,
  });
}

class TokenizationError extends TokenizationState {
  final String message;
  
  TokenizationError({required this.message});
}
