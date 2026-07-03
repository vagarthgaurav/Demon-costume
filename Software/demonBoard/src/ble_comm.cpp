#include "ble_comm.h"

#include <Arduino.h>
#include <NimBLEDevice.h>

#include "led.h"

#define SERVICE_UUID         "4100b1e3-0565-4526-aa7b-9cd9f36af43c"
#define LED_COLOR_UUID       "ad2644e3-2e1a-4210-879e-92ac55e68914"
#define LED_ENABLE_UUID      "882b1dd0-1e52-4254-9911-0e4dbaee904d"
#define LED_BRIGHTNESS_UUID  "79e16dd0-271e-4fae-9cf9-e50a620f3f38"
#define WING_SPEED_UUID      "9e3b36af-0877-414e-9562-0219fc809417"
#define WINGS_BATTERY_UUID   "6fd30705-3e6a-49ec-a272-d14b3bfd259f"
#define REMOTE_BATTERY_UUID  "4f271645-84c3-4486-9627-c751398f9d42"

static NimBLECharacteristic *s_led_color_char = nullptr;
static NimBLECharacteristic *s_led_enable_char = nullptr;
static NimBLECharacteristic *s_led_brightness_char = nullptr;
static NimBLECharacteristic *s_wing_speed_char = nullptr;
static NimBLECharacteristic *s_wings_battery_char = nullptr;
static NimBLECharacteristic *s_remote_battery_char = nullptr;

static volatile bool s_connected = false;
static volatile uint8_t s_wing_speed_percent = 50;

class ServerCallbacks : public NimBLEServerCallbacks {
    void onConnect(NimBLEServer *server) override {
        s_connected = true;
    }

    void onDisconnect(NimBLEServer *server) override {
        s_connected = false;
        NimBLEDevice::startAdvertising();
    }
};

// Value layout: [chain_mask, r, g, b]. chain_mask selects which LED_CHAIN_*
// chains get this color; LED_CHAIN_ALL applies it to every chain.
class LedColorCallbacks : public NimBLECharacteristicCallbacks {
    void onWrite(NimBLECharacteristic *characteristic) override {
        std::string value = characteristic->getValue();
        if (value.size() < 4) return;
        led_set_color((uint8_t)value[0], (uint8_t)value[1], (uint8_t)value[2], (uint8_t)value[3]);
    }
};

class LedEnableCallbacks : public NimBLECharacteristicCallbacks {
    void onWrite(NimBLECharacteristic *characteristic) override {
        std::string value = characteristic->getValue();
        if (value.empty()) return;
        led_set_enabled_mask((uint8_t)value[0]);
    }
};

// Brightness control is disabled for now (see led.cpp); this characteristic
// stays registered so the app doesn't fail to find it, but writes are
// currently ignored.
class LedBrightnessCallbacks : public NimBLECharacteristicCallbacks {
    void onWrite(NimBLECharacteristic *characteristic) override {}
};

class WingSpeedCallbacks : public NimBLECharacteristicCallbacks {
    void onWrite(NimBLECharacteristic *characteristic) override {
        std::string value = characteristic->getValue();
        if (value.empty()) return;
        s_wing_speed_percent = (uint8_t)value[0];
    }
};

void ble_init() {
    NimBLEDevice::init("DemonBoard");

    NimBLEServer *server = NimBLEDevice::createServer();
    server->setCallbacks(new ServerCallbacks());

    NimBLEService *service = server->createService(SERVICE_UUID);

    // Color/brightness/speed are slider-driven and fire rapidly, so they
    // accept write-without-response to avoid GATT ack round trips stalling
    // the write queue. Enable mask changes stay ack'd since they're rare
    // and correctness there matters more than latency.
    s_led_color_char = service->createCharacteristic(
        LED_COLOR_UUID, NIMBLE_PROPERTY::WRITE | NIMBLE_PROPERTY::WRITE_NR);
    s_led_color_char->setCallbacks(new LedColorCallbacks());

    s_led_enable_char = service->createCharacteristic(LED_ENABLE_UUID, NIMBLE_PROPERTY::WRITE);
    s_led_enable_char->setCallbacks(new LedEnableCallbacks());

    s_led_brightness_char = service->createCharacteristic(
        LED_BRIGHTNESS_UUID, NIMBLE_PROPERTY::WRITE | NIMBLE_PROPERTY::WRITE_NR);
    s_led_brightness_char->setCallbacks(new LedBrightnessCallbacks());

    s_wing_speed_char = service->createCharacteristic(
        WING_SPEED_UUID, NIMBLE_PROPERTY::WRITE | NIMBLE_PROPERTY::WRITE_NR);
    s_wing_speed_char->setCallbacks(new WingSpeedCallbacks());

    s_wings_battery_char = service->createCharacteristic(
        WINGS_BATTERY_UUID, NIMBLE_PROPERTY::READ | NIMBLE_PROPERTY::NOTIFY);

    s_remote_battery_char = service->createCharacteristic(
        REMOTE_BATTERY_UUID, NIMBLE_PROPERTY::READ | NIMBLE_PROPERTY::NOTIFY);

    service->start();

    NimBLEAdvertising *advertising = NimBLEDevice::getAdvertising();
    advertising->addServiceUUID(SERVICE_UUID);
    advertising->start();
}

bool ble_is_connected() {
    return s_connected;
}

static void notify_battery_mv(NimBLECharacteristic *characteristic, uint16_t battery_mv) {
    if (!characteristic) return;
    uint8_t buf[2] = { (uint8_t)(battery_mv & 0xFF), (uint8_t)(battery_mv >> 8) };
    characteristic->setValue(buf, sizeof(buf));
    if (s_connected) characteristic->notify();
}

void ble_notify_wings_battery(uint16_t battery_mv) {
    notify_battery_mv(s_wings_battery_char, battery_mv);
}

void ble_notify_remote_battery(uint16_t battery_mv) {
    notify_battery_mv(s_remote_battery_char, battery_mv);
}

uint8_t ble_wing_speed_percent() {
    return s_wing_speed_percent;
}
