import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/dynamic_theme_provider.dart';
import '../theme/spotless_colors.dart';

/// A gradient top bar that fades from the dynamic album-art color to
/// transparent. Used at the top of screens (Home, Library) instead of a
/// traditional AppBar, giving a PixelPlayer-style immersive header.
class GradientTopBar extends StatelessWidget {
  final String? title;
  final TextStyle? titleStyle;
  final List<Widget> actions;
  final Widget? leading;
  final double height;

  const GradientTopBar({
    super.key,
    this.title,
    this.titleStyle,
    this.actions = const [],
    this.leading,
    this.height = 100,
  });

  @override
  Widget build(BuildContext context) {
    final dynamic_ = context.watch<DynamicThemeProvider>();
    final theme = Theme.of(context);

    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: SpotlessColors.headerGradient(dynamic_.dominant),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 20,
        right: 12,
        bottom: 8,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 12)],
          if (title != null)
            Expanded(
              child: Text(
                title!,
                style: titleStyle ?? theme.textTheme.headlineLarge,
              ),
            )
          else
            const Spacer(),
          ...actions,
        ],
      ),
    );
  }
}
