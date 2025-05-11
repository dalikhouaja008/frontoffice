// lib/features/investment/domain/entities/investment_stats.dart
class InvestmentStats {
  final int totalTokens;
  final String totalPurchaseValue;
  final String totalCurrentMarketValue;
  final String totalListedValue;
  final String totalProfit;
  final String totalProfitPercentage;
  final int countOwned;
  final int countListed;

  InvestmentStats({
    required this.totalTokens,
    required this.totalPurchaseValue,
    required this.totalCurrentMarketValue,
    required this.totalListedValue,
    required this.totalProfit,
    required this.totalProfitPercentage,
    required this.countOwned,
    required this.countListed,
  });
}