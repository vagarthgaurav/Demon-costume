import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Primary action button, filled with the brand gradient. Reserved for the
/// one thing that matters most on screen (connecting to the board) so it
/// doesn't compete with itself if overused.
class GradientButton extends StatelessWidget {
  const GradientButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Ink(
        decoration: const BoxDecoration(gradient: AppColors.accentGradient),
        child: InkWell(
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            child: Text(
              label,
              style: AppTheme.mono(
                size: 12,
                weight: FontWeight.w700,
                color: Colors.white,
              ).copyWith(letterSpacing: 1.0),
            ),
          ),
        ),
      ),
    );
  }
}
