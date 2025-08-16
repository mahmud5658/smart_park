// ==== WiFi Credentials ====
const char* ssid = "car parking";
const char* password = "iotproject";

// ==== Firebase Setup ====
#define API_KEY "AIzaSyC6WdEF62ar9xBiIfC9d91GKc70dF6V1Us"
#define DATABASE_URL "https://car-parking-2ae16-default-rtdb.firebaseio.com/"
#define FIREBASE_PROJECT_ID "car-parking-2ae16"

#include <WiFi.h>
#include <Firebase_ESP_Client.h>
#include <Wire.h>
#include <LiquidCrystal_I2C.h>
#include <ESP32Servo.h>

// ==== Firebase Objects ====
FirebaseData fbdo;
FirebaseConfig config;
FirebaseAuth auth;

// ==== Servo and LCD ====
Servo gateServo;
LiquidCrystal_I2C lcd(0x27, 16, 2);

// ==== Pins ====
#define IR1 14
#define IR2 13
#define SERVO_PIN 27
const int slotPins[4] = {4, 5, 26, 25};

// ==== State Flags ====
bool flag1 = false;
bool flag2 = false;

// ==== Gate Angles ====
#define GATE_OPEN 90
#define GATE_CLOSED 0

// ==== LCD State Cache ====
String prevStates[4];

// ==== Slot Status Cache ====
String slotStatuses[4];

// ==== Timing ====
unsigned long lastFirebaseUpdate = 0;
const unsigned long firebaseInterval = 3000;

// ==== Setup ====
void setup() {
  Serial.begin(115200);

  lcd.init();
  lcd.backlight();
  gateServo.attach(SERVO_PIN);
  gateServo.write(GATE_CLOSED);

  for (int i = 0; i < 4; i++) {
    pinMode(slotPins[i], INPUT_PULLUP);
    slotStatuses[i] = "Available"; // initial state
  }

  pinMode(IR1, INPUT);
  pinMode(IR2, INPUT);

  WiFi.begin(ssid, password);
  Serial.print("Connecting to WiFi");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nWiFi connected.");

  // ==== Firebase Configuration ====
  config.api_key = API_KEY;
  config.database_url = DATABASE_URL;

  auth.user.email = "mahmud@gmail.com";
  auth.user.password = "12345678";

  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);

  Serial.println("Firebase setup complete.");

  lcd.setCursor(0, 0);
  lcd.print("  PARKING READY ");
  delay(2000);
  lcd.clear();
}

// ==== Main Loop ====
void loop() {
  handleGate();

  // Update slot statuses based on sensors
  bool statusChanged = updateSlotStatuses();

  // Update LCD
  updateDisplay();

  // Send updates to Firebase if changed or interval passed
  if (Firebase.ready() && (millis() - lastFirebaseUpdate > firebaseInterval || statusChanged)) {
    lastFirebaseUpdate = millis();
  }
}

// ==== Gate Control Logic ====
void handleGate() {
  // Car entering
  if (digitalRead(IR1) == LOW && !flag1) {
    if (isSlotAvailable()) {
      flag1 = true;
      if (!flag2) {
        // Mark first available slot as Booked
        setFirstAvailableSlotBooked();
        openGate();
      }
    } else {
      showFullMessage();
    }
  }

  // Car leaving
  if (digitalRead(IR2) == LOW && !flag2) {
    flag2 = true;
    if (!flag1) openGate();
  }

  if (flag1 && flag2) {
    delay(1000);
    closeGate();
    flag1 = flag2 = false;
  }
}

// ==== Slot Availability ====
bool isSlotAvailable() {
  for (int i = 0; i < 4; i++) {
    if (digitalRead(slotPins[i]) == HIGH) return true;
  }
  return false;
}

// ==== Mark First Available Slot as Booked ====
void setFirstAvailableSlotBooked() {
  for (int i = 0; i < 4; i++) {
    if (digitalRead(slotPins[i]) == HIGH) {
      slotStatuses[i] = "Booked";
      Serial.println("Slot " + String(i + 1) + " booked.");
      break;
    }
  }
}

// ==== Gate Control ====
void openGate() {
  gateServo.write(GATE_OPEN);
  delay(3000);
}

void closeGate() {
  gateServo.write(GATE_CLOSED);
}

// ==== Show Full Message ====
void showFullMessage() {
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("    SORRY 😞    ");
  lcd.setCursor(0, 1);
  lcd.print("  Parking Full  ");
  delay(2000);
  lcd.clear();
}

// ==== Update Slot Statuses ====
bool updateSlotStatuses() {
  bool changed = false;
  for (int i = 0; i < 4; i++) {
    bool empty = digitalRead(slotPins[i]) == HIGH;
    String newStatus;

    if (empty && slotStatuses[i] != "Booked") {
      newStatus = "Available";
    } else if (!empty) {
      newStatus = "Parked";
    } else {
      newStatus = slotStatuses[i]; // keep "Booked" until changed
    }

    if (newStatus != slotStatuses[i]) {
      slotStatuses[i] = newStatus;
      changed = true;
      Serial.println("Slot " + String(i + 1) + " status changed to " + newStatus);

      // Only update Firebase for the specific slot that changed
      updateFirebase(i); // Call the updateFirebase function with the specific slot index
    }
  }
  return changed;
}

// ==== LCD Display ====
void updateDisplay() {
  bool changed = false;
  String states[4];

  for (int i = 0; i < 4; i++) {
    states[i] = (digitalRead(slotPins[i]) == HIGH) ? "Empty" : "Full ";
    if (states[i] != prevStates[i]) changed = true;
  }

  if (changed) {
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("S1:" + states[0] + " S2:" + states[1]);
    lcd.setCursor(0, 1);
    lcd.print("S3:" + states[2] + " S4:" + states[3]);

    for (int i = 0; i < 4; i++) prevStates[i] = states[i];
  }
}

// ==== Firestore Updates ====
void updateFirebase(int slotIndex) {
  // Only update Firestore for the changed slot (i.e., slotIndex)
  Serial.println("Updating Firestore for Slot " + String(slotIndex + 1) + "...");

  String documentPath = "slots/slot" + String(slotIndex + 1);
  bool empty = digitalRead(slotPins[slotIndex]) == HIGH;
  String slotStatus = slotStatuses[slotIndex];

  String payload = 
    "{"
      "\"fields\":{"
        "\"isEmpty\":{\"booleanValue\":" + String(empty ? "true" : "false") + "},"
        "\"slotStatus\":{\"stringValue\":\"" + slotStatus + "\"}"
      "}"
    "}";

  if (Firebase.Firestore.patchDocument(&fbdo, FIREBASE_PROJECT_ID, "", documentPath.c_str(), payload.c_str(), "")) {
    Serial.println("Updated: " + documentPath + 
      " => isEmpty=" + String(empty ? "true" : "false") + 
      ", slotStatus=" + slotStatus);
  } else {
    Serial.print("Error updating ");
    Serial.print(documentPath);
    Serial.print(": ");
    Serial.println(fbdo.errorReason());
  }
}
