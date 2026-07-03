#include <Arduino.h>

#include "battery.h"
#include "ble_comm.h"
#include "espnow_comm.h"
#include "led.h"
#include "motor.h"

// Timeout: if no packet received within this many ms, stop motors
static const uint32_t HOLD_TIMEOUT_MS = 150;

// How often to push the wings battery reading to the phone app over BLE
static const uint32_t BLE_BATTERY_INTERVAL_MS = 2000;

// How often to re-send the current LED state, to self-correct if
// radio-induced noise (this board has no level shifter on the LED data
// lines) ever corrupts a frame.
static const uint32_t LED_REFRESH_INTERVAL_MS = 100;

static uint32_t s_last_packet_ms = 0;
static uint32_t s_last_ble_battery_ms = 0;
static uint32_t s_last_led_refresh_ms = 0;
static ButtonEvent s_active_event = ButtonEvent::LED;

void setup() {
    Serial.begin(115200);
    battery_init();
    motor_init();
    // LED init runs last so its "off" command is the final thing sent to the
    // strip's data line, in case radio bring-up (WiFi/BLE) induces any noise
    // on the LED GPIO during its own init.
    espnow_init();
    ble_init();
    led_init();
}

void loop() {
    if ((millis() - s_last_ble_battery_ms) >= BLE_BATTERY_INTERVAL_MS) {
        s_last_ble_battery_ms = millis();
        ble_notify_wings_battery(battery_read_mv());
    }

    if ((millis() - s_last_led_refresh_ms) >= LED_REFRESH_INTERVAL_MS) {
        s_last_led_refresh_ms = millis();
        led_refresh();
    }

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
