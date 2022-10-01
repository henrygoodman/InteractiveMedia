public class Person {
   float xpos, ypos;
   float xDiff, deltaX;
   float minY, maxY;
   float[] entrancePosition = new float[2];
   boolean walkedIn = false;
   float mapPosition;
   float size = random(4,8);
   int life = 0;
   
   public Person(Passage p) {
     entrancePosition[0] = p.position[0] + random(p.w/2);
     entrancePosition[1] = p.position[1];
     mapPosition = p.entrancePos;
     xpos = (float)(random(250) - 250) + p.entrancePos;
     ypos = (float)(p.h/3 + random(p.h/3) + entrancePosition[1]);
     xDiff = entrancePosition[0] - p.entrancePos;
     deltaX = xDiff * pollRate * 1.5/targetFrames;
     minY = entrancePosition[1] + 10;
     maxY = minY + p.h - 10;
   }
   
   public void move() {
     if (!walkedIn) {
       walkIn();
     }
   }
  
   //This will update the x position by a factor whereby after the amount of frames before the next update, it will be at the entrance...
   public void walkIn() {
     if (walkedIn) {return;}
     float currDistX = xDiff - (xpos - mapPosition);
     
     if (Math.abs(currDistX) >= 2) {
       xpos += deltaX;// + random(-2, 2);
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
  
}
