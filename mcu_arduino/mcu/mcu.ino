// Include Libraries
#include <Adafruit_NeoPixel.h>

#include <Adafruit_Sensor.h>
#include "DHT.h"

#include <RGBmatrixPanel.h>

#include <ThreeWire.h>
#include <RtcDS1302.h>

#ifdef __AVR__
#include <avr/power.h>
#endif

#include <IRremote.h>

// Define DHT11
#define DHT11_PIN 12
#define DHTTYPE DHT11
DHT dht(DHT11_PIN, DHTTYPE);

// Define RTC
ThreeWire myWire(4, 5, 2); // IO, SCLK, CE
RtcDS1302<ThreeWire> Rtc(myWire);

// Define RGB Led Matrix
#define CLK 11
#define OE   9
#define LAT 10
#define A   A0
#define B   A1
#define C   A2

// Define IRremote
int RECV_PIN = 22;
IRrecv irrecv(RECV_PIN);
decode_results results;

RGBmatrixPanel matrix(A, B, C, CLK, LAT, OE, true);

// Define WS2812
#define PIN       13
#define NUMPIXELS 24

Adafruit_NeoPixel pixels(NUMPIXELS, PIN, NEO_GRB + NEO_KHZ800);
#define DELAYVAL 500
int brightness = 51;
int old_brightness = 51;

unsigned long t;

void setup() {
  Serial.begin(9600);

  // Initialize DHT11
  dht.begin();
  dht.readHumidity();
  dht.readTemperature();

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

  // Initialize IRremote
  irrecv.enableIRIn(); // Start the receiver

  // Initialize LED Matrix
  matrix.begin();
  matrix.setTextSize(1);

  // Initialize WS2812
  pixels.begin();
  pixels.setBrightness(brightness);
  for (int i = 0; i < NUMPIXELS; i++) {
    pixels.setPixelColor(i, 255, 255, 255);
  }
  pixels.show();

  // Initalize Piezo
  pinMode(7, OUTPUT);
  analogWrite(7, 0);

  Serial.println("Arduino Ready!!");
}

int old_mode = 1;
int mode = 1;
boolean timer_flag = false;
boolean sleep_flag = false;

RtcDateTime start = Rtc.GetDateTime();
RtcDateTime pause = Rtc.GetDateTime();
RtcDateTime end = Rtc.GetDateTime();

void print_brightness() {
  t = millis();
  pixels.setBrightness(brightness);
  pixels.show();
}

