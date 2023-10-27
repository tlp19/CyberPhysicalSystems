#include <Arduino.h>

int ledRedPin = 2;
int ledYellowPin = 4;
int ledGreenPin = 6;


void setup() {
    // Setup the button pin to use the internal pull-up resistor
    pinMode(ledRedPin, OUTPUT);
    pinMode(ledYellowPin, OUTPUT);
    pinMode(ledGreenPin, OUTPUT);
    Serial.begin(9600);
}


void loop() {

    // Decode message received from Serial
    if(Serial.available()){
        // Read a String up to the delimiter character '_'
        String receivedString = Serial.readStringUntil('_');

        // Check what the character is, and decide what to do accordingly
        if(receivedString == "plastic"){
            // Turn on the red LED
            digitalWrite(ledRedPin, HIGH);
            digitalWrite(ledYellowPin, LOW);
            digitalWrite(ledGreenPin, LOW);

        } else if(receivedString == "metal"){
            // Turn on the yellow LED
            digitalWrite(ledRedPin, LOW);
            digitalWrite(ledYellowPin, HIGH);
            digitalWrite(ledGreenPin, LOW);

        } else if(receivedString == "wood"){
            // Turn on the green LED
            digitalWrite(ledRedPin, LOW);
            digitalWrite(ledYellowPin, LOW);
            digitalWrite(ledGreenPin, HIGH);
        }
    }

    // Delay before next loop (in milliseconds)
    delay(10);
}