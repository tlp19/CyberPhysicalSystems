#include <EEPROM.h>

#include <Ultrasonic.h>

// These constants won't change. They're used to give names to the pins used:
const int analogInPin = A0;  // Analog input pin that the potentiometer is attached to
const int analogOutPin = 5;  // Analog output pin that the LED is attached to
const int analogOutPin2 = 6;  // Analog output pin that the LED is attached to2

// constants won't change. They're used here to set pin numbers:
const int buttonPin = 2;  // the number of the pushbutton pin
const int ledPin = 13;    // the number of the LED pin

// variables will change:
int buttonState = 0;  // variable for reading the pushbutton status
int sensorValue = 0;  // value read from the pot
int outputValue = 0;  // value output to the PWM (analog out)
int outputValue2 = 0;  // value output to the PWM (analog out)
int buttonPush = 0; // find when the button is pushed
int buttonValue = 0;


void setup() {
  // initialize serial communications at 9600 bps:
  Serial.begin(9600);
  // initialize the pushbutton pin as an input:
  pinMode(buttonPin, INPUT_PULLUP);
}

void loop() {

  // read the state of the pushbutton value:
  buttonState = digitalRead(buttonPin);

  if(buttonState==LOW && buttonPush==LOW){
    buttonPush = HIGH;
  } else {
    buttonPush = LOW;
  }

  if (buttonPush == HIGH) {
    buttonValue = 1 - buttonValue;
  }

  // check if the pushbutton was pressed
  if (buttonValue == HIGH) {
    // read the analog in value:
    sensorValue = analogRead(analogInPin);
    // map it to the range of the analog out:
    outputValue = map(sensorValue, 0, 1023, 0, 255);
    outputValue2 = 255 - outputValue;
  } else {
    // turn LED off:
    outputValue = 0;
    outputValue2 = 0;
  }

  // change the analog out value:
  analogWrite(analogOutPin, outputValue);
  analogWrite(analogOutPin2, outputValue2);

  // print the results to the Serial Monitor:
  Serial.print("buttonState = ");
  Serial.print(buttonState);
  Serial.print("\t buttonPush = ");
  Serial.print(buttonPush);
  Serial.print("\t buttonValue = ");
  Serial.print(buttonValue);
  Serial.print("\t sensor = ");
  Serial.print(sensorValue);
  Serial.print("\t output = ");
  Serial.println(outputValue);

  // wait 2 milliseconds before the next loop for the analog-to-digital
  // converter to settle after the last reading:
  delay(50);
}