import 'package:flutter/material.dart';

import '../theme/spotless_colors.dart';

/// Reusable section header with a bold title and an optional trailing action
/// (e.g. "See All"). Used consistently across Home, Library, Discovery, etc.
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EdgeInsetsGeometry padding;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.padding = const EdgeInsets.only(bottom: 12, left: 4, right: 4),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge,
          ),
          if (actionLabel != null && onAction != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                foregroundColor: SpotlessColors.onSurfaceMedium,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                textStyle: theme.textTheme.labelMedium,
              ),
              child: Text(actionLabel!),
            ),
        ],
      ),
    );
  }
}
