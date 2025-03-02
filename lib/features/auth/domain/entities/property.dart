class Property {
  final String id;
  final String title;
  final String location;
  final String category;
  final double minInvestment;
  final double tokenPrice;
  final double totalValue;
  final double projectedReturn;
  final String riskLevel;
  final int availableTokens;
  final double fundingPercentage;
  final String imageUrl;
  final bool isFeatured;

  Property({
    required this.id,
    required this.title,
    required this.location,
    required this.category,
    required this.minInvestment,
    required this.tokenPrice,
    required this.totalValue,
    required this.projectedReturn,
    required this.riskLevel,
    required this.availableTokens,
    required this.fundingPercentage,
    required this.imageUrl,
    this.isFeatured = false,
  });
}