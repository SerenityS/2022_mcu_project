// Include DHT11
#include <Adafruit_Sensor.h>
#include "DHT.h"

// Include DS1302
#include <ThreeWire.h>
#include <RtcDS1302.h>

// Include RGB Matrix
#include <RGBmatrixPanel.h>

// Include IRremote
#include <IRremote.h>

// Include WS2812
#include <Adafruit_NeoPixel.h>

#ifdef __AVR__
#include <avr/power.h>
#endif

// Define DHT11
#define DHT11_PIN 12
#define DHTTYPE DHT11
DHT dht(DHT11_PIN, DHTTYPE);
float temp;
float hud;

// Define IRremote
int RECV_PIN = 22;
IRrecv irrecv(RECV_PIN);
decode_results results;

// Define RGB Led Matrix
#define CLK 11
#define OE   9
#define LAT 10
#define A   A0
#define B   A1
#define C   A2

RGBmatrixPanel matrix(A, B, C, CLK, LAT, OE, true);

#define countof(a) (sizeof(a) / sizeof(a[0]))

// Define RTC
ThreeWire myWire(4, 5, 2); // IO, SCLK, CE
RtcDS1302<ThreeWire> Rtc(myWire);

// Define WS2812
#define PIN       13
#define NUMPIXELS 24

Adafruit_NeoPixel pixels(NUMPIXELS, PIN, NEO_GRB + NEO_KHZ800);

int brightness = 125;
int old_brightness = 125;

int screen = 1;

void setup() {
  // Begin Serial Commnication
  Serial.begin(9600);

  // Initialize DHT11
  dht.begin();
  hud = dht.readHumidity();
  temp = dht.readTemperature();

  // Initialize IRremote
  irrecv.enableIRIn();

  // Initalize Piezo
  pinMode(7, OUTPUT);
  analogWrite(7, 0);

  // Initialize RGB LED Matrix
  matrix.begin();
  matrix.setTextSize(1);

  // Initialize RTC
  Rtc.Begin();
  if (Rtc.GetIsWriteProtected())
  {
    Rtc.SetIsWriteProtected(false);
  }
  if (!Rtc.GetIsRunning())
  {
    Rtc.SetIsRunning(true);
  }

  // Initialize WS2812
  pixels.begin();
  pixels.setBrightness(brightness);
  for (int i = 0; i < NUMPIXELS; i++) {
    pixels.setPixelColor(i, 255, 255, 255);
  }
  pixels.show();

  // All Modules are READY
  Serial.println("Arduino Ready!!");
}

// Declare Global Variable
int old_screen = 1;

boolean fever_flag = false;
boolean timer_flag = false;
boolean sleep_flag = false;

unsigned long t;

RtcDateTime start = Rtc.GetDateTime();
RtcDateTime end = Rtc.GetDateTime();

