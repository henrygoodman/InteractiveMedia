int scl2;

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
     .setColorLabel(0);
}
