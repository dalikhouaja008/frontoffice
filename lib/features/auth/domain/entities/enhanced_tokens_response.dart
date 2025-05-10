import 'package:equatable/equatable.dart';
import 'investment_stats.dart';
import 'token.dart';

class EnhancedTokensResponse extends Equatable {
  final bool success;
  final EnhancedTokensData data;
  final int count;
  final String message;
  final String timestamp;

  const EnhancedTokensResponse({
    required this.success,
    required this.data,
    required this.count,
    required this.message,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [success, data, count, message, timestamp];
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