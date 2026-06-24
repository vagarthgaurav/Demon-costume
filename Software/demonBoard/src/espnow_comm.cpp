#include "espnow_comm.h"

#include <Arduino.h>
#include <WiFi.h>
#include <esp_now.h>
#include <string.h>

static volatile ButtonEvent s_last_event = ButtonEvent::WING_UP;
static volatile bool s_has_new_event = false;

static uint8_t s_remote_mac[6];
static bool s_remote_known = false;

static void onDataReceived(const uint8_t *mac, const uint8_t *data, int len) {
    if (len < (int)sizeof(RemotePacket)) return;
    const RemotePacket *pkt = reinterpret_cast<const RemotePacket *>(data);
    s_last_event = pkt->event;
    s_has_new_event = true;

    if (!s_remote_known) {
        memcpy(s_remote_mac, mac, 6);
        esp_now_peer_info_t peer = {};
        memcpy(peer.peer_addr, mac, 6);
        peer.channel = 0;
        peer.encrypt = false;
        esp_now_add_peer(&peer);
        s_remote_known = true;
    }
}

void espnow_init() {
    WiFi.mode(WIFI_STA);

    if (esp_now_init() != ESP_OK) {
        Serial.println("ESP-NOW init failed");
        return;
    }

    esp_now_register_recv_cb(onDataReceived);
}

ButtonEvent espnow_last_event() {
    return s_last_event;
}

bool espnow_has_new_event() {
    if (!s_has_new_event) return false;
    s_has_new_event = false;
    return true;
}

void espnow_send_battery(uint16_t battery_mv) {
    if (!s_remote_known) return;
    ControllerPacket pkt = { battery_mv };
    esp_now_send(s_remote_mac, reinterpret_cast<uint8_t *>(&pkt), sizeof(pkt));
}
