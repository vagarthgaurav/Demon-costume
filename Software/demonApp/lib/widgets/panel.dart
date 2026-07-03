import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A bordered instrument panel. Soft corners, a faint top-to-bottom lift in
/// tone, and a low black shadow give it just enough depth to read as a
/// physical surface without turning into a generic elevated Material card.
class Panel extends StatelessWidget {
  const Panel({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.surfaceRaised, AppColors.surface],
        ),
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
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
