class TokenProperty {
  final String id;
  final String name;
  final String location;
  final int totalTokens;
  final int ownedTokens;
  final double marketPrice;
  final String imageUrl;
  final String lastTraded;
  final String priceChange;

  TokenProperty({
    required this.id,
    required this.name,
    required this.location,
    required this.totalTokens,
    required this.ownedTokens,
    required this.marketPrice,
    required this.imageUrl,
    required this.lastTraded,
    required this.priceChange,
  });
}