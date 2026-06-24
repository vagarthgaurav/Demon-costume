#include <Arduino.h>

#include "bat_indicator.h"
#include "charger_status.h"
#include "espnow_comm.h"
#include "pins.h"

// Send repeat interval while a button is held
static const uint32_t SEND_INTERVAL_MS = 80;

static uint32_t s_last_send_ms = 0;
static uint16_t s_last_battery_mv = 0;

void setup() {
    Serial.begin(115200);
    while (!Serial) delay(10);  // wait for USB CDC to enumerate

    pinMode(PIN_BTN_WING_UP, INPUT_PULLUP);
    pinMode(PIN_BTN_WING_DOWN, INPUT_PULLUP);
    pinMode(PIN_BTN_LED, INPUT_PULLUP);
    pinMode(PIN_BTN_SHOW_BATTERY, INPUT_PULLUP);

    pinMode(PIN_CHARGE_EN, OUTPUT);
    

    bat_indicator_init();
    charger_status_init();
    espnow_init();
}

void loop() {

    digitalWrite(PIN_CHARGE_EN, LOW);

    bool wingUp = digitalRead(PIN_BTN_WING_UP) == LOW;
    bool wingDown = digitalRead(PIN_BTN_WING_DOWN) == LOW;
    bool led = digitalRead(PIN_BTN_LED) == LOW;
    bool showBattery = digitalRead(PIN_BTN_SHOW_BATTERY) == LOW;

    bool anyHeld = wingUp || wingDown || led || showBattery;

    if (anyHeld && (millis() - s_last_send_ms) >= SEND_INTERVAL_MS) {
        if (wingUp) {
            espnow_send(ButtonEvent::WING_UP);
        } else if (wingDown) {
            espnow_send(ButtonEvent::WING_DOWN);
        } else if (led) {
            espnow_send(ButtonEvent::LED);
        } else if (showBattery) {
            espnow_send(ButtonEvent::SHOW_BATTERY);
        }
        s_last_send_ms = millis();
    }

    if (espnow_has_battery_update()) {
        s_last_battery_mv = espnow_last_battery_mv();
        bat_indicator_set(s_last_battery_mv);
        Serial.printf("Battery: %u mV (%.2f V)\n", s_last_battery_mv, s_last_battery_mv / 1000.0f);
    }

    charger_status_update();
    ChargerState charger = charger_status_get();
    if (charger != ChargerState::NO_INPUT) {
        bat_indicator_show_charger(charger, s_last_battery_mv);
    } else {
        bat_indicator_update();
    }
}
