import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class AppTextStyles {
  // Headings
  static TextStyle h1 = GoogleFonts.montserrat(
    fontSize: 42,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static TextStyle h2 = GoogleFonts.montserrat(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static TextStyle h3 = GoogleFonts.montserrat(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static TextStyle h4 = GoogleFonts.montserrat(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  // Body text
  static TextStyle body1 = const TextStyle(
    fontSize: 18,
    height: 1.6,
    color: AppColors.textSecondary,
  );
  
  static TextStyle body2 = const TextStyle(
    fontSize: 16,
    height: 1.5,
    color: AppColors.textSecondary,
  );
  
  static TextStyle body3 = const TextStyle(
    fontSize: 14,
    height: 1.5,
    color: AppColors.textSecondary,
  );
  
  // Button text
  static TextStyle buttonText = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.textLight,
  );
  
  // Caption text
  static TextStyle caption = const TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );
}