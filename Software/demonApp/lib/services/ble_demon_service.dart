import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:universal_ble/universal_ble.dart';

import '../models/device_state.dart';
import 'demon_service.dart';

/// Talks to the demonBoard over Bluetooth LE.
///
/// UUIDs must match the GATT server in demonBoard/src/ble_comm.cpp. The
/// board also stays connected to demonRemote over ESP-NOW at the same time
/// — the two radios coexist independently, so this doesn't affect that link.
class BleDemonService implements DemonService {
  static const _serviceUuid = '4100b1e3-0565-4526-aa7b-9cd9f36af43c';
  static const _ledColorUuid = 'ad2644e3-2e1a-4210-879e-92ac55e68914';
  static const _ledEnableUuid = '882b1dd0-1e52-4254-9911-0e4dbaee904d';
  static const _wingSpeedUuid = '9e3b36af-0877-414e-9562-0219fc809417';
  static const _wingsBatteryUuid = '6fd30705-3e6a-49ec-a272-d14b3bfd259f';
  static const _remoteBatteryUuid = '4f271645-84c3-4486-9627-c751398f9d42';

  static const _deviceName = 'DemonBoard';
  static const _scanTimeout = Duration(seconds: 10);

  final _controller = StreamController<DeviceState>.broadcast();
  DeviceState _current = DeviceState.disconnected();

  BleDevice? _device;
  BleCharacteristic? _ledColorChar;
  BleCharacteristic? _ledEnableChar;
  BleCharacteristic? _wingSpeedChar;
  StreamSubscription<bool>? _connectionSub;
  StreamSubscription<Uint8List>? _wingsBatterySub;
  StreamSubscription<Uint8List>? _remoteBatterySub;

  @override
  Stream<DeviceState> get state => _controller.stream;

  void _emit(DeviceState next) {
    _current = next;
    _controller.add(_current);
  }

  @override
  Future<void> connect() async {
    await UniversalBle.requestPermissions();

    final found = Completer<BleDevice>();
    final scanSub = UniversalBle.scanStream.listen((device) {
      if (found.isCompleted) return;
      if (device.name == _deviceName) found.complete(device);
    });

    await UniversalBle.startScan(scanFilter: ScanFilter(withServices: [_serviceUuid]));
    final BleDevice device;
    try {
      device = await found.future.timeout(_scanTimeout);
    } finally {
      await scanSub.cancel();
      await UniversalBle.stopScan();
    }

    _device = device;

    _connectionSub?.cancel();
    _connectionSub = device.connectionStream.listen((isConnected) {
      if (!isConnected) _emit(DeviceState.disconnected());
    });

    await device.connect();
    final services = await device.discoverServices();
    final service = services.firstWhere((s) => s.uuid.toLowerCase() == _serviceUuid);

    _ledColorChar = service.characteristics.firstWhere((c) => c.uuid.toLowerCase() == _ledColorUuid);
    _ledEnableChar = service.characteristics.firstWhere((c) => c.uuid.toLowerCase() == _ledEnableUuid);
    _wingSpeedChar = service.characteristics.firstWhere((c) => c.uuid.toLowerCase() == _wingSpeedUuid);
    final wingsBatteryChar =
        service.characteristics.firstWhere((c) => c.uuid.toLowerCase() == _wingsBatteryUuid);
    final remoteBatteryChar =
        service.characteristics.firstWhere((c) => c.uuid.toLowerCase() == _remoteBatteryUuid);

    await wingsBatteryChar.notifications.subscribe();
    await remoteBatteryChar.notifications.subscribe();

    _wingsBatterySub?.cancel();
    _wingsBatterySub = wingsBatteryChar.onValueReceived.listen((bytes) {
      _emit(_current.copyWith(wingsBatteryMillivolts: _decodeMv(bytes)));
    });

    _remoteBatterySub?.cancel();
    _remoteBatterySub = remoteBatteryChar.onValueReceived.listen((bytes) {
      _emit(_current.copyWith(remoteBatteryMillivolts: _decodeMv(bytes)));
    });

    _emit(_current.copyWith(connected: true, ledChainMask: LedChain.allMask));
  }

  int _channel(double component) => (component * 255.0).round().clamp(0, 255);

  int _decodeMv(List<int> bytes) {
    if (bytes.length < 2) return 0;
    return Uint8List.fromList(bytes).buffer.asByteData().getUint16(0, Endian.little);
  }

  @override
  Future<void> disconnect() async {
    await _device?.disconnect();
    await _connectionSub?.cancel();
    await _wingsBatterySub?.cancel();
    await _remoteBatterySub?.cancel();
    _device = null;
    _emit(DeviceState.disconnected());
  }

  @override
  Future<void> setLedColor(Color color) async {
    final char = _ledColorChar;
    if (char == null) return;
    await char.write(
      [_channel(color.r), _channel(color.g), _channel(color.b)],
      withResponse: true,
    );
    _emit(_current.copyWith(ledColor: color));
  }

  @override
  Future<void> setLedChainEnabled(LedChain chain, bool enabled) async {
    final char = _ledEnableChar;
    if (char == null) return;
    final mask = enabled ? (_current.ledChainMask | chain.bit) : (_current.ledChainMask & ~chain.bit);
    await char.write([mask], withResponse: true);
    _emit(_current.copyWith(ledChainMask: mask));
  }

  @override
  Future<void> setWingSpeed(int percent) async {
    final char = _wingSpeedChar;
    if (char == null) return;
    await char.write([percent.clamp(0, 100)], withResponse: true);
    _emit(_current.copyWith(wingSpeedPercent: percent));
  }

  @override
  void dispose() {
    _connectionSub?.cancel();
    _wingsBatterySub?.cancel();
    _remoteBatterySub?.cancel();
    _controller.close();
  }
}
