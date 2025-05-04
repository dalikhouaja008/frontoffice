import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:the_boost/core/error/failure.dart';
import 'package:the_boost/core/use_cases/usecase.dart';
import 'package:the_boost/features/auth/domain/entities/investment_stats.dart';
import 'package:the_boost/features/auth/domain/entities/token.dart';
import 'package:the_boost/features/auth/domain/use_cases/investments/get_enhanced_tokens_usecase.dart';

part 'investment_event.dart';
part 'investment_state.dart';

class InvestmentBloc extends Bloc<InvestmentEvent, InvestmentState> {
  final GetEnhancedTokensUseCase getEnhancedTokensUseCase;

  InvestmentBloc({
    required this.getEnhancedTokensUseCase,
  }) : super(InvestmentInitial()) {
    on<LoadEnhancedTokens>(_onLoadEnhancedTokens);
    on<RefreshEnhancedTokens>(_onRefreshEnhancedTokens);
  }

  Future<void> _onLoadEnhancedTokens(
    LoadEnhancedTokens event,
    Emitter<InvestmentState> emit,
  ) async {
    emit(InvestmentLoading());
    final result = await getEnhancedTokensUseCase(NoParams());
    result.fold(
      (failure) => emit(InvestmentError(message: _mapFailureToMessage(failure))),
      (data) => emit(InvestmentLoaded(
        tokens: data.data.tokens,
        stats: data.data.stats,
        timestamp: data.timestamp.toString(),
      )),
    );
  }

  Future<void> _onRefreshEnhancedTokens(
    RefreshEnhancedTokens event,
    Emitter<InvestmentState> emit,
  ) async {
    final currentState = state;
    if (currentState is InvestmentLoaded) {
      emit(InvestmentRefreshing(
        tokens: currentState.tokens,
        stats: currentState.stats,
        timestamp: currentState.timestamp,
      ));
    } else {
      emit(InvestmentLoading());
    }

    final result = await getEnhancedTokensUseCase(NoParams());
    result.fold(
      (failure) => emit(InvestmentError(message: _mapFailureToMessage(failure))),
      (data) => emit(InvestmentLoaded(
        tokens: data.data.tokens,
        stats: data.data.stats,
        timestamp: data.timestamp.toString(),
      )),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return (failure as ServerFailure).message ?? 'Erreur de serveur';
      case NetworkFailure:
        return 'Vérifiez votre connexion internet';
      default:
        return 'Erreur inattendue';
    }
  }
}