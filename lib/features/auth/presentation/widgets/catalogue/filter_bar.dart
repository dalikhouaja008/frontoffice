// lib/features/auth/presentation/widgets/catalogue/filter_bar.dart
import 'package:flutter/material.dart';

class FilterBar extends StatelessWidget {
  final Function(String) onSearchChanged;

  const FilterBar({Key? key, required this.onSearchChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Rechercher un terrain...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onChanged: onSearchChanged,
          ),
        ),
      ],
    );
  }
}