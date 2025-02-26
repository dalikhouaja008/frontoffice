// widgets/filter_bar.dart

import 'package:flutter/material.dart';
import 'package:the_boost/features/auth/data/models/land_model.dart';


class FilterBar extends StatelessWidget {
  final Function(LandType?) onTypeChanged;
  final Function(LandStatus?) onStatusChanged;
  final Function(String) onSearchChanged;
  final LandType? selectedType;
  final LandStatus? selectedStatus;

  const FilterBar({
    Key? key,
    required this.onTypeChanged,
    required this.onStatusChanged,
    required this.onSearchChanged,
    this.selectedType,
    this.selectedStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Rechercher un terrain...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: onSearchChanged,
          ),
        ),
        const SizedBox(width: 16),
        _buildTypeDropdown(),
        const SizedBox(width: 16),
        _buildStatusDropdown(),
      ],
    );
  }

  Widget _buildTypeDropdown() {
    return DropdownButton<LandType>(
      value: selectedType,
      hint: const Text('Type'),
      items: LandType.values.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text(_getLandTypeLabel(type)),
        );
      }).toList()
        ..insert(
          0,
          const DropdownMenuItem(
            value: null,
            child: Text('Tous les types'),
          ),
        ),
      onChanged: onTypeChanged,
    );
  }

  Widget _buildStatusDropdown() {
    return DropdownButton<LandStatus>(
      value: selectedStatus,
      hint: const Text('Statut'),
      items: LandStatus.values.map((status) {
        return DropdownMenuItem(
          value: status,
          child: Text(_getLandStatusLabel(status)),
        );
      }).toList()
        ..insert(
          0,
          const DropdownMenuItem(
            value: null,
            child: Text('Tous les statuts'),
          ),
        ),
      onChanged: onStatusChanged,
    );
  }

  String _getLandTypeLabel(LandType type) {
    switch (type) {
      case LandType.AGRICULTURAL:
        return 'Agricole';
      case LandType.RESIDENTIAL:
        return 'Résidentiel';
      case LandType.INDUSTRIAL:
        return 'Industriel';
      case LandType.COMMERCIAL:
        return 'Commercial';
    }
  }

  String _getLandStatusLabel(LandStatus status) {
    switch (status) {
      case LandStatus.AVAILABLE:
        return 'Disponible';
      case LandStatus.PENDING:
        return 'En attente';
      case LandStatus.SOLD:
        return 'Vendu';
    }
  }
}