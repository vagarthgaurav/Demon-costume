#include "charger_status.h"

#include <Arduino.h>
#include "pins.h"

// STAT blink fault detection: sample at ~5 Hz, look for edges within a 1.5s window.
// BQ25616 blinks at 1 Hz — we expect 2+ transitions per second.
static const uint32_t SAMPLE_INTERVAL_MS  = 200;   // 5 Hz sampling
static const uint32_t FAULT_WINDOW_MS     = 1500;  // sliding window for edge counting
static const uint8_t  FAULT_EDGE_THRESH   = 2;     // edges in window → fault

static const uint8_t  HISTORY_LEN = (FAULT_WINDOW_MS / SAMPLE_INTERVAL_MS) + 1;

static uint32_t s_edge_times[HISTORY_LEN];  // ring buffer of recent edge timestamps
static uint8_t  s_edge_head  = 0;
static uint8_t  s_edge_count = 0;

static uint32_t s_last_sample_ms = 0;
static bool     s_last_stat      = false;
static ChargerState s_state      = ChargerState::NO_INPUT;

void charger_status_init() {
    pinMode(PIN_CHARGER_PG,   INPUT);   // open-drain, external pull-up on PCB
    pinMode(PIN_CHARGER_STAT, INPUT);   // open-drain, external pull-up on PCB

    s_last_stat = (digitalRead(PIN_CHARGER_STAT) == HIGH);
    s_last_sample_ms = millis();
}

// Count edges within the sliding window.
static uint8_t count_recent_edges(uint32_t now) {
    uint8_t count = 0;
    for (uint8_t i = 0; i < s_edge_count; i++) {
        uint8_t idx = (s_edge_head - 1 - i + HISTORY_LEN) % HISTORY_LEN;
        if ((now - s_edge_times[idx]) <= FAULT_WINDOW_MS) {
            count++;
        } else {
            break;  // ring buffer is ordered oldest→newest; once outside window, done
        }
    }
    return count;
}

static void record_edge(uint32_t now) {
    s_edge_times[s_edge_head] = now;
    s_edge_head = (s_edge_head + 1) % HISTORY_LEN;
    if (s_edge_count < HISTORY_LEN) s_edge_count++;
}

static const char* state_name(ChargerState s) {
    switch (s) {
        case ChargerState::NO_INPUT:  return "NO_INPUT";
        case ChargerState::CHARGING:  return "CHARGING";
        case ChargerState::COMPLETE:  return "COMPLETE";
        case ChargerState::FAULT:     return "FAULT";
        default:                      return "UNKNOWN";
    }
}

void charger_status_update() {
    uint32_t now = millis();
    if ((now - s_last_sample_ms) < SAMPLE_INTERVAL_MS) return;
    s_last_sample_ms = now;

    int pg_raw   = digitalRead(PIN_CHARGER_PG);
    int stat_raw = digitalRead(PIN_CHARGER_STAT);
    bool pg   = (pg_raw   == LOW);   // active low
    bool stat = (stat_raw == HIGH);  // HIGH = idle/complete

    ChargerState prev_state = s_state;

    if (!pg) {
        s_state = ChargerState::NO_INPUT;
        s_edge_count = 0;
    } else {
        // Detect STAT edge
        if (stat != s_last_stat) {
            record_edge(now);
        }
        s_last_stat = stat;

        uint8_t edges = count_recent_edges(now);
        if (edges >= FAULT_EDGE_THRESH) {
            s_state = ChargerState::FAULT;
        } else if (!stat) {
            s_state = ChargerState::CHARGING;
        } else {
            s_state = ChargerState::COMPLETE;
        }
    }

    if (s_state != prev_state) {
        Serial.printf("[charger] PG=%d STAT=%d -> %s\n", pg_raw, stat_raw, state_name(s_state));
    } else {
        Serial.printf("[charger] PG=%d STAT=%d  state=%s\n", pg_raw, stat_raw, state_name(s_state));
    }
}

ChargerState charger_status_get() {
    return s_state;
}
