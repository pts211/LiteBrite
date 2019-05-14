/* ProcessingController
 * Author: Paul Sites (paul.sites@cerner.com)
 * 
 *
 * This is software used to control the LiteBrite created for DevCon 2019.
 */

// import UDP library
import hypermedia.net.*;

PegGrid grid;

UDP udp;  // define the UDP object

OPC opc;
PImage texture;
PImage dot;

final int GRID_W = 38;
final int GRID_H = 24;

Peg[] pegs = new Peg[GRID_W*GRID_H];

//Image loading

int currentImg = -1;
boolean hasDrawn = false;
PImage[] imgs;

void setup()
{
  initNetworking();
  initDisplay();  
  loadImages();

  //Test receiving a message.
  processMessage("192.168.1.1", "10000001000000000000001000000000000000");
  processMessage("192.168.1.2", "10000001000000000000001000000000000000");
  processMessage("192.168.1.3", "10000001000000000000001000000000000000");
  processMessage("192.168.1.4", "10000001000000000000001000000000000000");
  processMessage("192.168.1.5", "10000001000000000000001000000000000000");
}

void initNetworking()
{
  println("Controller: Initializing Network.");
  //Configure network.
  udp = new UDP( this, 6000);
  //udp.log( true );     // <-- printout the connection activity
  udp.listen( true );
  
  println("Controller: Initializing Network. Done.");
}

void initDisplay()
{
  println("Controller: Initializing Display Parameters.");
  size(900, 600, P3D);
  colorMode(HSB, 100);

  grid = new PegGrid(this, "127.0.0.1", 7890);
  
  println("Controller: Initializing Display Parameters. Done.");
}

void loadImages()
{
  println("Controller: Loading Images.");
  //Image loading
  String path = "/Users/ps022648/Desktop/DevCon/GIT/LiteBrite/Processing/ProcessingController/images";
  println("\tpath: " + path);
  String[] filenames = listFileNames(path);
  printArray(filenames);

  imgs = new PImage[filenames.length];
  for (int i = 0; i < filenames.length; i++) {
    imgs[i] = loadImage(path+"/"+filenames[i]);
  }
  println("Controller: Loading Images. Done.");
}

void draw()
{
  background(0);
  grid.draw();


  //We only want to draw the image to the screen once to load the image data into
  //the pegs. That way the image can be changed by clicking a peg.
  if (currentImg != -1 && !hasDrawn) {
    imageMode(CENTER);
    image(imgs[currentImg], width/2, height/2, width/1.25, height/1.25);
    hasDrawn = true;
    grid.loadImg();
  }
}

// ****************************************
// ****************************************
//        Input Handlers
// ****************************************
// ****************************************
void mousePressed()
{ 
  grid.mousePressed(mouseX, mouseY);
}

void keyPressed()
{
  switch(key)
  {
  case 'c':
    grid.setAllOff();
    break;
  case 'r':
    grid.setAll(Colors.RED);
    break;
  case 'g':
    grid.setAll(Colors.GREEN);
    break;
  case 'b':
    grid.setAll(Colors.BLUE);
    break;
  case 'w':
    grid.setAll(Colors.WHITE);
    break;
  case 'q':
    grid.setAllRandom();
    break;
  case 'n':
    nextImage();
  default:
    break;
  }
}

// ****************************************
// ****************************************
//        Network Methods
// ****************************************
// ****************************************

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
  int yidx = Integer.parseInt(ystr) - 1; //Change IP range to start at 1. 
  //println("yidx: " + yidx);

  message = message.trim();

  //TODO Was using message.length, make sure that using the GRID_W works.
  for (int x = 0; x < GRID_W; x++)
  {
    if (Integer.parseInt(String.valueOf(message.charAt(x))) == 1) {
      grid.nextColorAtCoord(x, yidx);
    }
  }
}

// ****************************************
// ****************************************
//        Image Methods
// ****************************************
// ****************************************
String[] listFileNames(String dir) {
  File file = new File(dir);
  if (file.isDirectory()) {
    String names[] = file.list();
    return names;
  } else {
    return null;
  }
}

void nextImage()
{
  currentImg++;
  if (currentImg >= imgs.length) {
    currentImg = -1;
  }
  hasDrawn = false;
}
