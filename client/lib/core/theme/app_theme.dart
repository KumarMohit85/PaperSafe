import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static const _borderRadius = 16.0;

  // ─── DARK THEME ────────────────────────────────────────────────────────────
  static ThemeData get dark {
    final colorScheme = ColorScheme.dark(
      primary:          AppColors.accent,
      onPrimary:        Colors.white,
      primaryContainer: AppColors.surfaceCard,
      secondary:        AppColors.accentLight,
      onSecondary:      Colors.white,
      surface:          AppColors.surface,
      onSurface:        AppColors.textPrimary,
      error:            AppColors.error,
      onError:          Colors.white,
      outline:          AppColors.glassBorder,
      surfaceTint:      AppColors.accent.withOpacity(0.05),
    );

    return _buildTheme(colorScheme, Brightness.dark);
  }

  // ─── LIGHT THEME ────────────────────────────────────────────────────────────
  static ThemeData get light {
    final colorScheme = ColorScheme.light(
      primary:          AppColors.brandStart,
      onPrimary:        Colors.white,
      primaryContainer: AppColors.bgLight,
      secondary:        AppColors.brandEnd,
      onSecondary:      Colors.white,
      surface:          AppColors.surfaceLight,
      onSurface:        AppColors.textLight,
      error:            AppColors.error,
      onError:          Colors.white,
      outline:          Colors.grey.shade300,
    );

    return _buildTheme(colorScheme, Brightness.light);
  }

  static ThemeData _buildTheme(ColorScheme cs, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final textTheme = GoogleFonts.interTextTheme().copyWith(
      displayLarge:  GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w700, color: cs.onSurface),
      displayMedium: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w700, color: cs.onSurface),
      displaySmall:  GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w600, color: cs.onSurface),
      headlineLarge: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: cs.onSurface),
      headlineMedium:GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: cs.onSurface),
      headlineSmall: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface),
      titleLarge:    GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface),
      titleMedium:   GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: cs.onSurface),
      titleSmall:    GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: cs.onSurface),
      bodyLarge:     GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, color: cs.onSurface),
      bodyMedium:    GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: cs.onSurface),
      bodySmall:     GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: cs.onSurface.withOpacity(0.7)),
      labelLarge:    GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.5),
      labelMedium:   GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.4),
      labelSmall:    GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w400, letterSpacing: 0.3),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      brightness: brightness,
      textTheme: textTheme,
      scaffoldBackgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: cs.onSurface),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: cs.onSurface,
        ),
      ),

      // Cards
      cardTheme: CardThemeData(
        color: isDark ? AppColors.surfaceCard : Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
          side: BorderSide(
            color: isDark ? AppColors.glassBorder : Colors.grey.shade200,
            width: 1,
          ),
        ),
        margin: EdgeInsets.zero,
      ),

      // Input / TextField
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.surfaceCard : Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
          borderSide: BorderSide(
            color: isDark ? AppColors.glassBorder : Colors.grey.shade200,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
          borderSide: BorderSide(color: AppColors.accent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
          borderSide: BorderSide(color: AppColors.error),
        ),
        hintStyle: GoogleFonts.inter(
          color: isDark ? AppColors.textHint : Colors.grey.shade400,
          fontSize: 14,
        ),
        labelStyle: GoogleFonts.inter(
          color: isDark ? AppColors.textSecondary : Colors.grey.shade600,
          fontSize: 14,
        ),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_borderRadius),
          ),
          elevation: 0,
          textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accent,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),

      // Bottom Navigation Bar
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? AppColors.surface : Colors.white,
        indicatorColor: AppColors.accent.withOpacity(0.2),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: AppColors.accent, size: 24);
          }
          return IconThemeData(
            color: isDark ? AppColors.textHint : Colors.grey.shade400,
            size: 22,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return GoogleFonts.inter(
            fontSize: 11,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w400,
            color: states.contains(WidgetState.selected)
                ? AppColors.accent
                : (isDark ? AppColors.textHint : Colors.grey.shade400),
          );
        }),
        elevation: 0,
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: isDark ? AppColors.surfaceCard : Colors.grey.shade100,
        selectedColor: AppColors.accent.withOpacity(0.2),
        labelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        side: BorderSide.none,
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? AppColors.surfaceCard : Colors.grey.shade900,
        contentTextStyle: GoogleFonts.inter(fontSize: 14, color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),

      // Bottom Sheet
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isDark ? AppColors.surface : Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        elevation: 0,
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: isDark ? AppColors.surfaceCard : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
      ),

      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: isDark ? AppColors.glassBorder : Colors.grey.shade200,
        thickness: 1,
        space: 1,
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? AppColors.accent
              : Colors.grey;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? AppColors.accent.withOpacity(0.3)
              : Colors.grey.withOpacity(0.3);
        }),
      ),
    );
  }
}