void loop() {
  // Disable Piezo
  analogWrite(7, 0);

  // Change LED Color when study 10sec for test
  if (Rtc.GetDateTime() - start >= 10 && !fever_flag && !sleep_flag && timer_flag) {
    fever_flag = true;
    for (int i = 0; i < 24; i++) {
      pixels.setPixelColor(i, 255, 0, 0);
    }
    pixels.show();
  }

  // Get Remote Controller
  if (irrecv.decode(&results)) {

    // Sleep Button(CH)
    if (results.value == 0xFF629D) {
      doSleep();
    }
    // RW Button
    else if (results.value == 0xFF22DD) {
      switch (screen) {
        case 1:
          screen = 3;
          break;
        case 2:
          screen = 1;
          break;
        case 3:
          screen = 2;
          break;
        default:
          screen = 1;
          break;
      }
    }
    // FF Button
    else if (results.value == 0xFF02FD) {
      switch (screen) {
        case 1:
          screen = 2;
          break;
        case 2:
          screen = 3;
          break;
        case 3:
          screen = 1;
          break;
        default:
          screen = 1;
          break;
      }
    }
    // Play/Pause Button
    else if (results.value == 0xFFC23D) {
      timer_flag = timer_flag ? false : true;
      if (!timer_flag) {
        fever_flag = false;
        for (int i = 0; i < 24; i++) {
          pixels.setPixelColor(i, 255, 255, 255);
        }
        pixels.show();
        sendStudyData();
      }
      else {
        start = Rtc.GetDateTime();
      }
      screen = 2;
    }
    // - Button
    else if (results.value == 0xFFE01F) {
      brightness -= 25;
      if (brightness < 25) brightness = 25;
      screen = 4;
      set_brightness();
    }
    // + Button
    else if (results.value == 0xFFA857) {
      brightness += 25;
      if (brightness > 255) brightness = 255;
      screen = 4;
      set_brightness();
    }
    // Button 1
    else if (results.value == 0xFF30CF) {
      screen = 1;
    }
    // Button 2
    else if (results.value == 0xFF18E7) {
      screen = 2;
    }
    // Button 3
    else if (results.value == 0xFF7A85) {
      screen = 3;
    }
    irrecv.resume();
  }

  // Serial Commnunication From Client(PC/Android)
  if (Serial.available()) {

    // Get Command
    int cmd = Serial.parseInt();

    // Update RTC Clock
    if (cmd == 1) {
      int yr = Serial.parseInt();
      int mon = Serial.parseInt();
      int day = Serial.parseInt();
      int hr = Serial.parseInt();
      int mn = Serial.parseInt();
      int sec = Serial.parseInt();
      Rtc.SetDateTime(RtcDateTime(yr, mon, day, hr, mn, sec));
    }
    // RW Button
    else if (cmd == 2) {
      switch (screen) {
        case 1:
          screen = 3;
          break;
        case 2:
          screen = 1;
          break;
        case 3:
          screen = 2;
          break;
        default:
          screen = 1;
          break;
      }
    }
    // FF Button
    else if (cmd == 3) {
      switch (screen) {
        case 1:
          screen = 2;
          break;
        case 2:
          screen = 3;
          break;
        case 3:
          screen = 1;
          break;
        default:
          screen = 1;
          break;
      }
    }
    // Play Button
    else if (cmd == 4) {
      if (!timer_flag) {
        timer_flag = timer_flag ? false : true;
      }
      else {
        start = Rtc.GetDateTime();
      }
      screen = 2;
    }
    // - Button
    else if (cmd == 5) {
      brightness -= 25;
      if (brightness < 1) brightness = 1;
      screen = 4;
      set_brightness();
    }
    // + Button
    else if (cmd == 6) {
      brightness += 25;
      if (brightness > 226) brightness = 226;
      screen = 4;
      set_brightness();
    }
    // Pause Button
    else if (cmd == 7) {
      if (timer_flag) {
        fever_flag = false;
        timer_flag = timer_flag ? false : true;
        for (int i = 0; i < 24; i++) {
          pixels.setPixelColor(i, 255, 255, 255);
        }
        pixels.show();
        sendStudyData();
      }
      screen = 2;
    }
    // Button 1
    else if (cmd == 8) {
      screen = 1;
    }
    // Button 2
    else if (cmd == 9) {
      screen = 2;
    }
    // Button 3
    else if (cmd == 10) {
      screen = 3;
    }
    // Sleep Button
    else if (cmd == 16) {
      doSleep();
    }
    // Alarm Function(Not Button)
    else if (cmd == 17) {
      t = millis();
      screen = 5;
    }
    // Sleep Alarm Function(Not Button)
    else if (cmd == 18) {
      doSleep();
    }
  }

  // Screens

  // Clock Screen
  if (screen == 1) {
    checkSleep();
    printTime();
  }
  //Timer Screen
  else if (screen == 2) {
    checkSleep();
    matrix.fillScreen(0);
    matrix.setCursor(1, 1);
    matrix.print("Timer");
    matrix.setCursor(1, 9);
    if (timer_flag == true) {
      printTimer();
    }
    else {
      start = Rtc.GetDateTime();
      matrix.print("00:00");
    }
  }
  // Temp/Hud Screen
  else if (screen == 3) {
    checkSleep();
    if (!isnan(hud) || !isnan(temp)) {
      matrix.fillScreen(0);
      matrix.setCursor(1, 1);
      matrix.print(temp);
      matrix.setCursor(1, 9);
      matrix.print(hud);
    }
    hud = dht.readHumidity();
    temp = dht.readTemperature();
    delay(20);
  }
  // Brightness Screen
  else if (screen == 4) {
    checkSleep();
    matrix.fillScreen(0);
    matrix.setCursor(1, 0);
    matrix.print("Brigh");
    matrix.setCursor(1, 9);
    matrix.print("t: ");
    matrix.print((brightness / 25) % 11);
    if (millis() - t > 5000) {
      screen = 1;
    }
  }
  // Alarm Screen
  else if (screen == 5) {
    checkSleep();
    analogWrite(7, 130);
    matrix.fillScreen(0);
    matrix.setCursor(1, 1);
    matrix.print("Alarm");
    matrix.setCursor(1, 9);
    matrix.print("!!!!!");
    if (millis() - t > 5000) {
      analogWrite(7, 0);
      screen = 1;
    }
  }
  matrix.swapBuffers(true);
}

