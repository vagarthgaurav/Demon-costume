import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Icon-only battery readout for the app bar - no text.
///
/// [deviceIcon] differentiates which pack this is (wings vs remote); the
/// battery glyph itself fills in bars to reflect charge level, same as a
/// phone status bar.
class BatteryBadge extends StatelessWidget {
  const BatteryBadge({
    super.key,
    required this.tooltip,
    required this.deviceIcon,
    required this.percent,
    required this.connected,
  });

  final String tooltip;
  final IconData deviceIcon;
  final int percent;
  final bool connected;

  @override
  Widget build(BuildContext context) {
    final low = connected && percent < 20;
    final color = !connected
        ? AppColors.textSecondary
        : low
            ? AppColors.warning
            : AppColors.textPrimary;

    return Tooltip(
      message: connected ? '$tooltip battery: $percent%' : '$tooltip battery: disconnected',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(deviceIcon, size: 15, color: color),
          const SizedBox(width: 3),
          Icon(_batteryIcon(), size: 18, color: color),
        ],
      ),
    );
  }

  IconData _batteryIcon() {
    if (!connected) return Icons.battery_unknown_outlined;
    if (percent < 20) return Icons.battery_alert_outlined;
    if (percent < 30) return Icons.battery_1_bar_outlined;
    if (percent < 45) return Icons.battery_2_bar_outlined;
    if (percent < 60) return Icons.battery_3_bar_outlined;
    if (percent < 75) return Icons.battery_4_bar_outlined;
    if (percent < 90) return Icons.battery_5_bar_outlined;
    if (percent < 98) return Icons.battery_6_bar_outlined;
    return Icons.battery_full_outlined;
  }
}
