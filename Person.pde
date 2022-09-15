public class Person {
   float xpos, ypos;
   float xDiff, deltaX;
   float minY, maxY;
   float[] entrancePosition;
   boolean walkedIn = false;
   color personColor = color(255, 120, 0, random(100, 200));
   float size = random(4,8);
   int life = 0;
   
   public Person(Passage p) {
     entrancePosition = p.position;
     xpos = (float)(random(250) - 250);
     ypos = (float)(p.h/3 + random(p.h/3) + entrancePosition[1]);
     xDiff = entrancePosition[0] + random(p.w);
     deltaX = xDiff * pollRate/targetFrames;
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
     float currDistX = xDiff - xpos;
     
     if (Math.abs(currDistX) >= 2) {
       xpos += deltaX;
       ypos += random(-3, 3);
       if (ypos < minY) {ypos = minY;}
       if (ypos > maxY) {ypos = maxY;}
     }
   //<>//
     if (xpos + 5 > xDiff) {
       xpos = xDiff;
       walkedIn = true;
     }
   }
  
   public void display() { 
     // Update this to display the image
     noStroke();
     fill(personColor);
     ellipse(xpos, ypos, size, size);
   }
  
}
