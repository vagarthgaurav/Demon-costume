import 'package:flutter/material.dart';

import '../models/device_state.dart';
import '../services/demon_service.dart';
import '../theme/app_theme.dart';
import '../widgets/panel.dart';

class WingSpeedScreen extends StatelessWidget {
  const WingSpeedScreen({super.key, required this.service, required this.deviceState});

  final DemonService service;
  final DeviceState deviceState;

  @override
  Widget build(BuildContext context) {
    final percent = deviceState.wingSpeedPercent;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PanelLabel('Wing speed'),
            const SizedBox(height: 20),
            ShaderMask(
              shaderCallback: (rect) => AppColors.accentGradient.createShader(rect),
              child: Text(
                '$percent%',
                style: AppTheme.mono(size: 44, weight: FontWeight.w600, color: Colors.white),
              ),
            ),
            const SizedBox(height: 12),
            Slider(
              value: percent.toDouble(),
              min: 0,
              max: 100,
              divisions: 20,
              label: '$percent%',
              onChanged: (v) => service.setWingSpeed(v.round()),
            ),
          ],
        ),
      ),
    );
  }
}
