public class DesktopViewer
{
  Robot robot;
  Rectangle r;

  DesktopViewer(int width, int height) {
    try {
      robot = new Robot();
    } 
    catch (Exception e) {
      println(e.getMessage());
    }
    
    r = new Rectangle(0, 0, width, height);
  }
  
  void draw()
  {
    BufferedImage img1 = robot.createScreenCapture(r);
    PImage img = new PImage(img1);
    image(img, 0, 0);
  }
  
}
