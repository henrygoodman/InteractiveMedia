import controlP5.*;
/* This file will act as the basic skeleton for assignment 2. Defining all the classes we need, the functions, etc. We will work on components separately, and then once they are finished
 * we can add them to this skeleton and consider that portion complete. 
 *
 * GENERAL OVERVIEW OF FUNCTIONALITY:
 * We want to model the people tracking data from both level 2 entrances/exits. We will download data for the entire year, as this will allow us to have a large range if needed which we can
 * zoom into. We also wish to store the data from the past 2-3 previous years, as by using different colours (and GUI selector elements), we can show which data points correspond to which
 * year. This gives a good comparison of traffic between the years. 
 *
 */

// GLOBAL PARAMETERS
ControlP5 cp5;
Map map1, map2, map3, map4;
int n1, n2, n3, n4; // Tracks the entrance count for both passages at each time interval.
LocalDateTime startTime;
LocalDateTime currentTime, latestTime;
float targetFrames = 60;

// Parameters accessible to change
color backgroundColor = color( 10, 10, 10);
float pollRate = 0.3; // This number determines how many updates occur each second of real time.
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
  
  // Add timescale toggle
  addToggle();
  
  // Load the maps
  map1 = new Map(1, "2022");
  map2 = new Map(2, "2021");
  map3 = new Map(3, "2020");
  map4 = new Map(4, "2019");
  
  // Set the data for Broadway TODO set for each map
  map1.p1.setData(loadData("https://eif-research.feit.uts.edu.au/api/csv/?rFromDate=2022-04-01T00%3A00&rToDate=2022-12-31T23%3A59%3A59&rFamily=people_sh&rSensor=CB11.PC02.14.Broadway&rSubSensor=CB11.02.Broadway.East+In"));
  map2.p1.setData(loadData("https://eif-research.feit.uts.edu.au/api/csv/?rFromDate=2021-04-01T00%3A00&rToDate=2021-12-31T23%3A59%3A59&rFamily=people_sh&rSensor=CB11.PC02.14.Broadway&rSubSensor=CB11.02.Broadway.East+In"));
  map3.p1.setData(loadData("https://eif-research.feit.uts.edu.au/api/csv/?rFromDate=2020-04-01T00%3A00&rToDate=2020-12-31T23%3A59%3A34&rFamily=people&rSensor=+PC02.14+%28In%29"));
  map4.p1.setData(loadData("https://eif-research.feit.uts.edu.au/api/csv/?rFromDate=2019-04-01T00%3A00&rToDate=2019-12-31T23%3A59%3A34&rFamily=people&rSensor=+PC02.14+%28In%29"));
  
  // Set the data for Jones St TODO set for each map
  map1.p2.setData(loadData("https://eif-research.feit.uts.edu.au/api/csv/?rFromDate=2022-04-01T00%3A00&rToDate=2022-12-31T23%3A59%3A59&rFamily=people_sh&rSensor=CB11.PC02.16.JonesStEast&rSubSensor=CB11.02.JonesSt+In"));
  map2.p2.setData(loadData("https://eif-research.feit.uts.edu.au/api/csv/?rFromDate=2021-04-01T00%3A00&rToDate=2021-12-31T23%3A59%3A59&rFamily=people_sh&rSensor=CB11.PC02.16.JonesStEast&rSubSensor=CB11.02.JonesSt+In"));
  map3.p2.setData(loadData("https://eif-research.feit.uts.edu.au/api/csv/?rFromDate=2020-04-01T00%3A00&rToDate=2020-12-31T23%3A59%3A34&rFamily=people&rSensor=+PC02.16+%28In%29"));
  map4.p2.setData(loadData("https://eif-research.feit.uts.edu.au/api/csv/?rFromDate=2019-04-01T00%3A00&rToDate=2019-12-31T23%3A59%3A34&rFamily=people&rSensor=+PC02.16+%28In%29"));
  
  // Set the start time for the sketch (compare the first 2 times), set the currentTime to the startTime to begin. TODO - get the time regardless of year.
  String[] startTimes = {map1.p1.data[0][0], map1.p2.data[0][0], 
                         map2.p1.data[0][0], map2.p2.data[0][0], 
                         map3.p1.data[0][0], map3.p2.data[0][0], 
                         map4.p1.data[0][0], map4.p2.data[0][0]};
  startTime = getStartTime(startTimes);
  currentTime = startTime;
  latestTime = startTime;
  
}
void draw() {
  background(backgroundColor);
  drawMainGUI();
  
  // n is the count displayed on each map in top corner.
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

String[][] loadData(String url) {
  Table dataTable = loadTable(url, "csv");
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
