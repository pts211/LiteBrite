public class Peg
{

  int DIAMETER = 20;
  Point p;
  color c;
  float hue;
  float brightness;

  Peg(Point p) {
    this.p = p;
    this.c = Colors.BLACK;
    this.brightness = 1.0;
  }

  Peg(Point p, int dia) {
    this.p = p;
    this.c = Colors.BLACK;
    this.DIAMETER = dia;
    this.brightness = 1.0;
  }
  
  Peg(Peg p) {
    this.p = p.p;
    this.c = p.c;
    this.DIAMETER = p.DIAMETER;
    this.brightness = p.brightness;
  }

  Point getPoint()
  {
    return this.p;
  }

  int getX()
  {
    return this.p.getX();
  }

  int getY()
  {
    return this.p.getY();
  }

  color getColor()
  {
    return this.c;
  }

  int getColorAsInt()
  {
    switch(this.c)
    {
    case Colors.RED:
      println("RED");
      return 1;
    case Colors.GREEN:
      println("GREEN");
      return 2;
    case Colors.BLUE:
      println("BLUE");
      return 3;
    case Colors.MAGENTA:
      println("MAGENTA");
      return 4;
    case Colors.YELLOW:
      println("YELLOW");
      return 5;
    case Colors.CYAN:
      println("CYAN");
      return 6;
    case Colors.WHITE:
      println("WHITE");
      return 7;
    case Colors.BLACK:
      println("BLACK");
      return 0;
    default:
      return -1;
    }
  }
  

  float getColorAsHue()
  {
    return hue(this.c);
  }

  void setColor(color c)
  {
    this.c = c;
  }

  void setHue(float hue)
  {
    this.hue = hue;
    //colorMode(HSB, 100, 255, 255);
    //this.c = color(hue, 0, 255);
    //colorMode(RGB, 255);
  }

  void nextColor()
  {
    this.c = Colors.nextColor(this.c);
  }

  void setBrigthness(int brightness)
  {
    brightness = constrain(brightness, 0, 100);
    this.brightness = brightness / 100.0;
  }

  color calcColor()
  {
    float r = red  (this.c);
    float g = green(this.c);
    float b = blue (this.c);

    // That multiplier changes the RGB value of each pixel.      
    r *= brightness;
    g *= brightness;
    b *= brightness;

    // The RGB values are constrained between 0 and 255 before being set as a new color.      
    r = constrain(r, 0, 205); 
    g = constrain(g, 0, 205);
    b = constrain(b, 0, 205);

    return color(r, g, b);
  }

  void drawHue()
  {
    pushMatrix();
    pushStyle();

    fill(this.hue);

    stroke(#ffffff);
    ellipse(p.getX(), p.getY(), DIAMETER, DIAMETER);
    //stroke(#ffffff);
    //arc(p.getX(), p.getY(), DIAMETER, DIAMETER, 0, 2*3.14159);
    popMatrix();
    popStyle();
  }

  void draw()
  {
    pushMatrix();
    pushStyle();

    color dispColor = calcColor();
    fill(dispColor);

    stroke(#ffffff);
    ellipse(p.getX(), p.getY(), DIAMETER, DIAMETER);
    //stroke(#ffffff);
    //arc(p.getX(), p.getY(), DIAMETER, DIAMETER, 0, 2*3.14159);
    popMatrix();
    popStyle();
  }
}
