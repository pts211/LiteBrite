unsigned long keyPrevMillis = 0;
const unsigned long keySampleIntervalMs = 25;
byte longKeyPressCountMax = 80;    // 80 * 25 = 2000 ms
byte mediumKeyPressCountMin = 20;    // 20 * 25 = 500 ms
byte KeyPressCount = 0;

byte prevKeyState = HIGH;         // button is active low
const byte keyPin = 2;            // button is connected to pin 2 and GND

void checkConfigButton()
{
  //boolean configBttn = digitalRead(configPin);

  //Serial.println(configBttn);

  // key management section
  if (millis() - keyPrevMillis >= keySampleIntervalMs) {
    keyPrevMillis = millis();

    byte currKeyState = digitalRead(configPin);

    if ((prevKeyState == HIGH) && (currKeyState == LOW)) {
      keyPress();
    }
    else if ((prevKeyState == LOW) && (currKeyState == HIGH)) {
      keyRelease();
    }
    else if (currKeyState == LOW) {
      KeyPressCount++;
      if (KeyPressCount >= longKeyPressCountMax) {
        longKeyPress();
      }
    }

    prevKeyState = currKeyState;
  }

}


// called when button is kept pressed for less than .5 seconds
bool shortFiredOnce = false;
void shortKeyPress() {
    if(!shortFiredOnce){
      Serial.println("short");
      printButtonMapping();
      shortFiredOnce = true;
    }
}


// called when button is kept pressed for more than 2 seconds
void mediumKeyPress() {
    Serial.println("medium");
}


bool firedOnce = false;
// called when button is kept pressed for 2 seconds or more
void longKeyPress() {
    if(!isTraining && !firedOnce){
      Serial.println("long");
      isTraining = true;
      firedOnce = true;
    }
}


// called when key goes from not pressed to pressed
void keyPress() {
    Serial.println("key press");
    KeyPressCount = 0;
}

// called when key goes from pressed to not pressed
void keyRelease() {
    Serial.println("key release");
    
    if (KeyPressCount < longKeyPressCountMax && KeyPressCount >= mediumKeyPressCountMin) {
        mediumKeyPress();
    }
    else {
      if (KeyPressCount < mediumKeyPressCountMin) {
        shortKeyPress();
      }
    }
    firedOnce = false;
    shortFiredOnce = false;
}
