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
    pushMatrix();
    pushStyle();

    BufferedImage img1 = robot.createScreenCapture(r);
    PImage img = new PImage(img1);
    img.resize(width, height);
    imageMode(CENTER);
    image(img, width/2, height/2);


    popMatrix();
    popStyle();
  }
}
