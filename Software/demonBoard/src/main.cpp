#include <Arduino.h>

#include "battery.h"
#include "espnow_comm.h"
#include "motor.h"

// Timeout: if no packet received within this many ms, stop motors
static const uint32_t HOLD_TIMEOUT_MS = 150;

static uint32_t s_last_packet_ms = 0;
static ButtonEvent s_active_event = ButtonEvent::LED;

void setup() {
    Serial.begin(115200);
    battery_init();
    motor_init();
    espnow_init();
}

void loop() {
    if (espnow_has_new_event()) {
        s_active_event = espnow_last_event();

        if (s_active_event == ButtonEvent::SHOW_BATTERY) {
            espnow_send_battery(battery_read_mv());
        } else {
            s_last_packet_ms = millis();
        }
    }

    bool timed_out = (millis() - s_last_packet_ms) > HOLD_TIMEOUT_MS;

    if (timed_out || s_active_event == ButtonEvent::SHOW_BATTERY) {
        motor_stop();
    } else if (s_active_event == ButtonEvent::WING_UP) {
        motor_up();
    } else if (s_active_event == ButtonEvent::WING_DOWN) {
        motor_down();
    } else {
        motor_stop();
    }
}
