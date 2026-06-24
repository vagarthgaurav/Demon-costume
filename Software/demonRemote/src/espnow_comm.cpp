#include "espnow_comm.h"

#include <Arduino.h>
#include <WiFi.h>
#include <esp_now.h>

static uint8_t controllerMac[] = CONTROLLER_MAC;
static esp_now_peer_info_t peerInfo;

static volatile uint16_t s_last_battery_mv = 0;
static volatile bool s_has_battery_update = false;

static void onDataSent(const uint8_t *mac_addr, esp_now_send_status_t status) {
}

static void onDataReceived(const uint8_t *mac, const uint8_t *data, int len) {
    if (len < (int)sizeof(ControllerPacket)) return;
    const ControllerPacket *pkt = reinterpret_cast<const ControllerPacket *>(data);
    s_last_battery_mv = pkt->battery_mv;
    s_has_battery_update = true;
}

void espnow_init() {
    WiFi.mode(WIFI_STA);

    if (esp_now_init() != ESP_OK) {
        Serial.println("ESP-NOW init failed");
        return;
    }

    esp_now_register_send_cb(onDataSent);
    esp_now_register_recv_cb(onDataReceived);

    memcpy(peerInfo.peer_addr, controllerMac, 6);
    peerInfo.channel = 0;
    peerInfo.encrypt = false;

    if (esp_now_add_peer(&peerInfo) != ESP_OK) {
        Serial.println("Failed to add peer");
    }
}

void espnow_send(ButtonEvent event) {
    RemotePacket packet = { event };
    esp_now_send(controllerMac, reinterpret_cast<uint8_t *>(&packet), sizeof(packet));
}

bool espnow_has_battery_update() {
    if (!s_has_battery_update) return false;
    s_has_battery_update = false;
    return true;
}

uint16_t espnow_last_battery_mv() {
    return s_last_battery_mv;
}
