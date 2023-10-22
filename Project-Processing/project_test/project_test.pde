import processing.sound.*;
import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress dest;

FFT fft;
Amplitude amp;
AudioIn in;

int bands = 1024;
float[] spectrum = new float[bands];
int constFreqNum = 5;
float sampleRate = 44100.0;


void setup() {
  size(1024, 360);
  background(255);

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

  if (amplitude > 0.25){
    sendOsc(amplitude, frequencies, freqAmps);
    println("Amplitude: " + amplitude);
    println("Freq 1: " + frequencies[0] + " Hz with amplitude " + freqAmps[0]);
    println("Freq 2: " + frequencies[1] + " Hz with amplitude " + freqAmps[1]);
    println("Freq 3: " + frequencies[2] + " Hz with amplitude " + freqAmps[2]);
  }
}


void oscEvent(OscMessage oscMessage) {
  /* check if theOscMessage has the address pattern we are looking for. */
  if (oscMessage.checkAddrPattern("/wek/outputs")==true) {
    /* check if the typetag is the right one. */
    println(oscMessage.typetag());
    if (oscMessage.checkTypetag("fff")) {
      /* parse theOscMessage and extract the values from the osc message arguments. */
      float firstValue = oscMessage.get(0).floatValue();
      float secondValue = oscMessage.get(1).floatValue();
      float thirdValue = oscMessage.get(2).floatValue();
      println("### received an osc message with typetag f.");
      println(" values: " + firstValue);
      println("         " + secondValue);
      println("         " + thirdValue);

      //updateArduino((int)firstValue);
      return;
    }
  }
  println("### received an osc message. with address pattern "+oscMessage.addrPattern());
}


float bandToFreq(int band){
  return band * sampleRate/(bands*2.0);
}


void sendOsc(float amplitude, float[] frequencies, float[] freqAmps) {
  // start a new OSC message
  OscMessage msg = new OscMessage("/wek/inputs");
  // add the amplitude value to the OSC message
  msg.add(amplitude);
  // add each constituent frequency to the OSC message
  for (int i = 0; i < frequencies.length; i++) {
    msg.add(frequencies[i]);
    msg.add(freqAmps[i]);
  }
  // send the OSC message
  oscP5.send(msg, dest);
}
