class TransactionResponseModel {
  final String transactionHash;
  final int blockNumber;
  final int tokenId;
  final int landId;
  final String price;
  final String buyer;
  final String seller;
  final String timestamp;
  final String message;

  TransactionResponseModel({
    required this.transactionHash,
    required this.blockNumber,
    required this.tokenId,
    required this.landId,
    required this.price,
    required this.buyer,
    required this.seller,
    required this.timestamp,
    required this.message,
  });

  factory TransactionResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return TransactionResponseModel(
      transactionHash: data['transactionHash'],
      blockNumber: data['blockNumber'],
      tokenId: data['tokenId'],
      landId: data['landId'],
      price: data['price'],
      buyer: data['buyer'],
      seller: data['seller'],
      timestamp: data['timestamp'],
      message: json['message'] ?? 'Transaction réussie',
    );
  }
}