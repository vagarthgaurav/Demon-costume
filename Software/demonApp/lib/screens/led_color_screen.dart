import 'package:flutter/material.dart';

import '../models/device_state.dart';
import '../services/demon_service.dart';
import '../theme/app_theme.dart';
import '../widgets/panel.dart';

class LedColorScreen extends StatelessWidget {
  const LedColorScreen({super.key, required this.service, required this.deviceState});

  final DemonService service;
  final DeviceState deviceState;

  @override
  Widget build(BuildContext context) {
    final color = deviceState.ledColor;
    final hex = '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            height: 88,
            decoration: BoxDecoration(
              color: color,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.45),
                  blurRadius: 32,
                  spreadRadius: -4,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              hex,
              style: AppTheme.mono(
                size: 13,
                color: color.computeLuminance() > 0.4 ? Colors.black87 : Colors.white,
                weight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Panel(
            child: Column(
              children: [
                const PanelLabel('Color'),
                const SizedBox(height: 12),
                _channelSlider(
                  label: 'R',
                  value: color.r * 255,
                  onChanged: (v) => service.setLedColor(color.withValues(red: v / 255)),
                ),
                _channelSlider(
                  label: 'G',
                  value: color.g * 255,
                  onChanged: (v) => service.setLedColor(color.withValues(green: v / 255)),
                ),
                _channelSlider(
                  label: 'B',
                  value: color.b * 255,
                  onChanged: (v) => service.setLedColor(color.withValues(blue: v / 255)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PanelLabel('Chains'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final entry in _chainLabels.entries)
                      _ChainToggle(
                        label: entry.value,
                        enabled: deviceState.isChainEnabled(entry.key),
                        onChanged: (enabled) => service.setLedChainEnabled(entry.key, enabled),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static const _chainLabels = {
    LedChain.right: 'Right',
    LedChain.left: 'Left',
    LedChain.auxRight: 'Aux Right',
    LedChain.auxLeft: 'Aux Left',
    LedChain.tail: 'Tail',
  };

  Widget _channelSlider({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Row(
      children: [
        SizedBox(width: 20, child: Text(label, style: AppTheme.mono(size: 13))),
        Expanded(
          child: Slider(
            value: value.clamp(0, 255),
            min: 0,
            max: 255,
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 36,
          child: Text(
            value.round().toString().padLeft(3, '0'),
            style: AppTheme.mono(size: 13, color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}

/// Pill-shaped on/off toggle for a single LED chain.
class _ChainToggle extends StatelessWidget {
  const _ChainToggle({required this.label, required this.enabled, required this.onChanged});

  final String label;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => onChanged(!enabled),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: enabled ? AppColors.accentGradient : null,
          color: enabled ? null : AppColors.surface,
          border: Border.all(color: enabled ? Colors.transparent : AppColors.border),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              enabled ? Icons.toggle_on : Icons.toggle_off_outlined,
              size: 18,
              color: enabled ? Colors.black87 : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label.toUpperCase(),
              style: AppTheme.mono(
                size: 12,
                weight: FontWeight.w600,
                color: enabled ? Colors.black87 : AppColors.textSecondary,
              ).copyWith(letterSpacing: 0.6),
            ),
          ],
        ),
      ),
    );
  }
}
