#pragma once

#include <stdint.h>

// MAC address of the demonBoard controller (receiver)
// Update this with the actual MAC address of your controller ESP32-C3
#define CONTROLLER_MAC { 0x08, 0x92, 0x72, 0xCE, 0xE5, 0x40 }

enum class ButtonEvent : uint8_t {
    WING_UP       = 0x01,
    WING_DOWN     = 0x02,
    LED           = 0x03,
    SHOW_BATTERY  = 0x04,
};

struct RemotePacket {
    ButtonEvent event;
};

struct ControllerPacket {
    uint16_t battery_mv;
};

void espnow_init();
void espnow_send(ButtonEvent event);
bool espnow_has_battery_update();
uint16_t espnow_last_battery_mv();
