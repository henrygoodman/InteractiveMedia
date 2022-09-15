// This class implements the map floor plan. It is simply an image/shape that we may define the co-ordinates of 2 'entrances'.
// We determine the position of the entrances regardless of image size by scaling the position and the image by the same scale factor.

public class Map {

  
  // Default constructor, draws a rectangle of width * height in the middlish of the screen.
  public Map() {
  }
  
  public void display() {
      fill(255);
      rect(0, height/4, width, height/2);
  }
  
  
}
