import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Real connection-state indicator - the one dot this app is allowed to have.
class StatusDot extends StatelessWidget {
  const StatusDot({super.key, required this.connected});

  final bool connected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: connected ? AppColors.good : AppColors.textSecondary,
      ),
    );
  }
}
