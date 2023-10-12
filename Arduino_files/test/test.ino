//setup simple arduino example to blink an led
// 1. define the pin number for the led
// 2. setup the pin as an output
// 3. loop forever
// 4. turn the led on
// 5. wait for 1 second
// 6. turn the led off
// 7. wait for 1 second
// 8. repeat

// 1. define the pin number for the led
int ledPin = 13;

// 2. setup the pin as an output
void setup() {
  pinMode(ledPin, OUTPUT);
}

// 3. loop forever
void loop() {
  // 4. turn the led on
  digitalWrite(ledPin, HIGH);
  // 5. wait for 1 second
  delay(1000);
  // 6. turn the led off
  digitalWrite(ledPin, LOW);
  // 7. wait for 1 second
  delay(1000);
  // 8. repeat
}