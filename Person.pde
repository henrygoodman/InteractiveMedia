public class Person {
   float xpos, ypos;
   float xDiff, deltaX;
   float minY, maxY;
   float currDistX = 0;
   float[] entrancePosition = new float[2];
   boolean walkedIn = false;
   float mapPosition;
   float size = random(4,8);
   int life = 0;
   Passage p;
   
   public Person(Passage p) {
     entrancePosition[0] = p.position[0] + random(p.w/2);
     entrancePosition[1] = p.passageHeight;
     mapPosition = p.entrancePos;
     xpos = (float)(random(300) - 300) + p.entrancePos;
     ypos = (float)(random(-p.h/1.8, p.h/1.8)) + entrancePosition[1];
     xDiff = entrancePosition[0] - p.entrancePos;
     deltaX = xDiff * pollRate * 2/targetFrames;
     minY = entrancePosition[1] - 5;
     maxY = minY + p.h;
     this.p = p;
   }
   
   public void move() {
     if (!walkedIn) {
       walkIn();
     }
   }
  
   public void walkIn() {
     if (walkedIn) {return;}
     currDistX = xDiff - (xpos - mapPosition);
     
     if (Math.abs(currDistX) >= 5) {
       xpos += deltaX;
       ypos += random(-.5, .5);
       if (ypos < minY) {ypos = minY;}
       if (ypos > maxY) {ypos = maxY;}
     }
     else { //<>//
       xpos = entrancePosition[0];
       walkedIn = true;
     }
   }
  
   public void display(PImage img) {
     if (walkedIn) return;
     if (xpos <= mapPosition) return;
     // Update this to display the image
     image(img, xpos, ypos - 15, 15, 15);
   }
  
   public float getDistance() {
     return currDistX;
   }
}
