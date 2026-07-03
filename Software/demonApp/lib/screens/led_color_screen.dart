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
        ],
      ),
    );
  }

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
