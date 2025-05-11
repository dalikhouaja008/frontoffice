import 'package:the_boost/features/auth/data/models/investment_stats_model.dart';
import 'package:the_boost/features/auth/data/models/token_model.dart';
import 'package:the_boost/features/auth/domain/entities/enhanced_tokens_response.dart';

class EnhancedTokensResponseModel extends EnhancedTokensResponse {
  EnhancedTokensResponseModel({
    required super.success,
    required EnhancedTokensDataModel super.data,
    required super.count,
    required super.message,
    String? timestamp,
  }) : super(
          timestamp: timestamp ?? DateTime.now().toIso8601String(),
        );

  factory EnhancedTokensResponseModel.fromJson(Map<String, dynamic> json) {
    return EnhancedTokensResponseModel(
      success: json['success'] ?? false,
      data: EnhancedTokensDataModel.fromJson(json['data'] ?? {}),
      count: json['count'] ?? 0,
      message: json['message'] ?? '',
      timestamp: json['timestamp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': (data as EnhancedTokensDataModel).toJson(),
      'count': count,
      'message': message,
      'timestamp': timestamp,
    };
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
      tokens: ((json['tokens'] ?? []) as List)
          .map((tokenJson) => TokenModel.fromJson(tokenJson))
          .toList(),
      stats: InvestmentStatsModel.fromJson(json['stats'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tokens': (tokens as List<TokenModel>)
          .map((token) => (token).toJson())
          .toList(),
      'stats': (stats as InvestmentStatsModel).toJson(),
    };
  }
}