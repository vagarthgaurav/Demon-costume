#pragma once

#include <stdint.h>

// Charger states decoded from PG and STAT pins (BQ25616)
enum class ChargerState {
    NO_INPUT,        // PG high — no valid charger input
    CHARGING,        // PG low, STAT low — actively charging
    COMPLETE,        // PG low, STAT high (stable) — charge complete / sleep
    FAULT,           // PG low, STAT blinking ~1 Hz — fault condition
};

void charger_status_init();

// Call every loop iteration; reads PG/STAT and updates internal state.
void charger_status_update();

ChargerState charger_status_get();
