#include <Arduino.h>
#include <PCA9685.h>
#include <Wire.h>

ServoDriver servo;

int fwdServoPin = 8;
int clawServoPin = 7;
int rotServoPin = 6;
int upServoPin = 5;

int buttonPin = 2;
int prevButtonValue = HIGH;

int potentiometer1Pin = A0;
int potentiometer2Pin = A1;
int potentiometer3Pin = A2;


void setup() {
    // Setup the button pin to use the internal pull-up resistor
    pinMode(buttonPin, INPUT_PULLUP);
    Wire.begin();
    Serial.begin(9600);
    servo.init(0x7f);
    servo.setAngle(upServoPin, 0);
    servo.setAngle(fwdServoPin, 110);
    servo.setAngle(rotServoPin, 90);
    servo.setAngle(clawServoPin, 0);
}


void loop() {
    
    // Read potentiometer values
    int knob1Value = analogRead(potentiometer1Pin);
    int knob2Value = analogRead(potentiometer2Pin);
    int knob3Value = analogRead(potentiometer3Pin);
    
    // Read button value
    int buttonValue = digitalRead(buttonPin);

    Serial.println("---------------------");
    Serial.println("Button: " + String(buttonValue));
    Serial.println("Knob 1: " + String(knob1Value));
    Serial.println("Knob 2: " + String(knob2Value));
    Serial.println("Knob 3: " + String(knob3Value));

    // Calculate servo angles
    int upAngle = knob1Value * 80.0/1023.0;
    int fwdAngle = 110 - (knob2Value * 110.0/1023.0);
    int rotAngle = 180 - (knob3Value * 180.0/1023.0);

    Serial.println("Angle up: " + String(upAngle));
    Serial.println("Angle forward: " + String(fwdAngle));
    Serial.println("Angle rotation: " + String(rotAngle));
    
    // Set servo angles
    servo.setAngle(upServoPin, upAngle);
    servo.setAngle(fwdServoPin, fwdAngle);
    servo.setAngle(rotServoPin, rotAngle);

    // Open or close the claw
    if ((buttonValue != prevButtonValue) && (buttonValue == LOW)) {
        // Serial.println("Button pushed");
        servo.setAngle(clawServoPin, 110);
    } else if ((buttonValue != prevButtonValue) && (buttonValue == HIGH)) {
        // Serial.println("Button released");
        servo.setAngle(clawServoPin, 0);
    }

    // Update memory variables
    prevButtonValue = buttonValue;

    // Delay before next loop (in milliseconds)
    delay(5);
}