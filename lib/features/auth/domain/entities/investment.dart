import 'property.dart';

class Investment {
  final String id;
  final String userId;
  final Property property;
  final int tokensPurchased;
  final double investmentAmount;
  final DateTime purchaseDate;
  final double currentValue;

  Investment({
    required this.id,
    required this.userId,
    required this.property,
    required this.tokensPurchased,
    required this.investmentAmount,
    required this.purchaseDate,
    required this.currentValue,
  });

  double get returnPercentage => 
      (currentValue - investmentAmount) / investmentAmount * 100;
}