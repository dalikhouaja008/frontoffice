import '../../domain/entities/investment_stats.dart';

class InvestmentStatsModel extends InvestmentStats {
  InvestmentStatsModel({
    required super.totalTokens,
    required super.totalPurchaseValue,
    required super.totalCurrentMarketValue,
    required super.totalListedValue,
    required super.totalProfit,
    required super.totalProfitPercentage,
    required super.countOwned,
    required super.countListed,
  });

  factory InvestmentStatsModel.fromJson(Map<String, dynamic> json) {
    return InvestmentStatsModel(
      totalTokens: json['totalTokens'] ?? 0,
      totalPurchaseValue: json['totalPurchaseValue'] ?? '0',
      totalCurrentMarketValue: json['totalCurrentMarketValue'] ?? '0',
      totalListedValue: json['totalListedValue'] ?? '0',
      totalProfit: json['totalProfit'] ?? '0',
      totalProfitPercentage: json['totalProfitPercentage'] ?? '0',
      countOwned: json['countOwned'] ?? 0,
      countListed: json['countListed'] ?? 0,
    );
  }

  // Ajout de la méthode toJson manquante
  Map<String, dynamic> toJson() {
    return {
      'totalTokens': totalTokens,
      'totalPurchaseValue': totalPurchaseValue,
      'totalCurrentMarketValue': totalCurrentMarketValue,
      'totalListedValue': totalListedValue,
      'totalProfit': totalProfit,
      'totalProfitPercentage': totalProfitPercentage,
      'countOwned': countOwned,
      'countListed': countListed,
    };
  }
}