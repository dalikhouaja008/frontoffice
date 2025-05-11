import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/land_types.dart';
import '../utils/string_extensions.dart';

class BasicInfoStep extends StatelessWidget {
  final String title;
  final String description;
  final String? selectedLandType;
  final String surface;
  final Function(String) onTitleChanged;
  final Function(String) onDescriptionChanged;
  final Function(String?) onLandTypeChanged;
  final Function(String) onSurfaceChanged;
  final GlobalKey<FormState>? formKey;

  const BasicInfoStep({
    Key? key,
    required this.title,
    required this.description,
    required this.selectedLandType,
    required this.surface,
    required this.onTitleChanged,
    required this.onDescriptionChanged,
    required this.onLandTypeChanged,
    required this.onSurfaceChanged,
    this.formKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Basic Land Information',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          'Enter the basic details about your land property',
          style: TextStyle(color: Colors.grey[600], fontSize: 16),
        ),
        SizedBox(height: 32),

        // Title field
        TextFormField(
          initialValue: title,
          decoration: InputDecoration(
            labelText: 'Property Title',
            hintText: 'Enter a descriptive title for your property',
            prefixIcon: Icon(Icons.title, color: AppColors.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          onChanged: onTitleChanged,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a property title';
            }
            return null;
          },
        ),
        SizedBox(height: 24),

        // Description field
        TextFormField(
          initialValue: description,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Property Description (Optional)',
            hintText: 'Enter a detailed description of your property',
            prefixIcon: Icon(Icons.description, color: AppColors.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          onChanged: onDescriptionChanged,
        ),
        SizedBox(height: 24),

        // Land type dropdown
        DropdownButtonFormField<String>(
          value: selectedLandType,
          decoration: InputDecoration(
            labelText: 'Land Type',
            hintText: 'Select the type of land',
            prefixIcon: Icon(Icons.category, color: AppColors.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          items: LandTypes.types.map((String type) {
            return DropdownMenuItem<String>(
              value: type,
              child: Text(type.capitalize()),
            );
          }).toList(),
          onChanged: onLandTypeChanged,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a land type';
            }
            return null;
          },
        ),
        SizedBox(height: 24),

        // Surface area field
        TextFormField(
          initialValue: surface,
          decoration: InputDecoration(
            labelText: 'Surface Area (sq meters)',
            hintText: 'Enter the total surface area in square meters',
            prefixIcon: Icon(Icons.square_foot, color: AppColors.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          keyboardType: TextInputType.number,
          onChanged: onSurfaceChanged,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the surface area';
            }
            if (double.tryParse(value) == null || double.parse(value) <= 0) {
              return 'Please enter a valid surface area';
            }
            return null;
          },
        ),
      ],
    );
  }
}