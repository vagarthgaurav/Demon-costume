#pragma once

#include <stdint.h>

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
ButtonEvent espnow_last_event();
bool espnow_has_new_event();
void espnow_send_battery(uint16_t battery_mv);
