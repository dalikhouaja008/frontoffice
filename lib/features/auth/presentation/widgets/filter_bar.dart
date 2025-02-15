import 'package:flutter/material.dart';
import 'package:the_boost/features/auth/presentation/models/land_model.dart';
import '../models/land_model.dart';

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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Rechercher un terrain...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTypeDropdown(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatusDropdown(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeDropdown() {
    return DropdownButtonFormField<LandType>(
      value: selectedType,
      decoration: InputDecoration(
        labelText: 'Type de terrain',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      items: LandType.values.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text(
            type == LandType.AGRICULTURAL ? 'Agricole' : 'Urbain',
          ),
        );
      }).toList(),
      onChanged: onTypeChanged,
    );
  }

  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<LandStatus>(
      value: selectedStatus,
      decoration: InputDecoration(
        labelText: 'Statut',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      items: LandStatus.values.map((status) {
        return DropdownMenuItem(
          value: status,
          child: Text(
            switch (status) {
              LandStatus.PENDING => 'En attente',
              LandStatus.APPROVED => 'Approuvé',
              LandStatus.REJECTED => 'Rejeté',
            },
          ),
        );
      }).toList(),
      onChanged: onStatusChanged,
    );
  }
}