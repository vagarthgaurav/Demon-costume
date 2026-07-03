import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../models/device_state.dart';
import 'demon_service.dart';

/// Fake demon board for developing/testing the UI without real BLE hardware.
///
/// Simulates a connect delay and a slowly draining battery so the battery
/// screen has something to show.
class MockDemonService implements DemonService {
  MockDemonService() {
    _controller.add(_current);
  }

  final _controller = StreamController<DeviceState>.broadcast();
  final _random = Random();
  Timer? _batteryTimer;

  DeviceState _current = DeviceState.disconnected();

  @override
  Stream<DeviceState> get state => _controller.stream;

  @override
  Future<void> connect() async {
    await Future.delayed(const Duration(milliseconds: 600));
    _current = _current.copyWith(
      connected: true,
      wingsBatteryMillivolts: 8200,
      remoteBatteryMillivolts: 12300,
    );
    _controller.add(_current);

    _batteryTimer?.cancel();
    _batteryTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      final wingsJitter = _random.nextInt(5) - 2; // +/- 2 mV noise
      final remoteJitter = _random.nextInt(5) - 2;
      final wingsDrained =
          (_current.wingsBatteryMillivolts - 1 + wingsJitter).clamp(6800, 8400);
      final remoteDrained =
          (_current.remoteBatteryMillivolts - 1 + remoteJitter).clamp(10800, 12600);
      _current = _current.copyWith(
        wingsBatteryMillivolts: wingsDrained,
        remoteBatteryMillivolts: remoteDrained,
      );
      _controller.add(_current);
    });
  }

  @override
  Future<void> disconnect() async {
    _batteryTimer?.cancel();
    _current = DeviceState.disconnected();
    _controller.add(_current);
  }

  @override
  Future<void> setLedColor(Color color, {LedChain? chain}) async {
    _current = _current.withChainColor(chain, color);
    _controller.add(_current);
  }

  @override
  Future<void> setLedBrightness(int percent, {LedChain? chain}) async {
    _current = _current.withChainBrightness(chain, percent.clamp(0, 100));
    _controller.add(_current);
  }

  @override
  Future<void> setLedChainEnabled(LedChain chain, bool enabled) async {
    final mask = enabled ? (_current.ledChainMask | chain.bit) : (_current.ledChainMask & ~chain.bit);
    _current = _current.copyWith(ledChainMask: mask);
    _controller.add(_current);
  }

  @override
  Future<void> setWingSpeed(int percent) async {
    _current = _current.copyWith(wingSpeedPercent: percent);
    _controller.add(_current);
  }

  @override
  void dispose() {
    _batteryTimer?.cancel();
    _controller.close();
  }
}