void loop() {
  if (irrecv.decode(&results)) {
    if (results.value == 0xFF629D) {
      sleep_flag = sleep_flag ? false : true;
      if (!sleep_flag) {
        mode = old_mode;
        brightness = old_brightness;
        pixels.setBrightness(brightness);
        pixels.show();
      }
      else {
        old_mode = mode;
        mode = 0;
        old_brightness = brightness;
        brightness = 1;
        pixels.setBrightness(brightness);
        pixels.show();
        matrix.fillScreen(0);
      }
    }
    if (results.value == 0xFF30CF) {
      mode = 1;
    }
    else if (results.value == 0xFF18E7) {
      mode = 2;
    }
    else if (results.value == 0xFF7A85) {
      mode = 3;
    }
    else if (results.value == 0xFFC23D) {
      timer_flag = timer_flag ? false : true;
      if (!timer_flag) {
        RtcDateTime now = Rtc.GetDateTime();

        Serial.print("S,");
        Serial.print(start.Year());
        Serial.print("-");
        Serial.print(start.Month());
        Serial.print("-");
        Serial.print(start.Day());
        Serial.print(" ");
        Serial.print(start.Hour());
        Serial.print(":");
        Serial.print(start.Minute());
        Serial.print(":");
        Serial.print(start.Second());
        Serial.print(",");
        Serial.print(now.Year());
        Serial.print("-");
        Serial.print(now.Month());
        Serial.print("-");
        Serial.print(now.Day());
        Serial.print(" ");
        Serial.print(now.Hour());
        Serial.print(":");
        Serial.print(now.Minute());
        Serial.print(":");
        Serial.print(now.Second());
      }
      mode = 2;
    }
    else if (results.value == 0xFFE01F) {
      brightness -= 25;
      if (brightness < 1) brightness = 1;
      mode = 4;
      print_brightness();
    }
    else if (results.value == 0xFFA857) {
      brightness += 25;
      if (brightness > 226) brightness = 226;
      mode = 4;
      print_brightness();
    }
    irrecv.resume();
  }

  if (Serial.available()) {
    int cmd = Serial.parseInt();

    if (cmd == 1) {
      int yr = Serial.parseInt();
      int mon = Serial.parseInt();
      int day = Serial.parseInt();
      int hr = Serial.parseInt();
      int mn = Serial.parseInt();
      int sec = Serial.parseInt();
      Rtc.SetDateTime(RtcDateTime(yr, mon, day, hr, mn, sec));
    }
    else if (cmd == 4) {
      if (!timer_flag) {
        timer_flag = timer_flag ? false : true;
      }
      mode = 2;
    }
    else if (cmd == 5) {
      brightness -= 25;
      if (brightness < 1) brightness = 1;
      mode = 4;
      print_brightness();
    }
    else if (cmd == 6) {
      brightness += 25;
      if (brightness > 226) brightness = 226;
      mode = 4;
      print_brightness();
    }
    else if (cmd == 7) {
      if (timer_flag) {
        timer_flag = timer_flag ? false : true;
        RtcDateTime now = Rtc.GetDateTime();

        Serial.print("S,");
        Serial.print(start.Year());
        Serial.print("-");
        Serial.print(start.Month());
        Serial.print("-");
        Serial.print(start.Day());
        Serial.print(" ");
        Serial.print(start.Hour());
        Serial.print(":");
        Serial.print(start.Minute());
        Serial.print(":");
        Serial.print(start.Second());
        Serial.print(",");
        Serial.print(now.Year());
        Serial.print("-");
        Serial.print(now.Month());
        Serial.print("-");
        Serial.print(now.Day());
        Serial.print(" ");
        Serial.print(now.Hour());
        Serial.print(":");
        Serial.print(now.Minute());
        Serial.print(":");
        Serial.print(now.Second());
      }
      mode = 2;
    }
    else if (cmd == 8) {
      mode = 1;
    }
    else if (cmd == 9) {
      mode = 2;
    }
    else if (cmd == 10) {
      mode = 3;
    }
    else if (cmd == 16) {
      sleep_flag = sleep_flag ? false : true;
      if (!sleep_flag) {
        mode = old_mode;
        brightness = old_brightness;
        pixels.setBrightness(brightness);
        pixels.show();
      }
      else {
        old_mode = mode;
        mode = 0;
        old_brightness = brightness;
        brightness = 1;
        pixels.setBrightness(brightness);
        pixels.show();
        matrix.fillScreen(0);
      }
    }
    else if (cmd == 111) {
      t = millis();
      mode = 5;
    }
    Serial.read();
  }
  if (mode == 1) {
    matrix.fillScreen(0);
    matrix.setCursor(1, 1);
    printTime(Rtc.GetDateTime());
  }
  else if (mode == 2) {
    matrix.fillScreen(0);
    matrix.setCursor(1, 1);
    matrix.print("Timer");
    matrix.setCursor(1, 9);
    if (timer_flag == true) {
      printTimer(Rtc.GetDateTime() - start);
    }
    else {
      start = Rtc.GetDateTime();
      matrix.print("00:00");
    }
  }
  else if (mode == 3) {
    float hud = dht.readHumidity();
    float temp = dht.readTemperature();
    if (!isnan(hud) || !isnan(temp)) {
      matrix.fillScreen(0);
      matrix.setCursor(1, 1);
      matrix.print(temp);
      matrix.setCursor(1, 9);
      matrix.print(hud);
    }
    delay(20);
  }
  else if (mode == 4) {
    matrix.fillScreen(0);
    matrix.setCursor(1, 0);
    matrix.print("Brigh");
    matrix.setCursor(1, 9);
    matrix.print("t: ");
    matrix.print((brightness / 25) % 10 + 1);
    if (millis() - t > 5000) {
      mode = 1;
    }
  }
  else if (mode == 5) {
    matrix.fillScreen(0);
    matrix.setCursor(1, 1);
    matrix.print("Alarm");
    matrix.setCursor(1, 9);
    matrix.print("!!!!!");
    if (millis() - t > 15000) {
      mode = 1;
    }
  }

  matrix.swapBuffers(true);
}

#define countof(a) (sizeof(a) / sizeof(a[0]))

void printTime(const RtcDateTime & dt)
{
  char datestring[20];

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

void printTimer(const RtcDateTime & dt)
{
  char datestring[20];
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
