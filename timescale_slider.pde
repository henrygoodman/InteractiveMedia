import controlP5.*;
ControlP5 cp5;

int scl2 = 1000; //variable changes scale with slider - change to index?

void setup() {
  size(1000, 800);
  
  cp5 = new ControlP5(this); //initialise
  addSliders();
}

void scaleSlider(int val) {
  scl2 = val;
}

void addSliders() {
   cp5.addSlider("scaleSlider")
     .setPosition(20,20)
     .setSize(200,20)
     .setRange(10,40)
     .setValue(scl2)
     .setLabel("Time Scale")
     .setColorLabel(0)
     ;
}
