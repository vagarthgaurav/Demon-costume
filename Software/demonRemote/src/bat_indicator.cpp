#include "bat_indicator.h"

#include <Arduino.h>
#include <FastLED.h>
#include "pins.h"

static const int NUM_LEDS = 4;
static const uint16_t BAT_MIN_MV = 10800; // 3S LiPo empty (3.6V/cell)
static const uint16_t BAT_MAX_MV = 12600; // 3S LiPo full  (4.2V/cell)
static const uint32_t DISPLAY_TIMEOUT_MS = 5000;

// Charger animation: full breathe cycle (fade in + fade out)
static const uint32_t BREATHE_PERIOD_MS = 2000;

static CRGB s_leds[NUM_LEDS];       // controller battery — PIN_LED_CTRL_BAT
static CRGB s_charge_leds[NUM_LEDS]; // remote battery / charger status — PIN_LED_REMOTE_BAT

static uint32_t s_lit_since_ms = 0;
static bool s_is_on = false;

void bat_indicator_init() {
    FastLED.addLeds<WS2812B, PIN_LED_CTRL_BAT,   GRB>(s_leds,        NUM_LEDS);
    FastLED.addLeds<WS2812B, PIN_LED_REMOTE_BAT,  GRB>(s_charge_leds, NUM_LEDS);
    FastLED.setBrightness(64);
    bat_indicator_off();
    fill_solid(s_charge_leds, NUM_LEDS, CRGB::Black);
    FastLED.show();
}

void bat_indicator_set(uint16_t battery_mv) {
    uint16_t clamped = battery_mv < BAT_MIN_MV ? BAT_MIN_MV
                     : battery_mv > BAT_MAX_MV ? BAT_MAX_MV
                     : battery_mv;

    uint32_t range = BAT_MAX_MV - BAT_MIN_MV;
    uint8_t pct = (uint8_t)((uint32_t)(clamped - BAT_MIN_MV) * 100 / range);

    CRGB color;
    int lit;
    if (pct >= 75) {
        color = CRGB::Green;
        lit = NUM_LEDS;
    } else if (pct >= 25) {
        color = CRGB::Yellow;
        lit = 1 + (int)((uint32_t)(pct - 25) * (NUM_LEDS - 1) / 50);
    } else {
        color = CRGB::Red;
        lit = 1;
    }

    for (int i = 0; i < NUM_LEDS; i++) {
        s_leds[NUM_LEDS - 1 - i] = (i < lit) ? color : CRGB::Black;
    }
    FastLED.show();
    s_lit_since_ms = millis();
    s_is_on = true;
}

void bat_indicator_show_charger(ChargerState state, uint16_t) {
    uint32_t now = millis();

    switch (state) {
        case ChargerState::NO_INPUT:
        case ChargerState::FAULT:
            fill_solid(s_charge_leds, NUM_LEDS, CRGB::Black);
            break;

        case ChargerState::COMPLETE:
            fill_solid(s_charge_leds, NUM_LEDS, CRGB::Green);
            break;

        case ChargerState::CHARGING: {
            // Triangle-wave breathe: ramp 0→255 in first half, 255→0 in second half
            uint32_t phase = now % BREATHE_PERIOD_MS;
            uint8_t brightness = (phase < BREATHE_PERIOD_MS / 2)
                ? (uint8_t)(phase * 255 / (BREATHE_PERIOD_MS / 2))
                : (uint8_t)((BREATHE_PERIOD_MS - phase) * 255 / (BREATHE_PERIOD_MS / 2));
            CRGB yellow = CRGB(brightness, brightness, 0);
            fill_solid(s_charge_leds, NUM_LEDS, yellow);
            break;
        }
    }

    FastLED.show();
}

void bat_indicator_update() {
    if (s_is_on && (millis() - s_lit_since_ms) >= DISPLAY_TIMEOUT_MS) {
        bat_indicator_off();
    }
}

void bat_indicator_off() {
    if (!s_is_on) return;
    fill_solid(s_leds, NUM_LEDS, CRGB::Black);
    FastLED.show();
    s_is_on = false;
}
