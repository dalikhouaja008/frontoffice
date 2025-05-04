import '../../domain/entities/enhanced_tokens_response.dart';
import 'token_model.dart';
import 'investment_stats_model.dart';

class EnhancedTokensResponseModel extends EnhancedTokensResponse {
  EnhancedTokensResponseModel({
    required bool success,
    required EnhancedTokensDataModel data,
    required int count,
    required String message,
    required String timestamp,
  }) : super(
          success: success,
          data: data,
          count: count,
          message: message,
          timestamp: timestamp,
        );

  factory EnhancedTokensResponseModel.fromJson(Map<String, dynamic> json) {
    return EnhancedTokensResponseModel(
      success: json['success'],
      data: EnhancedTokensDataModel.fromJson(json['data']),
      count: json['count'],
      message: json['message'],
      timestamp: json['timestamp'],
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