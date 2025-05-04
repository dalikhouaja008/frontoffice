import '../../domain/entities/investment_stats.dart';

class InvestmentStatsModel extends InvestmentStats {
  InvestmentStatsModel({
    required int totalTokens,
    required String totalPurchaseValue,
    required String totalCurrentMarketValue,
    required String totalListedValue,
    required String totalProfit,
    required String totalProfitPercentage,
    required int countOwned,
    required int countListed,
  }) : super(
          totalTokens: totalTokens,
          totalPurchaseValue: totalPurchaseValue,
          totalCurrentMarketValue: totalCurrentMarketValue,
          totalListedValue: totalListedValue,
          totalProfit: totalProfit,
          totalProfitPercentage: totalProfitPercentage,
          countOwned: countOwned,
          countListed: countListed,
        );

  factory InvestmentStatsModel.fromJson(Map<String, dynamic> json) {
    return InvestmentStatsModel(
      totalTokens: json['totalTokens'],
      totalPurchaseValue: json['totalPurchaseValue'],
      totalCurrentMarketValue: json['totalCurrentMarketValue'],
      totalListedValue: json['totalListedValue'],
      totalProfit: json['totalProfit'],
      totalProfitPercentage: json['totalProfitPercentage'],
      countOwned: json['countOwned'],
      countListed: json['countListed'],
    );
  }
}