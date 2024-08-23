#include <ESP8266WiFi.h>
#include <FirebaseESP8266.h>
#include <WiFiManager.h>          // Tambahkan pustaka WiFiManager
#include <Wire.h>
#include <LiquidCrystal_I2C.h>
#include <time.h>                 // Tambahkan pustaka time.h untuk NTP

// Definisikan pin
#define BUTTON_PIN D3   // Pin untuk button
#define BUZZER_PIN D5   // Pin untuk buzzer

// Ganti dengan informasi Firebase Anda
#define FIREBASE_HOST "esolusindosecurity-default-rtdb.firebaseio.com"  // Host Firebase Database tanpa 'https://'
#define FIREBASE_AUTH "05xW10cmdxUBIBwXw4i5edLZy06MbpMRelL5QGf2"  // Database Secret

// Firebase objects
FirebaseData firebaseData;
FirebaseConfig firebaseConfig;
FirebaseAuth firebaseAuth;

// Inisialisasi LCD I2C
LiquidCrystal_I2C lcd(0x27, 16, 2);  // Alamat I2C 0x27, 16 karakter, 2 baris

void setup() {
  // Inisialisasi pin
  pinMode(BUTTON_PIN, INPUT_PULLUP); // Button dengan pull-up internal
  pinMode(BUZZER_PIN, OUTPUT);      // Buzzer sebagai output

  // Mulai serial monitor
  Serial.begin(115200);
  Serial.println("Memulai WiFi Manager...");

  // Inisialisasi WiFiManager
  WiFiManager wifiManager;
  wifiManager.autoConnect("ESP8266_AP");  // Membuat AP dengan nama "ESP8266_AP"

  Serial.println("Terhubung ke WiFi.");

  // Konfigurasi Firebase
  firebaseConfig.host = FIREBASE_HOST;
  firebaseConfig.signer.tokens.legacy_token = FIREBASE_AUTH;  // Gunakan Database Secret sebagai Legacy Token

  // Mulai Firebase
  Firebase.begin(&firebaseConfig, &firebaseAuth);

  // Set timezone dan sinkronisasi waktu dengan NTP
  configTime(7 * 3600, 0, "pool.ntp.org", "time.nist.gov");  // UTC+7 untuk Waktu Indonesia Barat (WIB)

  // Inisialisasi LCD
  lcd.init();
  lcd.backlight();
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("Security System");
  lcd.setCursor(5, 1);
  lcd.print("Ready");
}

void loop() {
  // Periksa status koneksi WiFi
  if (WiFi.status() == WL_CONNECTED) {
    // Baca status button
    bool currentButtonState = digitalRead(BUTTON_PIN);

    // Jika button ditekan (status LOW karena pull-up internal) dan button baru saja ditekan
    static bool lastButtonState = HIGH;
    if (currentButtonState == LOW && lastButtonState == HIGH) {
      // Ubah status "speaker" di Firebase
      bool speakerState = !firebaseData.boolData(); // Dapatkan status speaker saat ini dari Firebase

      // Kirim status yang diperbarui ke Firebase
      if (Firebase.setBool(firebaseData, "/speaker", speakerState)) {
        Serial.print("Status speaker diperbarui: ");
        Serial.println(speakerState ? "true" : "false");
      } else {
        Serial.print("Gagal memperbarui status speaker: ");
        Serial.println(firebaseData.errorReason());
      }
    }

    // Update status button sebelumnya
    lastButtonState = currentButtonState;

    // Baca nilai "speaker" dari Firebase dan kontrol buzzer serta LCD
    if (Firebase.getBool(firebaseData, "/speaker")) {
      bool speakerState = firebaseData.boolData();

      // Jika nilai "speaker" adalah true, nyalakan buzzer dan tampilkan "Alarm ON" di LCD
      if (speakerState) {
        digitalWrite(BUZZER_PIN, HIGH);
        lcd.clear();
        lcd.setCursor(0, 0);
        lcd.print("Alarm ON");
        Serial.println("Firebase: speaker true. Buzzer dinyalakan.");
      } else {
        digitalWrite(BUZZER_PIN, LOW);
        lcd.clear();
        lcd.setCursor(0, 1);
        lcd.print("Alarm OFF");
        Serial.println("Firebase: speaker false. Buzzer dimatikan.");
      }
    } else {
      Serial.print("Gagal mendapatkan data dari Firebase: ");
      Serial.println(firebaseData.errorReason());
    }

    // Dapatkan waktu sekarang
    time_t now = time(nullptr);
    struct tm* timeinfo = localtime(&now);

    // Tampilkan waktu pada LCD (HH:MM:SS)
    lcd.setCursor(0, 0);
    lcd.printf("%02d:%02d:%02d", timeinfo->tm_hour, timeinfo->tm_min, timeinfo->tm_sec);

    // Tampilkan status koneksi WiFi
    Serial.print("IP Address: ");
    Serial.println(WiFi.localIP());
  } else {
    // Jika tidak terhubung ke WiFi, matikan buzzer dan tampilkan pesan error di LCD
    digitalWrite(BUZZER_PIN, LOW);
    lcd.clear();
    lcd.setCursor(0, 1);
    lcd.print("WiFi Error");
    Serial.println("Gagal terhubung ke WiFi.");
  }

  // Tunggu sejenak sebelum mencoba lagi
  delay(1000);  // Update setiap 1 detik
}