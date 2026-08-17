import 'package:flutter/material.dart';
import 'package:papersafe/core/theme/app_colors.dart';
import 'package:papersafe/core/theme/app_theme.dart';

/// Reusable card for a document type.
class DocumentCard extends StatelessWidget {
  final String title;
  final IconData iconData;
  final VoidCallback? onTap;

  const DocumentCard({
    super.key,
    required this.title,
    required this.iconData,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
        color: isDark ? AppColors.surfaceCard : Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(iconData, size: 48, color: AppColors.accent),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
