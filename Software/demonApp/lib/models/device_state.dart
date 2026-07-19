import 'package:flutter/material.dart';

/// The five independently-switchable WS2813 chains on the board.
///
/// Bit order (LSB first) must match LED_CHAIN_* in demonBoard/include/led.h.
enum LedChain {
  right(1 << 0),
  left(1 << 1),
  auxRight(1 << 2),
  auxLeft(1 << 3),
  tail(1 << 4);

  const LedChain(this.bit);
  final int bit;

  static const allMask = 0x1F;
}

/// Snapshot of everything the app knows about a connected demon board.
///
/// There are two independent battery packs in this system: the wings board
/// itself (3S LiPo) and the handheld remote (3S LiPo).
class DeviceState {
  const DeviceState({
    required this.connected,
    required this.ledColors,
    required this.ledBrightness,
    required this.ledChainMask,
    required this.wingsBatteryMillivolts,
    required this.remoteBatteryMillivolts,
    required this.wingSpeedPercent,
  });

  factory DeviceState.disconnected() => DeviceState(
    connected: false,
    ledColors: {
      for (final chain in LedChain.values) chain: Colors.lightBlueAccent,
    },
    ledBrightness: {for (final chain in LedChain.values) chain: 100},
    ledChainMask: 0,
    wingsBatteryMillivolts: 0,
    remoteBatteryMillivolts: 0,
    wingSpeedPercent: 100,
  );

  // 3S LiPo: ~10.8V empty, ~12.6V full.
  static const _wingsMinMv = 10800;
  static const _wingsMaxMv = 12600;

  // 3S LiPo: ~10.8V empty, ~12.6V full (matches demonRemote/bat_indicator.cpp).
  static const _remoteMinMv = 3700;
  static const _remoteMaxMv = 4200;

  final bool connected;
  final Map<LedChain, Color> ledColors;
  final Map<LedChain, int> ledBrightness;
  final int ledChainMask;
  final int wingsBatteryMillivolts;
  final int remoteBatteryMillivolts;
  final int wingSpeedPercent;

  bool isChainEnabled(LedChain chain) => (ledChainMask & chain.bit) != 0;

  Color colorFor(LedChain chain) => ledColors[chain] ?? Colors.red;
  int brightnessFor(LedChain chain) => ledBrightness[chain] ?? 100;

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
    Map<LedChain, Color>? ledColors,
    Map<LedChain, int>? ledBrightness,
    int? ledChainMask,
    int? wingsBatteryMillivolts,
    int? remoteBatteryMillivolts,
    int? wingSpeedPercent,
  }) {
    return DeviceState(
      connected: connected ?? this.connected,
      ledColors: ledColors ?? this.ledColors,
      ledBrightness: ledBrightness ?? this.ledBrightness,
      ledChainMask: ledChainMask ?? this.ledChainMask,
      wingsBatteryMillivolts:
          wingsBatteryMillivolts ?? this.wingsBatteryMillivolts,
      remoteBatteryMillivolts:
          remoteBatteryMillivolts ?? this.remoteBatteryMillivolts,
      wingSpeedPercent: wingSpeedPercent ?? this.wingSpeedPercent,
    );
  }

  /// Returns a copy with [color] applied to [chain], or to every chain if
  /// [chain] is null (the "all" convenience control).
  DeviceState withChainColor(LedChain? chain, Color color) {
    final next = Map<LedChain, Color>.from(ledColors);
    for (final c in chain == null ? LedChain.values : [chain]) {
      next[c] = color;
    }
    return copyWith(ledColors: next);
  }

  /// Returns a copy with [brightness] (0-100) applied to [chain], or to
  /// every chain if [chain] is null (the "all" convenience control).
  DeviceState withChainBrightness(LedChain? chain, int brightness) {
    final next = Map<LedChain, int>.from(ledBrightness);
    for (final c in chain == null ? LedChain.values : [chain]) {
      next[c] = brightness;
    }
    return copyWith(ledBrightness: next);
  }
}
