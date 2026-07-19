import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../models/device_state.dart';
import '../services/demon_service.dart';
import '../theme/app_theme.dart';
import '../widgets/panel.dart';

class LedColorScreen extends StatelessWidget {
  const LedColorScreen({super.key, required this.service, required this.deviceState});

  final DemonService service;
  final DeviceState deviceState;

  static const _chainLabels = {
    LedChain.right: 'Right',
    LedChain.left: 'Left',
    LedChain.auxRight: 'Aux Right',
    LedChain.auxLeft: 'Aux Left',
    LedChain.tail: 'Tail',
  };

  @override
  Widget build(BuildContext context) {
    final allEnabled = deviceState.ledChainMask == LedChain.allMask;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: IgnorePointer(
        ignoring: !deviceState.connected,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: deviceState.connected ? 1 : 0.4,
          child: Column(
            children: [
              Panel(
                child: _ChainControl(
                  label: 'All Chains',
                  color: deviceState.colorFor(LedChain.right),
                  enabled: allEnabled,
                  onColorChanged: (color) => service.setLedColor(color),
                  onEnabledChanged: (enabled) async {
                    for (final chain in LedChain.values) {
                      await service.setLedChainEnabled(chain, enabled);
                    }
                  },
                ),
              ),
              const SizedBox(height: 20),
              for (final entry in _chainLabels.entries) ...[
                Panel(
                  child: _ChainControl(
                    label: entry.value,
                    color: deviceState.colorFor(entry.key),
                    enabled: deviceState.isChainEnabled(entry.key),
                    onColorChanged: (color) => service.setLedColor(color, chain: entry.key),
                    onEnabledChanged: (enabled) => service.setLedChainEnabled(entry.key, enabled),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// One chain's controls: color swatch (opens a picker) and an on/off toggle.
/// Also used for the "All Chains" master control.
class _ChainControl extends StatelessWidget {
  const _ChainControl({
    required this.label,
    required this.color,
    required this.enabled,
    required this.onColorChanged,
    required this.onEnabledChanged,
  });

  final String label;
  final Color color;
  final bool enabled;
  final ValueChanged<Color> onColorChanged;
  final ValueChanged<bool> onEnabledChanged;

  Future<void> _pickColor(BuildContext context) async {
    Color picked = color;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceRaised,
        title: Text(label, style: AppTheme.mono(size: 14, color: AppColors.textPrimary)),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: color,
            onColorChanged: (c) {
              picked = c;
              onColorChanged(c);
            },
            enableAlpha: false,
            labelTypes: const [],
            pickerAreaHeightPercent: 0.7,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              onColorChanged(picked);
              Navigator.of(context).pop();
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: PanelLabel(label)),
            _EnableToggle(enabled: enabled, onChanged: onEnabledChanged),
          ],
        ),
        const SizedBox(height: 14),
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _pickColor(context),
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: color,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 24,
                  spreadRadius: -6,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
              style: AppTheme.mono(
                size: 13,
                color: color.computeLuminance() > 0.4 ? Colors.black87 : Colors.white,
                weight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Small pill on/off toggle used next to a chain's label.
class _EnableToggle extends StatelessWidget {
  const _EnableToggle({required this.enabled, required this.onChanged});

  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => onChanged(!enabled),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
              enabled ? 'ON' : 'OFF',
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
