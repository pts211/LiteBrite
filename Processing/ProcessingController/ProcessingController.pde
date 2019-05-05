//This is a sketch to control the LiteBrite created for DevCon 2019.
//Author: Paul Sites (ps022648)

OPC opc;
PImage texture;
PImage dot;

final int GRID_W = 38;
final int GRID_H = 24;
int i = 0;

Peg[] pegs = new Peg[GRID_W*GRID_H];

void setup()
{
  size(900, 600, P3D);
  colorMode(HSB, 100);
  texture = loadImage("ring.png");
  
  dot = loadImage("dot.png");
  
  opc = new OPC(this, "127.0.0.1", 7890);
  opc.showLocations(true);
  
  //frameRate(60);

  opc.ledGrid(0, GRID_W, GRID_H, width/2.0, height/2.0, 20.0, 20.0, 0, true);

  for (int i = 0; i < pegs.length; i++) {
      Point p = opc.getLocationByIndex(i);
      pegs[i] = new Peg(p);
      println("peg[" + i + "]: ( " + pegs[i].getX() + ", " + pegs[i].getY() + " )");
  }
}

void mousePressed()
{ 
  Point mP = new Point(mouseX, mouseY);
  for (int i = 0; i < pegs.length; i++) {
    Point pP = pegs[i].getPoint();
    
    if(containmentCheck(mP, pP)){
      println("Clicked peg " + i + " !"); 
      pegs[i].nextColor();
    }
  }
}

boolean containmentCheck(Point p1, Point p2)
{
  //if d^2 <= r^2 we're in the circle. Via Pythagorean theorem
  //d^2 = (p1.x - p2.x)^2 + (p1.y - p2.y)^2 
  
  int px = (p1.getX() - p2.getX());
  int py = (p1.getY() - p2.getY());
  
  int r2 = 10*10;
  int d2 = (px*px) + (py*py);
  
  if(d2 <= r2){
    return true;
  }else{
    return false; 
  }
}

void drawRing(float x, float y, float hue, float intensity, float size) {
  blendMode(ADD);
  tint(hue, 50, intensity);
  image(texture, x - size/2, y - size/2, size, size);
}

void draw()
{
  background(0);
  for (int i = 0; i < pegs.length; i++) {
      pegs[i].draw();
  }
  //opc.setPixel(20, color(0, 0, 255));
  //opc.writePixels();
  
  
  // Draw the image, centered at the mouse location
  //float dotSize = width * 0.2;
  //image(dot, mouseX - dotSize/2, mouseY - dotSize/2, dotSize, dotSize);
  
  

  // Draw each frame here
  //drawRing(mouseX, mouseY, 25, 80, 400);
}
