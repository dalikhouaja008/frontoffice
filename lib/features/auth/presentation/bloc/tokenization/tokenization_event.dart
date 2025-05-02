part of 'tokenization_bloc.dart';

abstract class TokenizationEvent {}

class LoadLandTokens extends TokenizationEvent {
  final int landId;
  
  LoadLandTokens({required this.landId});
}

class MintTokens extends TokenizationEvent {
  final int landId;
  final int quantity;
  final String value;
  
  MintTokens({required this.landId, required this.quantity, required this.value});
}

class LoadPlatformFeeInfo extends TokenizationEvent {}