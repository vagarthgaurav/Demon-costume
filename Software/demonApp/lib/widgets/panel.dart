import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A bordered instrument panel. No elevation, no shadow, no rounded-card
/// look - a hairline border communicates grouping instead.
class Panel extends StatelessWidget {
  const Panel({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(2),
      ),
      child: child,
    );
  }
}

/// Small uppercase mono label for a panel/section - used sparingly.
class PanelLabel extends StatelessWidget {
  const PanelLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: AppTheme.mono(size: 11, color: AppColors.textSecondary).copyWith(
        letterSpacing: 1.4,
      ),
    );
  }
}
