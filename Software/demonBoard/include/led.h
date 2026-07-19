#pragma once

#include <stdint.h>

// Chain bit order, LSB first: right, left, aux_right, aux_left, tail. Only
// right and left are actually driven right now (see led.cpp); the rest are
// accepted over BLE but currently no-ops.
#define LED_CHAIN_RIGHT     (1 << 0)
#define LED_CHAIN_LEFT      (1 << 1)
#define LED_CHAIN_AUX_RIGHT (1 << 2)
#define LED_CHAIN_AUX_LEFT  (1 << 3)
#define LED_CHAIN_TAIL      (1 << 4)
#define LED_CHAIN_ALL       0x1F

// Each chain is an 8-pixel WS2813 strip on its own data pin.
#define PIXELS_PER_STRIP 8

void led_init();

// Sets the base color for every chain selected in the LED_CHAIN_* bitmask,
// leaving other chains' colors untouched.
void led_set_color(uint8_t chain_mask, uint8_t r, uint8_t g, uint8_t b);

// Bitmask of LED_CHAIN_* selecting which chains are lit; disabled chains are
// forced off regardless of their current color.
void led_set_enabled_mask(uint8_t mask);

// Bitmask of LED_CHAIN_* currently enabled, per the last led_set_enabled_mask
// call (or LED_CHAIN_ALL at boot).
uint8_t led_enabled_mask();

void led_off();

// Re-sends the current color/enabled state without changing it. Called
// periodically to self-correct if noise on the data line (no level shifter
// on this board) ever corrupts a frame.
void led_refresh();
