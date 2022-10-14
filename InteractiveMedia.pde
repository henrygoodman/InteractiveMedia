import controlP5.*;
import processing.sound.*;    

// GLOBAL PARAMETERS
ControlP5 cp5;
Map map1, map2, map3, map4;
int n1, n2, n3, n4; // Tracks the entrance count for both passages at each time interval.
LocalDateTime startTime, currentTime, latestTime;
float targetFrames = 60;
SoundFile[] sounds;

// Parameters accessible to change
color backgroundColor = color( 10, 10, 10);
float pollRate = 0.5; // This number determines how many updates occur each second of real time.

// UI element value trackers.
boolean toggleValue = true;
String timeScale = toggleValue ? "HOUR" : "DAY";
String latestTimeScale = "";
int TOP_OFFSET = 80;
int WIDTH_PADDING = 20;
int DRAW_HEIGHT;
int DRAW_WIDTH;

void setup() {
  DRAW_HEIGHT = height - TOP_OFFSET;
  DRAW_WIDTH = width - WIDTH_PADDING;
  
  frameRate(targetFrames);
  size(1000, 800);
  background(backgroundColor);
  
  // Instantiate GUI controller
  cp5 = new ControlP5(this);
  
  // Load the maps
  map1 = new Map(1, "2022");
  map2 = new Map(2, "2021");
  map3 = new Map(3, "2020");
  map4 = new Map(4, "2019");
  
  // Set the data for Broadway
  map1.p1.setData(loadData("2022_Broadway"));
  map2.p1.setData(loadData("2021_Broadway"));
  map3.p1.setData(loadData("2020_Broadway"));
  map4.p1.setData(loadData("2019_Broadway"));
  
  // Set the data for Jones St
  map1.p2.setData(loadData("2022_JonesSt"));
  map2.p2.setData(loadData("2021_JonesSt"));
  map3.p2.setData(loadData("2020_JonesSt"));
  map4.p2.setData(loadData("2019_JonesSt"));
  
  // Set the start time for the sketch (gets the min of all startTimes), set the currentTime to the startTime to begin.
  String[] startTimes = {map1.p1.data[0][0], map1.p2.data[0][0], 
                         map2.p1.data[0][0], map2.p2.data[0][0], 
                         map3.p1.data[0][0], map3.p2.data[0][0], 
                         map4.p1.data[0][0], map4.p2.data[0][0]};
  startTime = getStartTime(startTimes);
  currentTime = startTime;
  latestTime = startTime;
  
  // Add timescale toggle
  addToggle();
  
  // Load Audio
  sounds = new SoundFile[6];
  sounds[0] = new SoundFile(this, "footstep1.mp3");
  sounds[1] = new SoundFile(this, "footstep2.mp3");
  sounds[2] = new SoundFile(this, "footstep3.mp3");
  sounds[3] = new SoundFile(this, "footstep4.mp3");
  sounds[4] = new SoundFile(this, "door1.wav");
  sounds[5] = new SoundFile(this, "door1.wav");
}
void draw() {
  background(backgroundColor);
  drawMainGUI();
  
  // Display each map, store the current IN count for the specified time interval.
  n1 = map1.display();
  n2 = map2.display();
  n3 = map3.display();
  n4 = map4.display();
  displayBusiest(n1, n2, n3, n4);
  
  // Every time we toggle the scale, update the latest time (so when we switch from DAY back to HOUR correct time shows as midnight).
  timeScale = toggleValue ? "HOUR" : "DAY";
  if (timeScale != latestTimeScale) latestTime = currentTime;
  latestTimeScale = timeScale;
  
  if (frameCount == 1 || frameCount * pollRate % targetFrames <= 0.05) {
    currentTime = currentTime.truncatedTo(ChronoUnit.HOURS);
    latestTime = currentTime;
    if (timeScale.equals("HOUR")) {
      currentTime = currentTime.plusHours(1);
    }
    if (timeScale.equals("DAY")) {
      currentTime = currentTime.plusHours(24 - currentTime.getHour());
    }
  }
}

void drawMainGUI() {
  String timeString = latestTime.toString();
  fill(255);
  textSize(50);
  if (timeScale.equals("HOUR")) {
    text(latestTime.getDayOfWeek().toString() + " " + timeString.split("T")[1], width/2 - 200, 50);
  } else {
    text(latestTime.getDayOfWeek().toString(), width/2 - 150, 50);
  }
  textSize(15);
  text("Scale: " + timeScale, width - 100, 40);
}


// Calculates the start time in the given time scale (gets minimum value to start from)
LocalDateTime getStartTime(String[] strings) {
  LocalDateTime min = stringToDate(strings[0]);
  for (String s : strings) {
    LocalDateTime dateString = stringToDate(s);
    if (min.isAfter(dateString)){
      min = dateString;
    }
  }
  return min.truncatedTo(ChronoUnit.HOURS);
}

String[][] loadData(String fileName) {
  Table dataTable = loadTable("Assets/Data/" + fileName + ".csv", "csv");
  String[][] data;
  data = new String[dataTable.getRowCount()][2];
  
  int index = 0;
  while (index < dataTable.getRowCount()) {
    data[index][0] = dataTable.getString(index, 0);
    data[index][1] = dataTable.getString(index, 1);
    index++;
  }
  return data;
}

LocalDateTime stringToDate(String date) {
  DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
  LocalDateTime dateTime = LocalDateTime.parse(date, formatter);
  return dateTime;
}


/*************************** GUI STUFF ****************************/

void addToggle() {
  cp5.addToggle("toggleValue")
     .setPosition(width - 170, 25)
     .setCaptionLabel("Time Scale")
     .setColorBackground(color(255,0,0))
     .setColorForeground(color(0,0,255))
     .setColorActive(color(0,255,0));
}

void displayBusiest(int x1, int x2, int x3, int x4) {
  if (x1 >= x2 && x1 >= x3 && x1 >= x4) {
    map1.displayBusiest();
  }
  if (x2 >= x1 && x2 >= x3 && x2 >= x4) {
    map2.displayBusiest();
  }
  if (x3 >= x1 && x3 >= x2 && x3 >= x4) {
    map3.displayBusiest();
  }
  if (x4 >= x1 && x4 >= x2 && x4 >= x3) {
    map4.displayBusiest();
  }
}
  
void playAudio(int n) {
  if (n == 0) {
    stopPlayingAudio();
  }
  for (int i = 0; i < n; i++) {
    int index = (int)random(0,3.9);
      sounds[index].play();
  }
}

void stopPlayingAudio() {
  for (SoundFile sound : sounds) {
    if (sound.isPlaying()) {
      sound.stop();
    }
  }
}
