import 'package:flutter/material.dart';

/// Snapshot of everything the app knows about a connected demon board.
///
/// There are two independent battery packs in this system: the wings board
/// itself (2S LiPo) and the handheld remote (3S LiPo). Their voltage ranges
/// differ, so percentage is computed per-pack.
class DeviceState {
  const DeviceState({
    required this.connected,
    required this.ledColor,
    required this.wingsBatteryMillivolts,
    required this.remoteBatteryMillivolts,
    required this.wingSpeedPercent,
  });

  factory DeviceState.disconnected() => const DeviceState(
        connected: false,
        ledColor: Colors.red,
        wingsBatteryMillivolts: 0,
        remoteBatteryMillivolts: 0,
        wingSpeedPercent: 50,
      );

  // 2S LiPo: ~6.0V empty, ~8.4V full.
  static const _wingsMinMv = 6000;
  static const _wingsMaxMv = 8400;

  // 3S LiPo: ~10.8V empty, ~12.6V full (matches demonRemote/bat_indicator.cpp).
  static const _remoteMinMv = 10800;
  static const _remoteMaxMv = 12600;

  final bool connected;
  final Color ledColor;
  final int wingsBatteryMillivolts;
  final int remoteBatteryMillivolts;
  final int wingSpeedPercent;

  double get wingsBatteryVolts => wingsBatteryMillivolts / 1000.0;
  double get remoteBatteryVolts => remoteBatteryMillivolts / 1000.0;

  double get wingsBatteryFraction =>
      _fraction(wingsBatteryMillivolts, _wingsMinMv, _wingsMaxMv);
  double get remoteBatteryFraction =>
      _fraction(remoteBatteryMillivolts, _remoteMinMv, _remoteMaxMv);

  int get wingsBatteryPercent => (wingsBatteryFraction * 100).round();
  int get remoteBatteryPercent => (remoteBatteryFraction * 100).round();

  static double _fraction(int mv, int minMv, int maxMv) {
    return ((mv - minMv) / (maxMv - minMv)).clamp(0.0, 1.0);
  }

  DeviceState copyWith({
    bool? connected,
    Color? ledColor,
    int? wingsBatteryMillivolts,
    int? remoteBatteryMillivolts,
    int? wingSpeedPercent,
  }) {
    return DeviceState(
      connected: connected ?? this.connected,
      ledColor: ledColor ?? this.ledColor,
      wingsBatteryMillivolts: wingsBatteryMillivolts ?? this.wingsBatteryMillivolts,
      remoteBatteryMillivolts: remoteBatteryMillivolts ?? this.remoteBatteryMillivolts,
      wingSpeedPercent: wingSpeedPercent ?? this.wingSpeedPercent,
    );
  }
}
