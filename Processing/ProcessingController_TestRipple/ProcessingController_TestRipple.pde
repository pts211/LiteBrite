/* ProcessingController
 * Author: Paul Sites (paul.sites@cerner.com)
 * 
 *
 * This is software used to control the LiteBrite created for DevCon 2019.
 */
//Display Size 
final int SCREEN_WIDTH = 900;
final float ASPECT_RATIO = float(PegGrid.GRID_W)/float(PegGrid.GRID_H);

//Port to listen to for button presses.
final int INPUT_PORT = 6000;

// import UDP library
import hypermedia.net.*;
import gifAnimation.*;

PegGrid grid;

UDP udp;  // Receive button presses over UDP.
OPC opc;  // Connect to FadeCandy lights via OPC.

//Store a few default transistions.
AnimatedTransistion pac;
Gif pacman;
AnimatedTransistion blink;
Gif blinky;

//Image loading
int currentImg = -1;
boolean hasDrawn = false;
PImage[] imgs;


//Ripples
int cols;
int rows;
float[][] current;// = new float[cols][rows];
float[][] previous;// = new float[cols][rows];

int dropsize = 50;
float flow = 20;
float dampening = 0.999;
int speed = 4;


//UserScreen userScreen;
void setup()
{
  size(SCREEN_WIDTH, int(SCREEN_WIDTH/ASPECT_RATIO), P3D); //Don't even think about doing a print statement before this.
  colorMode(HSB, 100);
  frameRate(30);
  println("Controller: Initializing Display Parameters. Done.");

  grid = new PegGrid(this, "127.0.0.1", 7890);
  
  initNetworking();
  loadImages();
  
  pacman = new Gif(this, "/Users/ps022648/Desktop/DevCon/GIT/LiteBrite/Processing/ProcessingController/animated/pacman-animation-crop-tail.gif");
  pac = new AnimatedTransistion(pacman, 3, false);

  blinky = new Gif(this, "/Users/ps022648/Desktop/DevCon/GIT/LiteBrite/Processing/ProcessingController/animated/blinky-animation-crop.gif");
  blink = new AnimatedTransistion(blinky, 3, true);

  //Test receiving a message.
  /*
  processMessage("192.168.1.1", "10000001000000000000001000000000000000");
  processMessage("192.168.1.2", "10000001000000000000001000000000000000");
  processMessage("192.168.1.3", "10000001000000000000001000000000000000");
  processMessage("192.168.1.4", "10000001000000000000001000000000000000");
  processMessage("192.168.1.5", "10000001000000000000001000000000000000");
  */
  
  //userScreen = new UserScreen();
  
  //Ripples
  cols = width;
  rows = height;
  current = new float[cols][rows];
  previous = new float[cols][rows];
}

void initNetworking()
{
  println("Controller: Initializing Network.");
  //Configure network.
  udp = new UDP( this, INPUT_PORT);
  udp.log( true );     // <-- printout the connection activity
  udp.listen( true );

  println("Controller: Initializing Network. Done.");
}

void initDisplay()
{
  println("Controller: Initializing Display Parameters.");
  size(SCREEN_WIDTH, int(SCREEN_WIDTH/ASPECT_RATIO), P3D);
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

  if (pac.isPlaying()) {
    pac.draw();
    grid.loadImg();
  }

  if (blink.isPlaying()) {
    blink.draw();
    grid.loadImg();
  }

  //We only want to draw the image to the screen once to load the image data into
  //the pegs. That way the image can be changed by clicking a peg.
  if (currentImg != -1 && !hasDrawn) {

    //If we load a saved LiteBrite image then we don't ant to scale it.
    PImage img = imgs[currentImg];
    float img_aspect = float(img.width)/float(img.height);
    img.resize(width, height);
    
    imageMode(CENTER);
    image(img, width/2, height/2);
    hasDrawn = true;
    grid.loadImg();
  }
  processRipple();
  
  println("fps: " + frameRate);
}

// ****************************************
// ****************************************
//        Input Handlers
// ****************************************
// ****************************************
void mousePressed()
{ 
  grid.mousePressed(mouseX, mouseY);
  
  previous[mouseX][mouseY] = 40 * dropsize;
}

void keyPressed()
{
  switch(key)
  {
  case 'c':
    pac.start();
    break;
  case 'C':
    blink.start();
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
    break;
  case 'S':  
    saveFrame();
    println("Saving image.");
    break;
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
  for (int x = 0; x < PegGrid.GRID_W; x++)
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

float dampening(float flow) {
  return (1 / (1 + pow((float)Math.E, -(flow/5))));
}

void processRipple()
{
  
  for (int s = 1; s <= speed; s++){
    loadPixels();
    for (int i = 1; i < cols-1; i++) {
      for (int j = 1; j < rows-1; j++) {
        current[i][j] = (
          previous[i-1][j] + 
          previous[i+1][j] +
          previous[i][j-1] + 
          previous[i][j+1]) / 2 -
          current[i][j];
        current[i][j] *= dampening(flow);
        int index = i + j * cols;
        pixels[index] = color(current[i][j]);
      }
    }
    updatePixels();
    float[][] temp = previous;
    previous = current;
    current = temp;
  }
   
}