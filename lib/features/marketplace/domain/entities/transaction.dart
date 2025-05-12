import 'package:equatable/equatable.dart';

class Transaction extends Equatable {
  final String transactionHash;
  final int blockNumber;
  final int tokenId;
  final int landId;
  final String price;
  final String buyer;
  final String seller;
  final String timestamp;
  final String message;

  const Transaction({
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

  @override
  List<Object?> get props => [
    transactionHash,
    blockNumber,
    tokenId,
    landId,
    price,
    buyer,
    seller,
    timestamp,
    message,
  ];
  
  // Helpers
  String get formattedPrice => '$price ETH';
  String get etherscanUrl => 'https://sepolia.etherscan.io/tx/$transactionHash';
  String get shortenedBuyer => _shortenAddress(buyer);
  String get shortenedSeller => _shortenAddress(seller);
  
  String _shortenAddress(String address) {
    if (address.length <= 12) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }
}