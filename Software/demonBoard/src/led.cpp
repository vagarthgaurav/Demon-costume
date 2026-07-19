#include "led.h"

#include <Arduino.h>
#include <FastLED.h>
#include "pins.h"

// Only right and left are driven right now. ESP32-C3 only has 2 hardware
// RMT channels; registering all 5 chains' controllers forced FastLED to
// multiplex the rest, and that multiplexing didn't survive BLE/ESP-NOW
// disabling interrupts (would corrupt output under radio load). Revisit
// aux_right/aux_left/tail once that's solved; their commands are accepted
// over BLE but are no-ops for now.
#define NUM_ACTIVE_CHAINS 2

static CRGB s_right[PIXELS_PER_STRIP];
static CRGB s_left[PIXELS_PER_STRIP];

static CRGB *const s_strips[NUM_ACTIVE_CHAINS] = {s_right, s_left};
static const uint8_t s_chain_bits[NUM_ACTIVE_CHAINS] = {LED_CHAIN_RIGHT, LED_CHAIN_LEFT};

static CRGB s_color[NUM_ACTIVE_CHAINS] = {CRGB::Black, CRGB::Black};
static uint8_t s_enabled_mask = LED_CHAIN_ALL;

static void apply() {
    for (int i = 0; i < NUM_ACTIVE_CHAINS; i++) {
        CRGB c = CRGB::Black;
        if (s_enabled_mask & s_chain_bits[i]) {
            c = s_color[i];
        }
        for (int p = 0; p < PIXELS_PER_STRIP; p++) {
            s_strips[i][p] = c;
        }
    }
    FastLED.show();
}

void led_init() {
    FastLED.addLeds<WS2813, LED_RIGHT, GRB>(s_right, PIXELS_PER_STRIP);
    FastLED.addLeds<WS2813, LED_LEFT,  GRB>(s_left,  PIXELS_PER_STRIP);
    led_off();
}

void led_set_color(uint8_t chain_mask, uint8_t r, uint8_t g, uint8_t b) {
    for (int i = 0; i < NUM_ACTIVE_CHAINS; i++) {
        if (chain_mask & s_chain_bits[i]) s_color[i] = CRGB(r, g, b);
    }
    apply();
}

void led_set_enabled_mask(uint8_t mask) {
    s_enabled_mask = mask & LED_CHAIN_ALL;
    apply();
}

uint8_t led_enabled_mask() {
    return s_enabled_mask;
}

void led_off() {
    s_enabled_mask = 0;
    led_set_color(LED_CHAIN_ALL, 0, 0, 0);
}

void led_refresh() {
    apply();
}
