import processing.serial.*;

Serial port;

Handle[] handles;

//True if a mouse button has just been pressed while no other button was.
boolean firstMousePress = false;

String lastArduinoMessage;

void setup() {
  // Size of the window
  size(640, 360);
  
  // Setup the communication with the Arduino
  String portName = Serial.list()[2];
  port = new Serial(this, portName, 9600);
  print("Ports available: ");
  //print(Serial.list());
  print("\n");
  
  int numOfHandles = 4;
  handles = new Handle[numOfHandles];
  
  int handleSize = 10;
  int sliderLength = 300;
  int initValue = 50;
  
  int y1 = 50;
  int y2 = 100;
  int y3 = 150;
  int y4 = 200;

  handles[0] = new Handle(1, width/2-sliderLength/2, y1, initValue, handleSize, sliderLength, handles);
  handles[1] = new Handle(2, width/2-sliderLength/2, y2, initValue, handleSize, sliderLength, handles);
  handles[2] = new Handle(3, width/2-sliderLength/2, y3, initValue, handleSize, sliderLength, handles);
  handles[3] = new Handle(4, width/2-sliderLength/2, y4, initValue, handleSize, sliderLength, handles);
  
  lastArduinoMessage = "";
}

void draw() {
  background(200);

  for (int i = 0; i < handles.length; i++) {
    handles[i].update();
    handles[i].display();
    fill(0);
    text(handles[i].id, handles[i].x - 20, handles[i].y);
  }

  //After it has been used in the sketch, set it back to false
  if (firstMousePress) {
    firstMousePress = false;
  }
}


void mousePressed() {
  if (!firstMousePress) {
    firstMousePress = true;
  }
}

void mouseReleased() {
  for (int i = 0; i < handles.length; i++) {
    handles[i].releaseEvent();
  }
}

class Handle {
  int id;
  int x, y;
  int boxx, boxy;
  int value;
  int size;
  int sliderlength;
  boolean over;
  boolean press;
  boolean locked = false;
  boolean otherslocked = false;
  Handle[] others;

  Handle(int _id, int _x, int _y, float init_value, int _size, int _length, Handle[] other_boxes) {
    id = _id;
    x = _x;
    y = _y;
    
    size = _size;
    sliderlength = _length;
    value = int(init_value/100.0*sliderlength);
    
    boxx = x + value - size/2;
    boxy = y - size/2;
    
    others = other_boxes;
  }

  void update() {
    boxx = x + value - size/2;
    boxy = y - size/2;

    for (int i=0; i<others.length; i++) {
      if (others[i].locked == true) {
        otherslocked = true;
        break;
      } else {
        otherslocked = false;
      }
    }

    if (otherslocked == false) {
      overEvent();
      pressEvent();
    }

    if (press) {
      value = in_range(mouseX - x, 0, sliderlength);
      float percentage = float(value) / float(sliderlength) * 100.0;
      println(id, ": ", percentage);
      String message = "s" + str(id) + "v" + str(percentage) + "e";
      updateArduino(message);
    }
  }

  void overEvent() {
    if (overRect(boxx, boxy, size, size)) {
      over = true;
    } else {
      over = false;
    }
  }

  void pressEvent() {
    if (over && firstMousePress || locked) {
      press = true;
      locked = true;
    } else {
      press = false;
    }
  }

  void releaseEvent() {
    locked = false;
  }

  void display() {
    // Draw a line behind the slider
    stroke(125);
    strokeWeight(1);
    line(x, y, x+sliderlength, y);
    stroke(0);
    strokeWeight(3);
    line(x, y, x+value, y);
    
    // If the slider is hovered or pressed
    if (press) {
      // Make the box green
      fill(0,255,0);
    } else if (over) {
      // Make the box blue
      fill(0,0,255);
    } else {
      fill(255);
    }
    // Draw the slider handle/box
    stroke(0);
    strokeWeight(2);
    rect(boxx, boxy, size, size);
  }
}

boolean overRect(int x, int y, int width, int height) {
  if (mouseX >= x && mouseX <= x+width &&
    mouseY >= y && mouseY <= y+height) {
    return true;
  } else {
    return false;
  }
}

int in_range(int val, int minv, int maxv) {
  return  min(max(val, minv), maxv);
}

// send a new message to the Arduino
void updateArduino(String message) {
  // check that the message is different from the last one sent
  //if(message.equals(lastArduinoMessage) == false) {
    // print for debugging convenience
    println("Sent to the arduino: ", message);
    // send the message to the Arduino
    port.write(message);
    // if so then update the message
    lastArduinoMessage = message;
  //}
}
