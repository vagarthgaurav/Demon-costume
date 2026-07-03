import 'package:flutter/material.dart';

import '../models/device_state.dart';
import '../theme/app_theme.dart';
import '../widgets/panel.dart';

class BatteryScreen extends StatelessWidget {
  const BatteryScreen({super.key, required this.deviceState});

  final DeviceState deviceState;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _BatteryPanel(
            label: 'Wings',
            volts: deviceState.wingsBatteryVolts,
            fraction: deviceState.wingsBatteryFraction,
            connected: deviceState.connected,
          ),
          const SizedBox(height: 20),
          _BatteryPanel(
            label: 'Remote',
            volts: deviceState.remoteBatteryVolts,
            fraction: deviceState.remoteBatteryFraction,
            connected: deviceState.connected,
          ),
        ],
      ),
    );
  }
}

class _BatteryPanel extends StatelessWidget {
  const _BatteryPanel({
    required this.label,
    required this.volts,
    required this.fraction,
    required this.connected,
  });

  final String label;
  final double volts;
  final double fraction;
  final bool connected;

  @override
  Widget build(BuildContext context) {
    final low = connected && fraction < 0.2;

    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PanelLabel(label),
          const SizedBox(height: 20),
          Text(
            connected ? '${volts.toStringAsFixed(2)}V' : '--.--V',
            style: AppTheme.mono(
              size: 36,
              weight: FontWeight.w600,
              color: low ? AppColors.warning : null,
            ),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Container(
                    height: 6,
                    width: constraints.maxWidth,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 6,
                    width: constraints.maxWidth * (connected ? fraction : 0),
                    decoration: BoxDecoration(
                      gradient: low ? null : AppColors.accentGradient,
                      color: low ? AppColors.warning : null,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 8),
          Text(
            connected ? '${(fraction * 100).round()}%' : 'DISCONNECTED',
            style: AppTheme.mono(size: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