// Functions

void checkSleep() {
  if (sleep_flag) {
    brightness = old_brightness;
    pixels.setBrightness(brightness);
    pixels.show();
    sleep_flag = false;
  }
}

void doSleep() {
  sleep_flag = sleep_flag ? false : true;
  if (!sleep_flag) {
    screen = old_screen;
    brightness = old_brightness;
    pixels.setBrightness(brightness);
    pixels.show();
  }
  else {
    fever_flag = false;
    old_screen = screen;
    screen = 0;
    old_brightness = brightness;
    brightness = 1;
    pixels.setBrightness(brightness);
    for (int i = 0; i < 24; i++) {
      pixels.setPixelColor(i, 255, 255, 255);
    }
    pixels.show();
    matrix.fillScreen(0);
  }
}

// Send Study data to Server
void sendStudyData() {
  char studyString[50];

  RtcDateTime now = Rtc.GetDateTime();

  snprintf_P(studyString,
             countof(studyString),
             PSTR("S,%04u-%02u-%02u %02u:%02u:%02u,%04u-%02u-%02u %02u:%02u:%02u"),
             start.Year(),
             start.Month(),
             start.Day(),
             start.Hour(),
             start.Minute(),
             start.Second(),
             now.Year(),
             now.Month(),
             now.Day(),
             now.Hour(),
             now.Minute(),
             now.Second()
            );
  Serial.println(studyString);
}

// Set Brightness
void set_brightness() {
  t = millis();
  pixels.setBrightness(brightness);
  pixels.show();
}

// Print Time with blinking
void printTime()
{
  char datestring[20];

  RtcDateTime dt = Rtc.GetDateTime();

  matrix.fillScreen(0);
  matrix.setCursor(1, 1);
  snprintf_P(datestring,
             countof(datestring),
             PSTR("%02u/%02u"),
             dt.Month(),
             dt.Day()
            );
  matrix.print(datestring);

  matrix.setCursor(1, 9);
  if (dt % 2) {
    snprintf_P(datestring,
               countof(datestring),
               PSTR("%02u %02u"),
               dt.Hour(),
               dt.Minute()
              );
  }
  else {
    snprintf_P(datestring,
               countof(datestring),
               PSTR("%02u:%02u"),
               dt.Hour(),
               dt.Minute()
              );
  }
  matrix.print(datestring);
}

// Print Timer with blinking
void printTimer()
{
  char datestring[20];

  RtcDateTime dt = Rtc.GetDateTime() - start;

  int mn = dt / 60;

  if (dt % 2) {
    snprintf_P(datestring,
               countof(datestring),
               PSTR("%02u %02u"),
               mn,
               dt.Second()
              );
  }
  else {
    snprintf_P(datestring,
               countof(datestring),
               PSTR("%02u:%02u"),
               mn,
               dt.Second()
              );
  }
  matrix.print(datestring);
}
