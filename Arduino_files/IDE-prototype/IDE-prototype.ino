int ledPin = 13; // LED connected to digital pin 13

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