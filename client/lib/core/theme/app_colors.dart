import 'package:flutter/material.dart';

/// PaperSafe v2.0 – Centralized color palette
class AppColors {
  // Brand gradient pair
  static const Color brandStart = Color(0xFF6C3DE3);  // Deep violet
  static const Color brandEnd   = Color(0xFF3D7BE3);  // Royal blue

  // Surface / background
  static const Color bgDark     = Color(0xFF0D0D1A);
  static const Color bgDark2    = Color(0xFF12122A);
  static const Color surface    = Color(0xFF1A1A35);
  static const Color surfaceCard= Color(0xFF22224A);

  // Text
  static const Color textPrimary   = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0D0);
  static const Color textHint      = Color(0xFF6060A0);

  // Accent
  static const Color accent        = Color(0xFF7C5CFC);
  static const Color accentLight   = Color(0xFFAE90FF);
  static const Color success       = Color(0xFF4CAF82);
  static const Color warning       = Color(0xFFFFBE55);
  static const Color error         = Color(0xFFFF5C7A);

  // Glass effect
  static const Color glassFill     = Color(0x1AFFFFFF);
  static const Color glassBorder   = Color(0x33FFFFFF);

  // Light theme
  static const Color bgLight       = Color(0xFFF5F4FF);
  static const Color surfaceLight  = Color(0xFFFFFFFF);
  static const Color textLight     = Color(0xFF1A1A35);
  static const Color textLightSec  = Color(0xFF5A5A8A);

  // Category colors
  static const Color catIdentity   = Color(0xFF6C3DE3);
  static const Color catEducation  = Color(0xFF3D9BE9);
  static const Color catTravel     = Color(0xFF2ECC8F);
  static const Color catFinance    = Color(0xFFFFBE55);
  static const Color catOther      = Color(0xFFFF7E67);

  // Gradients
  static const LinearGradient brandGradient = LinearGradient(
    colors: [brandStart, brandEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkBgGradient = LinearGradient(
    colors: [bgDark, bgDark2],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
