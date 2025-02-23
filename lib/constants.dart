import 'package:flutter/material.dart';

// Palette de couleurs
const kPrimaryColor = Color(0xFF6C63FF);  // Violet moderne
const kSecondaryColor = Color(0xFF2A2D3E); // Bleu foncé
const kBackgroundColor = Color(0xFFF5F5F5); // Gris très clair
const kTextColor = Color(0xFF2C384A);
const kTextLightColor = Color(0xFF6C7293);
const kAccentColor = Color(0xFF00B4D8); // Bleu vif

const double kDefaultPadding = 20.0;

final kDefaultShadow = BoxShadow(
  offset: const Offset(0, 4),
  blurRadius: 15,
  color: const Color(0xFF000000).withOpacity(0.1),
);

final kHoverShadow = BoxShadow(
  offset: const Offset(0, 6),
  blurRadius: 20,
  color: const Color(0xFF000000).withOpacity(0.15),
);