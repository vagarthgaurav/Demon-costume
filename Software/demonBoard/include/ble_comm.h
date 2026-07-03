#pragma once

#include <stdint.h>

// Bluetooth LE GATT server for the phone app. Runs alongside ESP-NOW
// (which talks to demonRemote) — the two coexist on the same radio via the
// standard ESP32 WiFi/BLE coexistence handled by the IDF, no extra work needed.
void ble_init();

bool ble_is_connected();

void ble_notify_wings_battery(uint16_t battery_mv);
void ble_notify_remote_battery(uint16_t battery_mv);

// Latest wing-speed percent (0-100) written by the app.
// Not yet wired to the motor driver — wing motors are still on/off only.
uint8_t ble_wing_speed_percent();
