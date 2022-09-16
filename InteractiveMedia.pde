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
Map map;
Passage p1, p2;
int n1 = 0, n2 = 0; // Tracks the entrance count for both passages at each time interval.
LocalDateTime startTime;
LocalDateTime currentTime, latestTime;
float targetFrames = 60;

// Parameters accessible to change
color backgroundColor = color( 10, 10, 10);
float pollRate = 0.3; // This number determines how many updates occur each second of real time.
boolean toggleValue = true;
String timeScale = toggleValue ? "HOUR" : "DAY";

void setup() {
  frameRate(targetFrames);
  size(1000, 800);
  background(backgroundColor);
  
  // Instantiate GUI controller
  cp5 = new ControlP5(this);
  
  // Add timescale toggle
  addToggle();
  
  // Load the map
  map = new Map();
  
  // Set map entrances
  p1 = new Passage("Broadway", 2*width/3, height/2 - 75);
  p2 = new Passage("Jones St", 2*width/3, height/2 + 75);
  
  // Set the data for Broadway (April 1 - Dec 31)
  p1.setData(loadData("https://eif-research.feit.uts.edu.au/api/csv/?rFromDate=2021-04-01T00%3A00&rToDate=2021-12-31T23%3A59%3A59&rFamily=people_sh&rSensor=CB11.PC02.14.Broadway&rSubSensor=CB11.02.Broadway.East+In"));
  
  // Set the data for Jones St (Aprial 1 - Dec 31)
  p2.setData(loadData("https://eif-research.feit.uts.edu.au/api/csv/?rFromDate=2021-04-01T00%3A00&rToDate=2021-12-31T23%3A59%3A59&rFamily=people_sh&rSensor=CB11.PC02.16.JonesStEast&rSubSensor=CB11.02.JonesSt+In"));
  
  // Set the start time for the sketch (compare the first 2 times), set the currentTime to the startTime to begin.
  String[] startTimes = {p1.data[0][0], p2.data[0][0]};
  startTime = getStartTime(startTimes);
  currentTime = startTime;
  
}

void draw() {
  background(backgroundColor);

  map.display();
  p1.display(n1, n1 > n2);
  p2.display(n2, n2 > n1);
  
  // Update according to pollRate. 
  if (frameCount == 1 || frameCount * pollRate % targetFrames <= 0.05) {
    System.out.println("Updating...");
    
    if (timeScale.equals("HOUR")) {
      latestTime = currentTime;
      n1 = p1.updateHour(currentTime);
      n2 = p2.updateHour(currentTime);
      currentTime = currentTime.plusHours(1);
    }
    if (timeScale.equals("DAY")) {
      latestTime = currentTime;
      n1 = p1.updateDay(currentTime);
      n2 = p2.updateDay(currentTime);
      currentTime = currentTime.plusHours(24);
    }
  }
  drawCounter(n1, n2);
  timeScale = toggleValue ? "HOUR" : "DAY";
}

void drawCounter(int count1, int count2) {
  fill(255);
  textSize(15);
  float totalEntries = count1 + count2;
  String timeString = latestTime.toString();
  
  if (timeScale.equals("DAY"))
  timeString = timeString.split("T")[0];
  text("Date: " + timeString, 50, 20);
  text("Day: " + latestTime.getDayOfWeek(), 50, 40);
  text("Scale: " + timeScale, width - 100, 120);
  text("Total Entries: " + totalEntries, 50, 60);
  
  fill(0);
  textSize(50);
  if (timeScale.equals("HOUR")) {
    text(latestTime.getDayOfWeek().toString() + " " + timeString.split("T")[1], width/2 - 200, height/3);
  } else {
    text(latestTime.getDayOfWeek().toString(), width/2 - 150, height/3);
  }

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
     .setPosition(width - 100, 50)
     .setCaptionLabel("Time Scale")
     .setColorBackground(color(255,0,0))
     .setColorForeground(color(0,0,255))
     .setColorActive(color(0,255,0));
}
