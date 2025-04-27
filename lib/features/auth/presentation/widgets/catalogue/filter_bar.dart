// lib/features/auth/presentation/widgets/catalogue/filter_bar.dart
import 'package:flutter/material.dart';

class FilterBar extends StatelessWidget {
  final Function(String) onSearchChanged;

  const FilterBar({Key? key, required this.onSearchChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search lands...',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          prefixIcon: const Icon(Icons.search),
        ),
        onChanged: onSearchChanged,
      ),
    );
  }
}