// lib/features/investment/presentation/bloc/investment_event.dart
part of 'investment_bloc.dart';

abstract class InvestmentEvent extends Equatable {
  const InvestmentEvent();

  @override
  List<Object> get props => [];
}

class LoadEnhancedTokens extends InvestmentEvent {}

class RefreshEnhancedTokens extends InvestmentEvent {}