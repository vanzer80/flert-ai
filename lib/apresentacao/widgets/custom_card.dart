import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? elevation;
  final BorderRadiusGeometry? borderRadius;
  final Color? backgroundColor;

  const CustomCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.elevation,
    this.borderRadius,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.all(8.0),
      child: Card(
        elevation: elevation ?? 4,
        color: backgroundColor ?? AppColors.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(20),
        ),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16.0),
          child: child,
        ),
      ),
    );
  }
}

class SuggestionCard extends StatelessWidget {
  final String suggestion;
  final VoidCallback? onCopy;
  final VoidCallback? onEdit;

  const SuggestionCard({
    super.key,
    required this.suggestion,
    this.onCopy,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            suggestion,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: onCopy,
                icon: const Icon(
                  Icons.copy,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                tooltip: 'Copiar',
              ),
              IconButton(
                onPressed: onEdit,
                icon: const Icon(
                  Icons.edit,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                tooltip: 'Editar',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
