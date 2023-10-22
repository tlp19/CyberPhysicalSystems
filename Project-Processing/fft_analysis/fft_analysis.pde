import processing.sound.*;

FFT fft;
Amplitude amp;
AudioIn in;
int bands = 1024;
float[] spectrum = new float[bands];
int constFreqNum = 5;
float sampleRate = 44100.0;

float bandToFreq(int band){
  return band * sampleRate/(bands*2.0);
}

void setup() {
  size(1024, 360);
  background(255);
    
  // Create an Input stream which is routed into the Amplitude analyzer
  Sound s = new Sound(this);
  // println(Sound.list());
  s.inputDevice(8);
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
  // iterate over all the bands
  for(int i = 0; i < bands; i++){
    // The result of the FFT is normalized
    // draw the line for frequency band i scaling it up by 5 to get more amplitude.
    line( i, height, i, height - spectrum[i]*height*20);
    
    // find the 5 biggest constituent frequencies
    
    for(int j = 0; j < constFreq.length; j++){
      if (spectrum[i] > spectrum[constFreq[j]]){
        // add the frequency index to the array
        constFreq = splice(constFreq, i, j);
        // remove the last element of the array
        constFreq = subset(constFreq, 0, constFreq.length-1);
        break;
      }
    }
  }

  println("Amplitude: " + amplitude);
  println("Freq 1: " + bandToFreq(constFreq[0]) + " Hz");
  println("Freq 2: " + bandToFreq(constFreq[1]) + " Hz");
  println("Freq 3: " + bandToFreq(constFreq[2]) + " Hz");
  println("Freq 4: " + bandToFreq(constFreq[3]) + " Hz");
  println("Freq 5: " + bandToFreq(constFreq[4]) + " Hz");
}
