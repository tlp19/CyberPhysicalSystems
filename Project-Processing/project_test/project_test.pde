import processing.sound.*;
import oscP5.*;
import netP5.*;
import processing.serial.*;

Serial port;
String[] materials = {"wood", "metal", "plastic"};

OscP5 oscP5;
NetAddress dest;

FFT fft;
Amplitude amp;
AudioIn in;

int bands = 512;
float[] spectrum = new float[bands];
int constFreqNum = 10;
float sampleRate = 44100.0;

int confirmationWait = 500;

boolean recording = false;
int lastRecording = 0;
int woodRecords = 0;
int metalRecords = 0;
int plasticRecords = 0;


void setup() {
  size(1024, 360);
  background(255);

  // Setup the communication with the Arduino
  String portName = Serial.list()[2];
  port = new Serial(this, portName, 9600);

  // Start oscP5, listening for incoming messages at port 12000
  oscP5 = new OscP5(this, 12000);
  dest = new NetAddress("127.0.0.1", 6448);
    
  // Create an Input stream which is routed into the Amplitude analyzer
  Sound s = new Sound(this);
  // println(Sound.list());
  // s.inputDevice(8);
  in = new AudioIn(this, 0);

  // Create the analysis objects
  fft = new FFT(this, bands);
  amp = new Amplitude(this);
  
  // Start the Audio Input
  in.start();
  
  // Patch the AudioIn into the analysis objects
  fft.input(in);
  amp.input(in);
}


void draw() { 
  background(255);
  fft.analyze(spectrum);
  float amplitude = amp.analyze();

  int[] constFreq = new int[constFreqNum];
  // Iterate over all the bands
  for(int i = 0; i < bands; i++){
    // The result of the FFT is normalized
    // Draw the line for frequency band i scaling it up by 5 to get more amplitude.
    line( i, height, i, height - spectrum[i]*height*20);
    
    // Find the 5 biggest constituent frequencies
    for(int j = 0; j < constFreq.length; j++){
      if (spectrum[i] > spectrum[constFreq[j]]){
        // Add the frequency index to its right place in the array
        constFreq = splice(constFreq, i, j);
        // Remove the last element of the array
        constFreq = subset(constFreq, 0, constFreq.length-1);
        break;
      }
    }
  }

  // Convert the frequency band indices to frequencies
  // and store the amplitude of each frequency
  float[] frequencies = new float[constFreqNum];
  float[] freqAmps = new float[constFreqNum];
  for(int i = 0; i < constFreq.length; i++){
    frequencies[i] = bandToFreq(constFreq[i]);
    freqAmps[i] = spectrum[constFreq[i]];
  }

  if (amplitude > 0.30){
    sendOsc(amplitude, frequencies, freqAmps);
    println("Amplitude: " + amplitude);
    // println("Freq 1: " + frequencies[0] + " Hz with amplitude " + freqAmps[0]);
    // println("Freq 2: " + frequencies[1] + " Hz with amplitude " + freqAmps[1]);
    // println("Freq 3: " + frequencies[2] + " Hz with amplitude " + freqAmps[2]);
  }

  // If the last OSC message from Wekinator was received more than a certain time ago (the confirmation wait)
  if (recording && (millis() > (lastRecording + confirmationWait))) {
    
    // Find the total number of records
    int allRecords = woodRecords + metalRecords + plasticRecords;

    // Make sure there are enough records to make a decision
    if (allRecords <= 6) {
      return;
    }

    // Find the proportion of each material
    float propWood = (float)woodRecords / (float)allRecords;
    float propMetal = (float)metalRecords / (float)allRecords;
    float propPlastic = (float)plasticRecords / (float)allRecords;

    // Find the material with the highest proportion and send it to the Arduino
    if ((propWood > propMetal) && (propWood > propPlastic)) {
      updateArduino(materials[0]);
    } else if ((propMetal > propWood) && (propMetal > propPlastic)) {
      updateArduino(materials[1]);
    } else if ((propPlastic > propWood) && (propPlastic > propMetal)) {
      updateArduino(materials[2]);
    }

    // Reset the records
    recording = false;
    woodRecords = 0;
    metalRecords = 0;
    plasticRecords = 0;
  }
}


void oscEvent(OscMessage oscMessage) {
  // Check if theOscMessage has the address pattern we are looking for
  if (oscMessage.checkAddrPattern("/wek/outputs")) {

    // Check if the typetag is the right one
    if (oscMessage.checkTypetag("f")) {

      // Parse the OscMessage and extract the values from the osc message arguments
      float value = oscMessage.get(0).floatValue();
      println("---> received OSC message from '/wek/outputs'");
      println(" value: " + value);

      // Record the predicted material
      recording = true;
      switch ((int)value) {
        case 1:
          woodRecords++;
          break;
        case 2:
          metalRecords++;
          break;
        case 3:
          plasticRecords++;
          break;
      }

      // Remember when we received this message
      lastRecording = millis();

      println("Wood: " + woodRecords + " Metal: " + metalRecords + " Plastic: " + plasticRecords);
    }

  } else if (oscMessage.checkAddrPattern("/material")) {
    // if (oscMessage.checkTypetag("ffff")) {
    //   float firstValue = oscMessage.get(0).floatValue();
    //   float secondValue = oscMessage.get(1).floatValue();
    //   float thirdValue = oscMessage.get(2).floatValue();
    //   float fourthValue = oscMessage.get(3).floatValue();
    //   println("---> received OSC message from '/material'");
    //   println(" values: " + firstValue);
    //   println("         " + secondValue);
    //   println("         " + thirdValue);
    //   println("         " + fourthValue);

  } else {
    println("---> received unknown OSC message with address " + oscMessage.addrPattern());
  }
}


// Convert a FFT band to its corresponding frequency
float bandToFreq(int band){
  return band * sampleRate/(bands*2.0);
}

// Send an OSC message to Wekinator
void sendOsc(float amplitude, float[] frequencies, float[] freqAmps) {
  // start a new OSC message
  OscMessage msg = new OscMessage("/wek/inputs");
  // add the amplitude value to the OSC message
  msg.add(amplitude);
  // add each constituent frequency to the OSC message
  for (int i = 0; i < frequencies.length; i++) {
    msg.add(frequencies[i]);
  }
  // add each constituent frequency's amplitude to the OSC message
  for (int i = 0; i < freqAmps.length; i++) {
    msg.add(freqAmps[i]);
  }
  // send the OSC message
  oscP5.send(msg, dest);
}


// Send a new message to the Arduino
void updateArduino(String message) {
    // Add a delimiter to the message
    message = message + "_";

    // Send the message to the Arduino
    port.write(message);
    println("Sent to the arduino: ", message);
}