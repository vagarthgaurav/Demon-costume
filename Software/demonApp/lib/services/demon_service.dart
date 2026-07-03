import 'package:flutter/material.dart';

import '../models/device_state.dart';

/// Everything the UI needs from a demon board connection.
///
/// The real implementation will talk BLE; for now [MockDemonService]
/// fakes it so the UI can be built and tested without hardware.
abstract class DemonService {
  Stream<DeviceState> get state;

  Future<void> connect();
  Future<void> disconnect();

  /// Sets the color of [chain], or of every chain if [chain] is null.
  Future<void> setLedColor(Color color, {LedChain? chain});

  /// Sets the brightness (0-100) of [chain], or of every chain if [chain]
  /// is null.
  Future<void> setLedBrightness(int percent, {LedChain? chain});

  Future<void> setLedChainEnabled(LedChain chain, bool enabled);
  Future<void> setWingSpeed(int percent);

  void dispose();
}
