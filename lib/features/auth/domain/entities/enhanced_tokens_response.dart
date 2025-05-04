import 'package:equatable/equatable.dart';
import 'investment_stats.dart';
import 'token.dart';

class EnhancedTokensResponse extends Equatable {
  final EnhancedTokensData data;
  final DateTime timestamp;

  const EnhancedTokensResponse({
    required this.data,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [data, timestamp];
}

class EnhancedTokensData extends Equatable {
  final List<Token> tokens;
  final InvestmentStats stats;

  const EnhancedTokensData({
    required this.tokens,
    required this.stats,
  });

  @override
  List<Object?> get props => [tokens, stats];
}