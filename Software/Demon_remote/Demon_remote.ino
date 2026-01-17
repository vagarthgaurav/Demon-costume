#include <esp_now.h>
#include <WiFi.h>

#define UP_BTN 0
#define DOWN_BTN 1


// REPLACE WITH YOUR RECEIVER MAC Address
uint8_t broadcastAddress[] = { 0x08, 0x92, 0x72, 0xce, 0xe5, 0x40 };

// Structure example to send data
// Must match the receiver structure
typedef struct struct_message {
  int direction;
} struct_message;

// Create a struct_message called myData
struct_message myData;

esp_now_peer_info_t peerInfo;


void send_data(int data) {
  // Send message via ESP-NOW
  esp_err_t result = esp_now_send(broadcastAddress, (uint8_t *)&myData, sizeof(myData));

  if (result != ESP_OK) {
    Serial.println("Error sending the data");
  }
}

// callback when data is sent
void OnDataSent(const uint8_t *mac_addr, esp_now_send_status_t status) {
  //Serial.print("\r\nLast Packet Send Status:\t");
  Serial.println(status == ESP_NOW_SEND_SUCCESS ? "Delivery Success" : "Delivery Fail");
}

void setup() {
  pinMode(UP_BTN, INPUT);
  pinMode(DOWN_BTN, INPUT);

  // Init Serial Monitor
  Serial.begin(115200);

  // Set device as a Wi-Fi Station
  WiFi.mode(WIFI_STA);

  // Init ESP-NOW
  if (esp_now_init() != ESP_OK) {
    Serial.println("Error initializing ESP-NOW");
    return;
  }

  // Once ESPNow is successfully Init, we will register for Send CB to
  // get the status of Trasnmitted packet
  esp_now_register_send_cb(esp_now_send_cb_t(OnDataSent));

  // Register peer
  memcpy(peerInfo.peer_addr, broadcastAddress, 6);
  peerInfo.channel = 0;
  peerInfo.encrypt = false;

  // Add peer
  if (esp_now_add_peer(&peerInfo) != ESP_OK) {
    Serial.println("Failed to add peer");
    return;
  }
}

void loop() {

  int up_btn_data = digitalRead(UP_BTN);
  int down_btn_data = digitalRead(DOWN_BTN);

  if (up_btn_data == 0) {
    // Rotate clockwise

    Serial.println("Going up");

    myData.direction = 1;
    send_data(myData.direction);
  }

  if (down_btn_data == 0) {
    // Rotate anti-clockwise

    Serial.println("Going down");

    myData.direction = -1;
    send_data(myData.direction);
  }

  delay(100);
}
