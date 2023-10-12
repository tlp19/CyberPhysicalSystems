#include <Arduino.h>
#line 1 "C:\\Users\\tangu\\source\\IDE\\CyberPhysicalSystems\\IDE-prototype\\IDE-prototype.ino"
int ledPin = 13; // LED connected to digital pin 13

#line 3 "C:\\Users\\tangu\\source\\IDE\\CyberPhysicalSystems\\IDE-prototype\\IDE-prototype.ino"
void setup();
#line 11 "C:\\Users\\tangu\\source\\IDE\\CyberPhysicalSystems\\IDE-prototype\\IDE-prototype.ino"
void loop();
#line 3 "C:\\Users\\tangu\\source\\IDE\\CyberPhysicalSystems\\IDE-prototype\\IDE-prototype.ino"
void setup() {
  // initialize digital pin LED_BUILTIN as an output.
  pinMode(ledPin, OUTPUT);
  delay(1000);   
  digitalWrite(ledPin, 255);        // turn the LED on (HIGH is the voltage level)
}

// the loop function runs over and over again forever
void loop() {
  delay(1000);                      // wait for a second
  digitalWrite(ledPin, 255);
  delay(1000);
  digitalWrite(ledPin, 0);
}
