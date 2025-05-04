// lib/features/investment/domain/entities/enhanced_tokens_response.dart
import 'package:the_boost/features/auth/domain/entities/investment_stats.dart';
import 'package:the_boost/features/auth/domain/entities/token.dart';

class EnhancedTokensResponse {
  final bool success;
  final EnhancedTokensData data;
  final int count;
  final String message;
  final String timestamp;

  EnhancedTokensResponse({
    required this.success,
    required this.data,
    required this.count,
    required this.message,
    required this.timestamp,
  });
}

class EnhancedTokensData {
  final List<Token> tokens;
  final InvestmentStats stats;

  EnhancedTokensData({
    required this.tokens,
    required this.stats,
  });
}