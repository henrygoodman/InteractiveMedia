// This class implements the map floor plan. It is simply an image/shape that we may define the co-ordinates of 2 'entrances'.
// We determine the position of the entrances regardless of image size by scaling the position and the image by the same scale factor.

public class Map {
  int xpos, ypos;
  float w =  DRAW_WIDTH/2 - WIDTH_PADDING/2, h = DRAW_HEIGHT/2 - 10;
  String year;
  Passage p1, p2;
  int[] ns = {0,0};
  boolean setAudioEnabled = false;
  HashMap<String, String> busiestDays = new HashMap<String, String>();
  LocalDateTime currentYearTime;
  
  // Default constructor, draws a rectangle of width * height in the middlish of the screen.
  public Map(int quadrant, String year) {
    
    busiestDays.put("2022 Broadway", "Wednesday");
    busiestDays.put("2022 JonesSt", "Wednesday");
    busiestDays.put("2021 Broadway", "Thursday");
    busiestDays.put("2021 JonesSt", "Thursday");
    busiestDays.put("2020 Broadway", "Wednesday");
    busiestDays.put("2020 JonesSt", "Tuesday");
    busiestDays.put("2019 Broadway", "Thursday");
    busiestDays.put("2019 JonesSt", "Wednesday");
    
    if (quadrant == 1 || quadrant == 3) {
      xpos = WIDTH_PADDING/2;
    } else {
      xpos = WIDTH_PADDING/2 + DRAW_WIDTH/2;
    }
    if (quadrant == 1 || quadrant == 2) {
      ypos = TOP_OFFSET;
    } else {
      ypos = TOP_OFFSET + DRAW_HEIGHT/2;
    }
    p1 = new Passage("Broadway", xpos + 400, ypos + 40, this, 12, busiestDays.get(year + " Broadway"));
    p2 = new Passage("Jones St", xpos + 400, ypos + 38, this, 13, busiestDays.get(year + " JonesSt"));
    this.year = year;
  }
  
  void reinit() {
    if (year.equals("2022")) {
       currentYearTime = startTime.plusHours(48); 
    }
    else if (year.equals("2021")) {
       currentYearTime = startTime.plusHours(72); 
    }
    else if (year.equals("2020")) {
       currentYearTime = startTime.plusHours(96); 
    }
    else if (year.equals("2019")) {
       currentYearTime = startTime.plusHours(0); 
    } 
  }
  
  public int display() {  // Update according to pollRate. 
    if (frameCount == 1 || frameCount * pollRate % targetFrames <= 0.05) {
      ns = updateInterval(timeScale);
    }
    
    if (mouseX >= xpos && mouseX <= xpos + w && mouseY >= ypos && mouseY <= ypos + h) {
      if (frameCount % 30 == 0) {
        playAudio(max((p1.people.size() + p2.people.size()) % 5, (int)Math.ceil(map(p1.people.size() + p2.people.size(), 0, 5000, 0, 80))));
      }
      setAudioEnabled = true;
    } else {
      setAudioEnabled = false;
    }
          
    fill(255,230);
    rect(xpos, ypos, w, h);
    p1.display(ns[0]);
    p2.display(ns[1]);
    drawCounter(ns[0], ns[1]);
    return ns[0] + ns[1];
  }
  
  // Turns the busiest map green.
  void displayBusiest() {
    fill(0,200,0,30);
    rect(xpos, ypos, w, h);
  }
  
  int[] updateInterval(String timeScale) {
    int[] ret = new int[2];
    if (timeScale == "HOUR") {
      ret[0] = p1.updateHour(currentYearTime);
      ret[1] = p2.updateHour(currentYearTime);
    } else {
      ret[0] = p1.updateDay(currentYearTime);
      ret[1] = p2.updateDay(currentYearTime);
    }
    return ret;
  }
  void drawCounter(int count1, int count2) {
    fill(0);
    textSize(15);
    float totalEntries = count1 + count2;
    String timeString = currentYearTime.toString();
    
    if (timeScale.equals("DAY"))
    timeString = timeString.split("T")[0];
    text("Date: " + timeString.replace("1900-",""), xpos + WIDTH_PADDING + 5, ypos + 20);
    text("Day: " + latestTime.getDayOfWeek(), xpos + WIDTH_PADDING + 5, ypos + 40);
    text("Total Entries: " + totalEntries, xpos + WIDTH_PADDING + 5, ypos + 60);
    
    textSize(40);
    text(year, xpos + DRAW_WIDTH/2 - 100, ypos + 40);
  }

}
