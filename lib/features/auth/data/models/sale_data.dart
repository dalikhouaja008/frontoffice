class SaleData {
  final int selectedTokenIndex;
  final int tokensToSell;
  final double pricePerToken;
  final bool isMarketPrice;
  final String selectedDuration;
  final bool termsAccepted;
  final String description;

  SaleData({
    required this.selectedTokenIndex,
    required this.tokensToSell,
    required this.pricePerToken,
    required this.isMarketPrice,
    required this.selectedDuration,
    required this.termsAccepted,
    required this.description,
  });

  double get totalAmount => tokensToSell * pricePerToken;

  double get platformFee => totalAmount * 0.02;
  
  double get gasFee => 2.5;
  
  double get finalAmount => totalAmount - platformFee - gasFee;

  SaleData copyWith({
    int? selectedTokenIndex,
    int? tokensToSell,
    double? pricePerToken,
    bool? isMarketPrice,
    String? selectedDuration,
    bool? termsAccepted,
    String? description,
  }) {
    return SaleData(
      selectedTokenIndex: selectedTokenIndex ?? this.selectedTokenIndex,
      tokensToSell: tokensToSell ?? this.tokensToSell,
      pricePerToken: pricePerToken ?? this.pricePerToken,
      isMarketPrice: isMarketPrice ?? this.isMarketPrice,
      selectedDuration: selectedDuration ?? this.selectedDuration,
      termsAccepted: termsAccepted ?? this.termsAccepted,
      description: description ?? this.description,
    );
  }
}