import 'package:the_boost/features/auth/data/models/investment_stats_model.dart';
import 'package:the_boost/features/auth/data/models/token_model.dart';
import 'package:the_boost/features/auth/domain/entities/enhanced_tokens_response.dart';

class EnhancedTokensResponseModel extends EnhancedTokensResponse {
  EnhancedTokensResponseModel({
    required EnhancedTokensDataModel data,
    required DateTime timestamp,
  }) : super(
          data: data,
          timestamp: timestamp,
        );

  factory EnhancedTokensResponseModel.fromJson(Map<String, dynamic> json) {
    return EnhancedTokensResponseModel(
      data: EnhancedTokensDataModel.fromJson(json['data']),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class EnhancedTokensDataModel extends EnhancedTokensData {
  EnhancedTokensDataModel({
    required List<TokenModel> tokens,
    required InvestmentStatsModel stats,
  }) : super(
          tokens: tokens,
          stats: stats,
        );

  factory EnhancedTokensDataModel.fromJson(Map<String, dynamic> json) {
    return EnhancedTokensDataModel(
      tokens: (json['tokens'] as List)
          .map((tokenJson) => TokenModel.fromJson(tokenJson))
          .toList(),
      stats: InvestmentStatsModel.fromJson(json['stats']),
    );
  }
}