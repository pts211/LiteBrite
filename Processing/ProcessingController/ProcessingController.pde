//This is a sketch to control the LiteBrite created for DevCon 2019.
//Author: Paul Sites (ps022648)



// import UDP library
import hypermedia.net.*;

UDP udp;  // define the UDP object

OPC opc;
PImage texture;
PImage dot;

final int GRID_W = 38;
final int GRID_H = 24;
int i = 0;

Peg[] pegs = new Peg[GRID_W*GRID_H];

void setup()
{
  //Configure network.
  udp = new UDP( this, 5400 );
  //udp.log( true );     // <-- printout the connection activity
  udp.listen( true );
  
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
  
  processMessage("192.168.1.4", "10000001000000000000001000000000000000");
}

int getIndexAtPoint(int x, int y)
{
  if( (x < GRID_W) && (y < GRID_H) ){
    return x + GRID_W * y;
  }
  return -1;
}

void mousePressed()
{ 
  Point mP = new Point(mouseX, mouseY);
  for (int i = 0; i < pegs.length; i++) {
    Point pP = pegs[i].getPoint();
    
    if(containmentCheck(mP, pP, Peg.DIAMETER/2)){
      println("Clicked peg " + i + "."); 
      pegs[i].nextColor();
    }
  }
}

boolean containmentCheck(Point p1, Point p2, int radius)
{
  //if d^2 <= r^2 we're in the circle. Via Pythagorean theorem
  //d^2 = (p1.x - p2.x)^2 + (p1.y - p2.y)^2 
  
  int px = (p1.getX() - p2.getX());
  int py = (p1.getY() - p2.getY());
  
  int r2 = radius*radius;
  int d2 = (px*px) + (py*py);
  
  if(d2 <= r2){
    return true;
  }
  return false;
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


/**
 * To perform any action on datagram reception, you need to implement this 
 * handler in your code. This method will be automatically called by the UDP 
 * object each time he receive a nonnull message.
 * By default, this method have just one argument (the received message as 
 * byte[] array), but in addition, two arguments (representing in order the 
 * sender IP address and his port) can be set like below.
 */
// void receive( byte[] data ) {       // <-- default handler
void receive( byte[] data, String ip, int port )  // <-- extended handler
{
  // get the "real" message =
  // forget the ";\n" at the end <-- !!! only for a communication with Pd !!!
  data = subset(data, 0, data.length-1);
  String message = new String( data );
  
  // print the result
  println( "receive: \""+message+"\" from "+ip+" on port "+port );
    
  processMessage(ip, message);
}


void processMessage(String ip, String message)
{
  String ystr = ip.substring(ip.lastIndexOf('.')+1, ip.length());
  int yidx = Integer.parseInt(ystr);
  println("yidx: " + yidx);
  
  message = message.trim();
  
  for(int x = 0; x < message.length(); x++)
  {
    if(Integer.parseInt(String.valueOf(message.charAt(x))) == 1){
       int idx = getIndexAtPoint(x, yidx);
       pegs[idx].nextColor();
       println("Updating peg: " + idx);
    }
    //println("x: " + x + " val: " + message.charAt(i)); 
  }
  
}
