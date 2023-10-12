#include <Arduino.h>
#include <PCA9685.h>
#include <Wire.h>

ServoDriver servo;

int fwdServoPin = 8;
int clawServoPin = 7;
int rotServoPin = 6;
int upServoPin = 5;

int slider1Value = 50.0;
int slider2Value = 50.0;
int slider3Value = 50.0;
int slider4Value = 50.0;

int readingSliderID = false;
int readingSliderValue = false;
String receivedSliderID = "";
String receivedSliderValue = "";


void setup() {
    // Setup the button pin to use the internal pull-up resistor
    pinMode(2, INPUT_PULLUP);
    Wire.begin();
    Serial.begin(9600);
    servo.init(0x7f);
}


void loop() {

    // Decode message received from Serial
    while(Serial.available()){
        char received = (char)Serial.read();
        
        if(received=='s'){
            readingSliderID = true;
            readingSliderValue = false;

        } else if(received=='v'){
            readingSliderID = false;
            readingSliderValue = true;

        } else if(received=='e'){
            // Clean-up the received strings
            receivedSliderID.trim();
            receivedSliderValue.trim();
            // Update the stored slider values
            if(receivedSliderID=="1"){
                slider1Value = receivedSliderValue.toFloat();
            } else if(receivedSliderID=="2"){
                slider2Value = receivedSliderValue.toFloat();
            } else if(receivedSliderID=="3"){
                slider3Value = receivedSliderValue.toFloat();
            } else if(receivedSliderID=="4"){
                slider4Value = receivedSliderValue.toFloat();
            }
            // Reset the flags and received strings
            readingSliderID = false;
            readingSliderValue = false;
            receivedSliderID = "";
            receivedSliderValue = "";
            //break;

        } else if(readingSliderID){
            receivedSliderID += received;

        } else if(readingSliderValue){
            receivedSliderValue += received;
        }
    }

    Serial.println("Slider 1: " + String(slider1Value));
    Serial.println("Slider 2: " + String(slider2Value));
    Serial.println("Slider 3: " + String(slider3Value));
    Serial.println("Slider 4: " + String(slider4Value));

    // Calculate servo angles
    int upAngle = slider1Value * 80.0/100.0;
    int fwdAngle = 110 - (slider2Value * 110.0/100.0);
    int rotAngle = 180 - (slider3Value * 180.0/100.0);
    int clawAngle = slider4Value * 110.0/100.0;

    Serial.println("Angle up: " + String(upAngle));
    Serial.println("Angle forward: " + String(fwdAngle));
    Serial.println("Angle rotation: " + String(rotAngle));
    Serial.println("Angle claw: " + String(clawAngle));
    
    // Set servo angles
    servo.setAngle(upServoPin, upAngle);
    servo.setAngle(fwdServoPin, fwdAngle);
    servo.setAngle(rotServoPin, rotAngle);
    servo.setAngle(clawServoPin, clawAngle);

    // Delay before next loop (in milliseconds)
    delay(0);
}