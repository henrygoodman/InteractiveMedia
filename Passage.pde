import java.util.*;
import java.time.*;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;

public class Passage {
  float[] position = {0, 0};
  String name, busiestDay;
  String[][] data;
  LinkedList<Person> people;
  float w = 80, h = 40, entrancePos, passageHeight;
  PImage[] door;
  PImage doorState;
  boolean doorOpen = false;
  int index = 0, currentDoorIndex = 0, soundIndex, totalCount = 0;
  Map m;
  PImage[] img = {loadImage("Assets/Images/StickF1.gif"),
                  loadImage("Assets/Images/StickF2.gif"),
                  loadImage("Assets/Images/StickF3.gif"),
                  loadImage("Assets/Images/StickF4.gif"),
                };
  PImage[] door1 = {loadImage("Assets/Images/door1_0.gif"),
                  loadImage("Assets/Images/door1_1.gif"),
                  loadImage("Assets/Images/door1_2.gif"),
                  loadImage("Assets/Images/door1_3.gif"),
                };
                
  PImage[] door2 = {loadImage("Assets/Images/door2_0.gif"),
                  loadImage("Assets/Images/door2_1.gif"),
                  loadImage("Assets/Images/door2_2.gif"),
                  loadImage("Assets/Images/door2_3.gif"),
                };
  
  public Passage(String name, float x, float y, Map m, int si, String busiestDay) {
    this.name = name;
    position[0] = x;
    position[1] = y;
    people = new LinkedList();
    entrancePos = m.xpos;
    this.m = m;
    this.busiestDay = busiestDay;
    soundIndex = si;
    
    if (this.name == "Broadway") {
      door = door1;
      passageHeight = position[1] + 70;
    } else {
      door = door2;
      passageHeight = position[1] + 250;
    }
    doorState = door[0];
    
  }
  
  public void setData(String[][] data) {
    this.data = data;
    normalizeYear();
  }
  
  public float[] getPosition() {
    return position;
  }
  
  public void display(int count) {
    stroke(0);
    fill(163, 145, 132, 100);
    rect(m.xpos, passageHeight - 17, m.w - 50, 40);
    removePeople();
    updateDoor();
    fill(134, 90);
    image(doorState, position[0] - 100, position[1], 3 * w, 8 * h);

    for (int i = 0; i < people.size(); i++) {
      people.get(i).display(img[frameCount % 32 / 8]);
      people.get(i).move();
    }
    
    float ypos;
    if (name.equals("Broadway")) {
      ypos = position[1];
    } else {
      ypos = position[1] + 200;
    }
    if (mouseX > position[0] - 100 && mouseX < position[0] - 100 + 3 * w && mouseY > ypos && mouseY < ypos + 2 * h) {
       displayInfoBox(count); 
    }
  }
  
  void displayInfoBox(int count) {
    float ypos; 
    float xpos = position[0] - 150;
    if (name.equals("Broadway")) {
      ypos = position[1];
    } else {
      ypos = position[1] + 200;
    }
    fill(255, 220);
    rect(xpos, ypos, 200, 100, 5,5,5,5);
    textSize(15);
    fill(0);
    text(name + " " + m.year, xpos + 10, ypos + 25);
    text("Current Interval Count: " + count, xpos + 10, ypos + 45);
    text("Total Count: " + totalCount, xpos + 10, ypos + 65);
    text("Busiest day: " + busiestDay, xpos + 10, ypos + 85);
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
          if (intervalCount > 100 && intervalCount % 256 != 0) break;
          people.add(new Person(this));
          addCount++;
      }
      
      intervalCount += currentData;
      
      // Get a new data point while in the same hour.
      index++;
      if (index >= data.length) {
        index = 0;
        m.reinit();
        currentTime = startTime;
        latestTime = startTime;
      }
      currentTime = stringToDate(data[index][0]);
      currentData = Float.parseFloat(data[index][1]);
    }
    totalCount += intervalCount;
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
          if (intervalCount > 100 && intervalCount % 512 != 0) break;
          people.add(new Person(this));
          addCount++;
      }
      intervalCount += currentData;
      
      // Get a new data point while in the same day.
      index++;
      if (index >= data.length) {
        index = 0;
        m.reinit();
        currentTime = startTime;
        latestTime = startTime;
      }
      currentTime = stringToDate(data[index][0]);
      currentData = Float.parseFloat(data[index][1]);
    }
    totalCount += intervalCount;
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
        removeList.add(p);
      }
    }
    people.removeAll(removeList);
  }
  
  void updateDoor() {
   if (!doorOpen) {
     boolean firstPersonClose = false;
      for (Person p : people) {
        if (p.getDistance() != 0 && p.getDistance() < 150) {
          firstPersonClose = true;
          break;
        } 
     }
     if (firstPersonClose)
       openDoor();
   }
   else {
     boolean lastPersonInside = true;
      for (Person p : people) {
        if (p.getDistance() != 0 && p.getDistance() > 10) {
          lastPersonInside = false;
        } 
     }
     if (lastPersonInside)
       closeDoor();
   }
  }
  
  void openDoor() {
     if (doorState == door[3]) {
       doorOpen = true;
       return;
     }
     if (frameCount % 3 == 0) {
       currentDoorIndex += 1;
       doorState = door[currentDoorIndex];
     }
     if (!sounds[soundIndex].isPlaying() && m.setAudioEnabled) {
       sounds[soundIndex].play();
     }
 }
 
 void closeDoor() {
    if (doorState == door[0]) {
      doorOpen = false;
      return;
    }
    if (frameCount % 3 == 0) {
       currentDoorIndex -= 1;
       doorState = door[currentDoorIndex];
    }
 }
 
}
