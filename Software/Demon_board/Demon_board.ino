#include <esp_now.h>
#include <WiFi.h>

#define IN1 0
#define IN2 1

int direction = 0;

// Structure example to receive data
// Must match the sender structure
typedef struct struct_message {
  int direction;
} struct_message;

// Create a struct_message called myData
struct_message myData;

// callback function that will be executed when data is received
void OnDataRecv(const uint8_t *mac, const uint8_t *incomingData, int len) {
  memcpy(&myData, incomingData, sizeof(myData));
  // Serial.print("Bytes received: ");
  // Serial.println(len);


  direction = myData.direction;
}

void setup() {

  pinMode(IN1, OUTPUT);
  pinMode(IN2, OUTPUT);

  // Initialize Serial Monitor
  Serial.begin(115200);

  // Set device as a Wi-Fi Station
  WiFi.mode(WIFI_STA);

  // Init ESP-NOW
  if (esp_now_init() != ESP_OK) {
    Serial.println("Error initializing ESP-NOW");
    return;
  }

  // Once ESPNow is successfully Init, we will register for recv CB to
  // get recv packer info
  esp_now_register_recv_cb(esp_now_recv_cb_t(OnDataRecv));
}

void loop() {
  if (direction == 1) {
    Serial.print("Direction: ");
    Serial.println(direction);
    digitalWrite(IN1, HIGH);
    digitalWrite(IN2, LOW);
  } else if (direction == -1) {
    Serial.print("Direction: ");
    Serial.println(direction);

    digitalWrite(IN1, LOW);
    digitalWrite(IN2, HIGH);
  } else {
    Serial.println("Stopped ");
    digitalWrite(IN1, LOW);
    digitalWrite(IN2, LOW);
  }
  direction = 0;
  delay(100);
}
