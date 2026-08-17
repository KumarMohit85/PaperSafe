import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:papersafe/core/theme/app_colors.dart';

/// A reusable GlassMorphism container.
///
/// Provides a blurred background with optional gradient overlay.
/// Use it to wrap any child widget.
class GlassMorphism extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blurSigma;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final LinearGradient? gradient;
  final Color? color;

  const GlassMorphism({
    super.key,
    required this.child,
    this.borderRadius = 16.0,
    this.blurSigma = 10.0,
    this.padding = EdgeInsets.zero,
    this.margin = EdgeInsets.zero,
    this.gradient,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = color ??
        (isDark ? AppColors.glassFill : AppColors.glassFill.withOpacity(0.4));
    final overlayGradient = gradient ??
        LinearGradient(
          colors: [baseColor, baseColor.withOpacity(0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AppColors.glassBorder, width: 1),
        gradient: overlayGradient,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: child,
        ),
      ),
    );
  }
}
