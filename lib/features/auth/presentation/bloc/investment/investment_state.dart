// lib/features/investment/presentation/bloc/investment_state.dart
part of 'investment_bloc.dart';

abstract class InvestmentState extends Equatable {
  const InvestmentState();
  
  @override
  List<Object> get props => [];
}

class InvestmentInitial extends InvestmentState {}

class InvestmentLoading extends InvestmentState {}

class InvestmentRefreshing extends InvestmentState {
  final List<Token> tokens;
  final InvestmentStats stats;
  final String timestamp;

  const InvestmentRefreshing({
    required this.tokens,
    required this.stats,
    required this.timestamp,
  });

  @override
  List<Object> get props => [tokens, stats, timestamp];
}

class InvestmentLoaded extends InvestmentState {
  final List<Token> tokens;
  final InvestmentStats stats;
  final String timestamp;

  const InvestmentLoaded({
    required this.tokens,
    required this.stats,
    required this.timestamp,
  });

  @override
  List<Object> get props => [tokens, stats, timestamp];
}

class InvestmentError extends InvestmentState {
  final String message;

  const InvestmentError({required this.message});

  @override
  List<Object> get props => [message];
}