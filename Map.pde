// This class implements the map floor plan. It is simply an image/shape that we may define the co-ordinates of 2 'entrances'.
// We determine the position of the entrances regardless of image size by scaling the position and the image by the same scale factor.

public class Map {
  int xpos, ypos;
  String year;
  Passage p1, p2;
  int[] ns = {0,0};

  // Default constructor, draws a rectangle of width * height in the middlish of the screen.
  public Map(int quadrant, String year) {
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
    p1 = new Passage("Broadway", xpos + width/2.8, ypos + height/4 - 100, this.xpos);
    p2 = new Passage("Jones St", xpos + width/2.8, ypos + height/4 + 30, this.xpos);
    this.year = year;
  }
  
  public int display() {  // Update according to pollRate. 
    if (frameCount == 1 || frameCount * pollRate % targetFrames <= 0.05) {
      ns = updateInterval(timeScale);
    }
    fill(255);
    rect(xpos, ypos, DRAW_WIDTH/2 - WIDTH_PADDING/2, DRAW_HEIGHT/2 - 10);
    p1.display(ns[0], ns[0] > ns[1]);
    p2.display(ns[1], ns[1] > ns[0]);
    drawCounter(ns[0], ns[1]);
    return ns[0] + ns[1];
  }
  
  // Turns the busiest map green.
  void displayBusiest() {
    fill(0,200,0,30);
    rect(xpos, ypos, DRAW_WIDTH/2 - WIDTH_PADDING/2, DRAW_HEIGHT/2 - 10);
  }
  
  int[] updateInterval(String timeScale) {
    int[] ret = new int[2];
    if (timeScale == "HOUR") {
      ret[0] = p1.updateHour(currentTime);
      ret[1] = p2.updateHour(currentTime);
    } else {
      ret[0] = p1.updateDay(currentTime);
      ret[1] = p2.updateDay(currentTime);
    }
    return ret;
  }
  void drawCounter(int count1, int count2) {
    fill(0);
    textSize(15);
    float totalEntries = count1 + count2;
    String timeString = latestTime.toString();
    
    if (timeScale.equals("DAY"))
    timeString = timeString.split("T")[0];
    text("Date: " + timeString.replace("1900-",""), xpos + WIDTH_PADDING + 5, ypos + 20);
    text("Day: " + latestTime.getDayOfWeek(), xpos + WIDTH_PADDING + 5, ypos + 40);
    text("Total Entries: " + totalEntries, xpos + WIDTH_PADDING + 5, ypos + 60);
    
    textSize(40);
    text(year, xpos + DRAW_WIDTH/2 - 100, ypos + 40);
  }
  
}
