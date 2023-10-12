#include <Arduino.h>
#line 1 "C:\\Users\\tangu\\source\\IDE\\CyberPhysicalSystems\\WS1\\WS1.ino"
#include "./lib/Seeed_PCA9685/I2Cdev.cpp"
#include "./lib/Seeed_PCA9685/PCA9685.cpp"
#include <Wire.h>

ServoDriver servo;


#line 8 "C:\\Users\\tangu\\source\\IDE\\CyberPhysicalSystems\\WS1\\WS1.ino"
void setup();
#line 17 "C:\\Users\\tangu\\source\\IDE\\CyberPhysicalSystems\\WS1\\WS1.ino"
void loop();
#line 8 "C:\\Users\\tangu\\source\\IDE\\CyberPhysicalSystems\\WS1\\WS1.ino"
void setup() {
    // join I2C bus (I2Cdev library doesn't do this automatically)
    Wire.begin();
    Serial.begin(9600);
    servo.init(0x7f);
    // uncomment this line if you need to use a special servo
    // servo.setServoPulseRange(600,2400,180);
}

void loop() {
    // Drive 8 servos in turns
    for (int i = 1; i < 9; i++) {
        servo.setAngle(i, 0);
        delay(1000);
        servo.setAngle(i, 90);
        delay(1000);
    }
}
