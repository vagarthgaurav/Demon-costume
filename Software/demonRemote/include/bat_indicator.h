#pragma once

#include <stdint.h>
#include "charger_status.h"

void bat_indicator_init();
void bat_indicator_set(uint16_t battery_mv);

// Drive LEDs to show current charger state. Call every loop when charger is connected.
void bat_indicator_show_charger(ChargerState state, uint16_t battery_mv);

void bat_indicator_update();
void bat_indicator_off();
