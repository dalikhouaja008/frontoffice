// lib/features/auth/presentation/widgets/currency_toggle.dart
import 'package:flutter/material.dart';

class CurrencyToggle extends StatelessWidget {
  final String selectedCurrency;
  final Function(String) onCurrencyChanged;
  final List<String> availableCurrencies;

  const CurrencyToggle({
    Key? key,
    required this.selectedCurrency,
    required this.onCurrencyChanged,
    this.availableCurrencies = const ['ETH', 'TND', 'USD'],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: availableCurrencies.map((currency) {
          final isSelected = currency == selectedCurrency;
          return GestureDetector(
            onTap: () => onCurrencyChanged(currency),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                currency,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
     ),
   );
 }
}