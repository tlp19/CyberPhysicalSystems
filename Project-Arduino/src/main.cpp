#include <Arduino.h>
#include <PCA9685.h>
#include <Wire.h>

int ledRedPin = 2;
int ledYellowPin = 3;
int ledGreenPin = 4;

ServoDriver servo;

int servoSmallLeft = 5;
int servoSmallRight = 6;
int servoBigLeft = 8;
int servoBigRight = 7;

int servoPins[4] = {servoSmallLeft, servoBigLeft, servoSmallRight, servoBigRight};
int direction[4] = {-1, -1, 1, 1};

void stopAllServos() {
    servo.setAngle(servoSmallLeft, 85);
    servo.setAngle(servoSmallRight, 85);
    servo.setAngle(servoBigLeft, 88);
    servo.setAngle(servoBigRight, 88);
}

void turn(int id, int speed) {
    int angle = 90.0 + (float)speed * 90.0 / 100.0;
    servo.setAngle(servoPins[id-1], angle);
}

void scheduleTurns(int nbOfServos, int ids[], int speeds[], int length, int spacing) {
    for(int i = 0; i < nbOfServos; i++) {
        turn(ids[i], speeds[i] * direction[ids[i]-1]);
        delay(spacing);
    }
    delay(length);
    for(int i = 0; i < nbOfServos; i++) {
        turn(ids[i], 0);
        delay(spacing);
    }
}


void setup() {
    pinMode(ledRedPin, OUTPUT);
    pinMode(ledYellowPin, OUTPUT);
    pinMode(ledGreenPin, OUTPUT);
    Wire.begin();
    Serial.begin(9600);
    servo.init(0x7f);
    servo.setServoPulseRange(900, 2100);
    // Turn off all servos from before 
    stopAllServos();

    // turn(4, 20);
    // delay(5000);
    // turn(4, 30);
    // delay(100);
    // turn(4, 40);

    // turn(2, -30);
    // delay(5000);
    // turn(2, -35);
    // delay(3000);
    // turn(2, -40);

    // turn(2, -32);
    // delay(5000);
    // turn(3, 10);
    // delay(5000);
    // turn(4, 20);

    // turn(3, 11);
    // delay(1500);
    // turn(1, -22);

    // delay(5300-1500);
    // turn(3, 0);
    // delay(1500);
    // stopAllServos();
}

// 1: 20 and above
// 2: 32 slow 40 fast 45 super fast
// 3: 10 slow 20 fast 30 super fast
// 4: 15 slow 30 fast 40 super fast


void loop() {

    // Decode message received from Serial
    if(Serial.available()){
        // Read one character at a time
        String received = Serial.readStringUntil('_');
        received.trim();

        if(received == "wood") {

          // Turn on the green LED
          digitalWrite(ledRedPin, LOW);
          digitalWrite(ledYellowPin, LOW);
          digitalWrite(ledGreenPin, HIGH);

          // Drive the motors
          int servoSchedule[2] = {3, 1}; 
          int speedSchedule[2] = {11, 22};
          scheduleTurns(2, servoSchedule, speedSchedule, 3800, 1500);
          stopAllServos();
          delay(3000);

        } else if(received == "metal") {

          // Turn on the yellow LED
          digitalWrite(ledRedPin, LOW);
          digitalWrite(ledYellowPin, HIGH);
          digitalWrite(ledGreenPin, LOW);

          // Drive the motors
          int nbOfServos = 4;
          int servoSchedule[nbOfServos] = {4, 3, 2, 1}; 
          int speedSchedule[nbOfServos] = {26, 13, 43, 25};
          scheduleTurns(nbOfServos, servoSchedule, speedSchedule, 1000, 900);
          stopAllServos();
          delay(3000);

        } else if(received == "plastic") {

          // Turn on the red LED
          digitalWrite(ledRedPin, HIGH);
          digitalWrite(ledYellowPin, LOW);
          digitalWrite(ledGreenPin, LOW);

          // Drive the motors
          int nbOfServos = 4;
          int servoSchedule[nbOfServos] = {3, 4, 1, 2}; 
          int speedSchedule[nbOfServos] = {13, 35, 20, 45};
          scheduleTurns(nbOfServos, servoSchedule, speedSchedule, 500, 1600);
          stopAllServos();
          delay(2000);

        }
    }

    // Delay before next loop (in milliseconds)
    delay(10);
}