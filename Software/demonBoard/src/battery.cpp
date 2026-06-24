#include "battery.h"

#include <Arduino.h>
#include "pins.h"

// Voltage divider: R16=4.7k top, R17=1k bottom
// Ratio calibrated empirically: 11.68V actual vs 12.99V raw (factor 5.7 * 11680/12990)
// 3S LiPo range: 10.8V (empty) to 12.6V (full)
static const float BAT_DIVIDER_RATIO = 5.1193f;
static const float ADC_REF_MV = 3300.0f;
static const float ADC_MAX = 4095.0f;

void battery_init() {
    analogReadResolution(12);
}

uint16_t battery_read_mv() {
    uint32_t sum = 0;
    for (int i = 0; i < 8; i++) sum += analogRead(BATTERY_SENSE);
    float adc = sum / 8.0f;
    uint16_t mv = (uint16_t)(adc / ADC_MAX * ADC_REF_MV * BAT_DIVIDER_RATIO);
    Serial.printf("Battery ADC: %.0f  Voltage: %u mV (%.2f V)\n", adc, mv, mv / 1000.0f);
    return mv;
}
