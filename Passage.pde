import java.util.*;
import java.time.*;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;

public class Passage {
  float[] position = {0, 0};
  String name;
  String[][] data;
  int index = 0;
  LinkedList<Person> people;
  float w = 80;
  float h = 75;
  float entrancePos;
  PImage[] img = {loadImage("Assets/Images/StickF1.gif"),
                  loadImage("Assets/Images/StickF2.gif"),
                  loadImage("Assets/Images/StickF3.gif"),
                  loadImage("Assets/Images/StickF4.gif"),
                };
  
  public Passage(String name, float x, float y, float mapXpos) {
    this.name = name;
    position[0] = x;
    position[1] = y;
    people = new LinkedList();
    entrancePos = mapXpos;
  }
  
  public void setData(String[][] data) {
    this.data = data;
    normalizeYear();
  }
  
  public float[] getPosition() {
    return position;
  }
  
  public void display(int count, boolean busier) {
    textSize(20);
    color textColor = busier ? color(100, 150, 100) : color(40, 40, 40);
    fill(textColor);
    text(name, position[0], position[1] - 10);
    textSize(15);
    text("Count: " + count, position[0], position[1] + h + 20);
    stroke(0);
    fill(134);
    
    rect(position[0], position[1], w, h);
    rect(position[0] + w/2 - 3, position[1], 6, h);
    
    for (int i = 0; i < people.size(); i++) {
      people.get(i).display(img[frameCount % 32 / 8]);
      people.get(i).move();
    }
  }
  
  // update the sketch, show all the data points from the given time interval (currently an hour).
  int updateHour(LocalDateTime currentTimeInterval) {
    int intervalCount = 0;
    int currentHour = currentTimeInterval.getHour();
    float currentData = Float.parseFloat(data[index][1]);
    LocalDateTime currentTime = stringToDate(data[index][0]);

    // Runs at the start to match the time of the first data points together.
    while (currentTime.isBefore(currentTimeInterval) && currentTime.getHour() < currentHour) {
      index++;
      currentTime = stringToDate(data[index][0]);
    }
    
    // Update every hour
    while (currentTime.getHour() == currentHour) {
      int addCount = 0;
      while (addCount < currentData) {
          // If we are drawing heaps, only render every 2nd.
          if (intervalCount > 100 && addCount % 2 != 0) break;
          people.add(new Person(this));
          addCount++;
      }
      
      intervalCount += currentData;
      
      // Get a new data point while in the same hour.
      index++;
      if (index >= data.length) {index = 0;}
      currentTime = stringToDate(data[index][0]);
      currentData = Float.parseFloat(data[index][1]);
    }
    removePeople();
    return intervalCount;
  }
  
  
  // Update the sketch, show all the data points from the given time interval.
  int updateDay(LocalDateTime currentTimeInterval) {
    int intervalCount = 0;
    DayOfWeek currentDay = currentTimeInterval.getDayOfWeek();
    
    float currentData = Float.parseFloat(data[index][1]);
    LocalDateTime currentTime = stringToDate(data[index][0]);
    
    // Runs at the start to match the time of the first data points together.
    while (currentTime.isBefore(currentTimeInterval) && currentTime.getDayOfWeek() != currentDay) {
      index++;
      currentTime = stringToDate(data[index][0]);
    }
    
    // Update every day (iterate all the points until we reach the next day.)
    while (currentTime.getDayOfWeek() == currentDay) {
      int addCount = 0;
      while (addCount < currentData) {
          // If we are drawing heaps, only render every 2nd.
          if (intervalCount > 100 && addCount % 2 != 0) break;
          people.add(new Person(this));
          addCount++;
      }
      intervalCount += currentData;
      
      // Get a new data point while in the same day.
      index++;
      if (index >= data.length) {index = 0;}
      currentTime = stringToDate(data[index][0]);
      currentData = Float.parseFloat(data[index][1]);
    }
    removePeople();
    return intervalCount;
  }
  
  // Dont pay much attention to this, this just converts each data DATE to the same year so we can compare hour/day times easier.
  void normalizeYear() {
    for (int i = 0; i < data.length; i++) {
      String year = data[i][0].split("-")[0];
      data[i][0] = data[i][0].replace(year, "1900");
    }
  }
  
  void removePeople() {
    LinkedList<Person> removeList = new LinkedList<Person>();
    for (Person p : people) {
      if (p.walkedIn) {
        p.life++;
      }
      if (p.life > 0) {
        removeList.add(p);
      }
    }
    people.removeAll(removeList);
  }
}
