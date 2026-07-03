import 'package:flutter/material.dart';

import '../models/device_state.dart';
import '../services/demon_service.dart';
import '../theme/app_theme.dart';
import '../widgets/battery_badge.dart';
import '../widgets/status_dot.dart';
import 'battery_screen.dart';
import 'led_color_screen.dart';
import 'wing_speed_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.service});

  final DemonService service;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _tabs = ['LED', 'Battery', 'Wings'];

  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DeviceState>(
      stream: widget.service.state,
      initialData: DeviceState.disconnected(),
      builder: (context, snapshot) {
        final deviceState = snapshot.data ?? DeviceState.disconnected();
        return Scaffold(
          appBar: AppBar(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('DEMON BOARD'),
                const SizedBox(width: 10),
                StatusDot(connected: deviceState.connected),
              ],
            ),
            actions: [
              BatteryBadge(
                tooltip: 'Wings',
                deviceIcon: Icons.flight_outlined,
                percent: deviceState.wingsBatteryPercent,
                connected: deviceState.connected,
              ),
              const SizedBox(width: 14),
              BatteryBadge(
                tooltip: 'Remote',
                deviceIcon: Icons.settings_remote_outlined,
                percent: deviceState.remoteBatteryPercent,
                connected: deviceState.connected,
              ),
              const SizedBox(width: 20),
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: TextButton(
                  onPressed: deviceState.connected
                      ? widget.service.disconnect
                      : widget.service.connect,
                  child: Text(deviceState.connected ? 'DISCONNECT' : 'CONNECT'),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              _TabStrip(
                labels: _tabs,
                selectedIndex: _tabIndex,
                onSelected: (i) => setState(() => _tabIndex = i),
              ),
              Expanded(
                child: IndexedStack(
                  index: _tabIndex,
                  children: [
                    LedColorScreen(service: widget.service, deviceState: deviceState),
                    BatteryScreen(deviceState: deviceState),
                    WingSpeedScreen(service: widget.service, deviceState: deviceState),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Hairline-underlined tab strip - reads as an instrument selector, not a
/// rounded Material bottom nav.
class _TabStrip extends StatelessWidget {
  const _TabStrip({
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: InkWell(
                onTap: () => onSelected(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: i == selectedIndex ? AppColors.accent : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      labels[i].toUpperCase(),
                      style: AppTheme.mono(
                        size: 12,
                        color: i == selectedIndex
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                        weight: FontWeight.w600,
                      ).copyWith(letterSpacing: 1.2),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
