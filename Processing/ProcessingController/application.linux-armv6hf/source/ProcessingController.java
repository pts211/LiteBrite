import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.awt.Robot; 
import java.awt.image.BufferedImage; 
import java.awt.Rectangle; 
import hypermedia.net.*; 
import gifAnimation.*; 
import g4p_controls.*; 
import peasy.*; 
import java.util.Random; 
import java.net.*; 
import java.util.Arrays; 
import java.io.*; 
import java.util.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class ProcessingController extends PApplet {

/* ProcessingController
 * Author: Paul Sites (paul.sites@cerner.com)
 * 
 *
 * This is software used to control the LiteBrite created for DevCon 2019.
 */
//Display Size 
final int SCREEN_WIDTH = 900;
final float ASPECT_RATIO = PApplet.parseFloat(PegGrid.GRID_W)/PApplet.parseFloat(PegGrid.GRID_H);

//Port to listen to for button presses.
final int INPUT_PORT = 6000;

Configuration config;

//Desktop Display




// import UDP library


// Need G4P library

// You can remove the PeasyCam import if you are not using
// the GViewPeasyCam control or the PeasyCam library.


PegGrid grid;

UDP udp;  // Receive button presses over UDP.
OPC opc;  // Connect to FadeCandy lights via OPC.

//Store a few default transistions.
AnimatedTransistion pac;
Gif pacman;
AnimatedTransistion blink;
Gif blinky;
Gif coffee;

//Image loading
int currentImg = -1;
boolean hasDrawn = false;
PImage[] imgs;

//Ripples
RippleGenerator ripGen;

//Desktop Viewer
DesktopViewer desktop;

//Loading Sequence
LoadingBar loadingBar;

//Scrolling Text
ScrollingText title;

//Screensaver
Screensaver screensaver;

Clock clock;
Timer idleTimer;

public void settings() {
  size(SCREEN_WIDTH, PApplet.parseInt(SCREEN_WIDTH/ASPECT_RATIO)); //Don't even think about doing a print statement before this.
}

public void setup()
{
  colorMode(RGB, 100);
  //frameRate(30);
  println("Controller: Initializing Display Parameters. Done.");
  grid = new PegGrid(this, "127.0.0.1", 7890);

  clock = new Clock();

  initNetworking();
  loadImages();

  pacman = new Gif(this, "/home/robot/Desktop/LiteBrite/Processing/ProcessingController/animated/pacman-animation-crop-tail.gif");
  pac = new AnimatedTransistion(pacman, 3, false);

  blinky = new Gif(this, "/home/robot/Desktop/LiteBrite/Processing/ProcessingController/animated/blinky-animation-crop.gif");
  blink = new AnimatedTransistion(blinky, 3, true);

  coffee = new Gif(this, "/home/robot/Desktop/LiteBrite/Processing/ProcessingController/animated/coffee_crop_invert_wide.gif");
  coffee.loop();  
  coffee.play();



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
  ripGen = new RippleGenerator(400);

  createGUI();
  customGUI();
  config = new Configuration();

  desktop = new DesktopViewer(SCREEN_WIDTH, PApplet.parseInt(SCREEN_WIDTH/ASPECT_RATIO));

  loadingBar = new LoadingBar();

  //screensaver = new Screensaver("/home/robot/Desktop/timelapses/csv_data/historyWhiteTest.txt");
  //screensaver = new Screensaver("/home/robot/Desktop/timelapses/csv_data/testHistory02.txt");
  //screensaver = new Screensaver("/home/robot/Desktop/timelapses/csv_data/history66142011166.txt");
  screensaver = new Screensaver("/home/robot/Desktop/timelapses/csv_data/history66123749157.txt");  //PAC MAN ghosts
  //screensaver = new Screensaver("/home/robot/Desktop/timelapses/csv_data/historyWhiteTest.txt");
  //screensaver = new Screensaver("");
  //screensaver = new Screensaver("");
  //screensaver = new Screensaver("");
  screensaver.setPegs(grid.getPegs());

  idleTimer = new Timer(5000);
  idleTimer.start();

  //config.loadingSequenceEnabled = true;
  //startLoadingSequence();

  title = new ScrollingText();
}

public void initNetworking()
{
  println("Controller: Initializing Network.");
  //Configure network.

  udp = new UDP( this, INPUT_PORT);
  udp.log( true );     // <-- printout the connection activity
  udp.listen( true );
  println("Controller: Initializing Network. Done.");
  println("Controller: Initializing Network. Done.");
}

public void loadImages()
{
  println("Controller: Loading Images.");
  //Image loading
  String path = "/home/robot/Desktop/LiteBrite/Processing/ProcessingController/images";
  println("\tpath: " + path);
  String[] filenames = listFileNames(path);
  printArray(filenames);

  imgs = new PImage[filenames.length];
  for (int i = 0; i < filenames.length; i++) {
    imgs[i] = loadImage(path+"/"+filenames[i]);
  }
  println("Controller: Loading Images. Done.");
}

public void draw()
{
  if (idleTimer.update()) {
    config.isIdle = true;
  }
  if (config.isIdle) {
    clock.processTriggers();
  }
  if (config.isSleeping)
  {
    background(0);
    return;
  }


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
    img.resize(width, height);

    imageMode(CENTER);
    image(img, width/2, height/2);
    hasDrawn = true;
    grid.loadImg();
  }


  if (config.rippleEnabled) {
    ripGen.draw();
  }
  if (config.showDesktop) {
    desktop.draw();
  }
  if (config.randomPegsEnabled) {
    randomPegs();
  }
  if (config.loadingSequenceEnabled) {
    loadScreen();
  }
  if (config.rainbowEnabled) {
    rainbowCycle();
  }
  if (config.isMorning && config.isIdle)
  {
    image(coffee, width/2  - coffee.width*3/2, height / 2 - coffee.height*3/2, coffee.width * 3, coffee.height * 3);
  } else if ( config.isIdle )
  {
    randomPegsScreensaver();
    screensaver.draw();
  }

  title.draw();
}

// ****************************************
// ****************************************
//        Input Handlers
// ****************************************
// ****************************************
public void mousePressed()
{ 
  idleTimer.reset();
  if (config.isIdle || config.isSleeping) {
    config.isIdle = false;
    config.isSleeping = false;
    return;
  }


  Peg peg = grid.mousePressed(mouseX, mouseY);

  if ( peg != null) {
    if (config.captureUsageEnabled) {
      screenshot();
    }
    if (config.write_csv) {
      grid.writeState();
    }
    if (config.rippleEnabled) {
      ripGen.addRipple(peg.getPoint(), peg.getColor());
    }
  }
}

public void keyPressed()
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
  case 'o':
    grid.setAll(Colors.BLACK);
    break;
  case 'S':  
    saveFrame();
    //String timestamp = str(month()) + str(day()) + str(hour()) + str(minute()) + str(second());
    //saveFrame("timelapse-"+timestamp + ".png");
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
public void receive( byte[] data, String ip, int port )  // <-- extended handler
{
  // get the "real" message =
  // forget the ";\n" at the end <-- !!! only for a communication with Pd !!!
  data = subset(data, 0, data.length-1);
  String message = new String( data );

  // print the result
  println( "receive: \""+message+"\" from "+ip+" on port "+port );

  processMessage(ip, message);
}

public void processMessage(String ip, String message)
{
  idleTimer.reset();
  if (config.isIdle || config.isSleeping) {
    config.isIdle = false;
    config.isSleeping = false;
    return;
  }
  String ystr = ip.substring(ip.lastIndexOf('.')+1, ip.length());
  int yidx = Integer.parseInt(ystr) - 1; //Change IP range to start at 1. 
  //println("yidx: " + yidx);

  message = message.trim();

  //TODO Was using message.length, make sure that using the GRID_W works.
  for (int x = 0; x < PegGrid.GRID_W + 1; x++)
  {
    if (Integer.parseInt(String.valueOf(message.charAt(x))) == 1 && x < PegGrid.GRID_W ) {
      println("x:" + x);
      if (message.contains("c")) {
        grid.setRow(yidx, Colors.BLACK);
        grid.nextColorAtCoord(x, yidx);
        grid.nextColorAtCoord(x, yidx);
      } else if (config.usePaintColor) {
        grid.setColorAtCoord(x, yidx, config.paintColor);
      } else {
        grid.nextColorAtCoord(x, yidx);
      }
      if (config.captureUsageEnabled) {
        screenshot();
      }
      if (config.write_csv) {
        grid.writeState();
      }
    }
    if (yidx == 9 && (Integer.parseInt(String.valueOf(message.charAt(38))) == 1)) {
      println("CLEAR BUTTON PRESSED!");
      pac.start();
    }
  }
  //if(message.length()
}

// ****************************************
// ****************************************
//        Image Methods
// ****************************************
// ****************************************
public String[] listFileNames(String dir) {
  File file = new File(dir);
  if (file.isDirectory()) {
    String names[] = file.list();
    return names;
  } else {
    return null;
  }
}

public void nextImage()
{
  currentImg++;
  if (currentImg >= imgs.length) {
    currentImg = -1;
  }
  hasDrawn = false;
}

public void screenshot()
{  
  String timestamp = str(month()) + str(day()) + str(hour()) + str(minute()) + str(second()) + str(millis());
  saveFrame("timelapses/"+str(month()) + str(day()) + "/timelapse-##########-"+timestamp + ".png");
}

// ****************************************
// ****************************************
//        GUI Methods
// ****************************************
// ****************************************
// Use this method to add additional statements
// to customise the GUI controls
public void customGUI() {
}

// Update the view graphic
public void updatePaintColorView(int newcolor) {
  PGraphics v = paintColor_view.getGraphics();
  v.beginDraw();
  v.background(newcolor);
  v.endDraw();
}

public class AnimatedTransistion
{
  Gif gif;
  int totalDist;
  int startPos;
  int speed;
  boolean reversed;

  float duration;

  int currentPos;

  boolean isPlaying = false;


  AnimatedTransistion(Gif gif, float duration, boolean reversed) {
    this.gif = gif;
    this.duration = duration;
    this.reversed = reversed;

    if (reversed) {
      this.startPos = gif.width *2;
    } else {
      this.startPos = -gif.width *2;
    }
    this.currentPos = startPos;

    totalDist = Math.abs(startPos) + width;

    //println("total distance is:" + totalDist);
  }

  public void setDuration(float duration)
  {
    this.duration = duration;
  }

  public boolean isPlaying()
  {
    return isPlaying;
  }

  public void start()
  {
    //30fps
    //dist 1760
    speed = PApplet.parseInt(totalDist/(frameRate*duration));
    if (reversed) {
      speed *= -1;
    }
    println("framerate: " + frameRate);
    println("speed: " + speed);
    gif.play();
    isPlaying = true;
  }

  public void reset()
  {
    isPlaying = false;
    currentPos = startPos;
    gif.stop();
  }

  public void draw()
  {
    pushMatrix();
    pushStyle();
    imageMode(CORNER);
    image(gif, currentPos, 0, width, height);
    currentPos += speed;

    if (currentPos > width && !reversed) {
      reset();
    } else if ( currentPos < (-gif.width*2) && reversed) {
      reset();
    }
    popMatrix();
    popStyle();
  }
}

public class Clock
{
  int hour, minute, second;

  Clock() {
    hour = hour();
    minute = minute();
    second = second();
    
  }
  
  
  private void update()
  {
    hour = hour();
    minute = minute();
    second = second();
  }
  
  public void processTriggers()
  {
    update();
    if( hour >= 18 && hour < 24 || hour < 6)
    {
      //NIGHT TIME - Sleep
      config.isSleeping = true;   
    }else{
      config.isSleeping = false;
    }
    
    if( hour >= 6 && hour < 9 )
    {
      config.isMorning = true;   
    }
    
    
    
    
  }

}


public static class Colors
{
  private static Random rand = new Random();

  public final static int RED = 0xffff0000;
  public final static int GREEN = 0xff00ff00;
  public final static int BLUE = 0xff0000ff;
  public final static int MAGENTA = 0xffff00ff;
  public final static int YELLOW = 0xffffff00;
  public final static int CYAN = 0xff00ffff;
  public final static int WHITE = 0xffffffff;
  public final static int BROWN = 0xffb76c09;
  public final static int BLACK = 0xff000000;  

  Colors() {
  }

  public static int nextColor(int current)
  {
    switch(current)
    {
    case RED:
      return GREEN;
    case GREEN:
      return BLUE;
    case BLUE:
      return MAGENTA;
    case MAGENTA:
      return YELLOW;
    case YELLOW:
      return CYAN;
    case CYAN:
      return WHITE;
    case WHITE:
      return BROWN;
    case BROWN:
      return BLACK;
    case BLACK:
      return RED;
    default:
      return Colors.WHITE;
    }
  }
  
  public static String getColorAsString(int input)
  {
    switch(input)
    {
    case RED:
      return "RED";
    case GREEN:
      return "GREEN";
    case BLUE:
      return "BLUE";
    case MAGENTA:
      return "MAGENTA";
    case YELLOW:
      return "YELLOW";
    case CYAN:
      return "CYAN";
    case WHITE:
      return "WHITE";
    case BROWN:
      return "BROWN";
    case BLACK:
      return "BLACK";
    default:
      return "INVALID";
    }
  }

  public static int randomColor()
  {
    int n = rand.nextInt(8);

    switch(n)
    {
    case 1:
      return GREEN;
    case 2:
      return BLUE;
    case 3:
      return MAGENTA;
    case 4:
      return YELLOW;
    case 5:
      return CYAN;
    case 6:
      return WHITE;
    case 7:
      return BLACK;
    case 8:
      return RED;
    default:
      return Colors.WHITE;
    }
  }
}

public class Configuration
{
  public boolean isIdle = false;
  public boolean isSleeping = false;
  public boolean isMorning = false;
  
  public boolean loadingSequenceEnabled = false;

  public boolean rippleEnabled = false;
  public boolean showDesktop = false;
  
  
  public boolean randomPegsEnabled = false;
  public int randomPegSpeed = 1000;
  
  public boolean rainbowEnabled = false;
  public float rainbowSpeed = 0;
  
  public boolean scrollingTextLoopEnabled = false;
  
  public int scrollSpeed = 1;
  public int textX = 0;
  public int textY = 0;
  public int textS = 0;
  
  
  public boolean captureUsageEnabled = false;
  public boolean write_csv = true;
  
  public boolean usePaintColor = false;
  public int paintColor;
  
  public boolean nextFrame = false;
  
  Configuration() {
  }
}
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

  public void draw()
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
Timer randomPegTimer = new Timer(200);

public void randomPegs()
{
  randomPegTimer.setInterval(config.randomPegSpeed);

  if (randomPegTimer.update()) {
    grid.setAllRandom();
  }
}

public void randomPegsScreensaver()
{
  randomPegTimer.setInterval(config.randomPegSpeed);

  if (randomPegTimer.update()) {
    screensaver.setAllRandom();
  }
}

public void startLoadingSequence()
{
  loadingBar.reset();
  loadingBar.start();
  actionTimer.start();
}

Timer actionTimer = new Timer(400);
public void loadScreen()
{
  if (loadingBar.isLoading()) {
    loadingBar.draw();
    actionTimer.reset();
  } else {
    if (actionTimer.update())
    {
      int ticks = actionTimer.getTicks();
      if (ticks < 8)
      {
        grid.setAllRandom();
      } else if (ticks == 8 && actionTimer.isEnabled()) {
        config.loadingSequenceEnabled = false;
        actionTimer.stop();
        grid.setAllOff();
        config.scrollSpeed = 20;
        title.start();
      } /*else if (!title.isRunning() && !actionTimer.isEnabled()){
       println("Starting timer");
       
       actionTimer.start();
       } else if (ticks >12) {
       config.loadingSequenceEnabled = false;
       grid.setAllOff();
       } else{
       grid.setAllRandom();
       }
       */
    }
  }
}

float rc;
public void rainbowCycle()
{
  rc = (rc >= 255) ? (0) : (rc + config.rainbowSpeed);

  colorMode(HSB, 255);
  for (int i=0; i < PegGrid.GRID_W; i++) {
    for (int j=0; j < PegGrid.GRID_H; j++) {
      grid.setColorAtCoord(i, j, color(rc, 255, 255));
    }
  }
  colorMode(RGB, 255);
}


public int Wheel(byte WheelPos) {
  if (WheelPos < 85) {
    return color(WheelPos * 3, 255 - WheelPos * 3, 0);
  } else if (WheelPos < 170) {
    WheelPos -= 85;
    return color(255 - WheelPos * 3, 0, WheelPos * 3);
  } else {
    WheelPos -= 170;
    return color(0, WheelPos * 3, 255 - WheelPos * 3);
  }
}



final double THRESHOLD = .01f;


public int getColorFromHue(float hue)
{
  String hueStr = nf(hue, 0, 3);
  int startColor = Colors.RED;
  int currentColor = startColor;
  //nf(hue(color(currentColor)), 0, 3);
  
  if(hue == 0)
  {
   return 0; 
  }
  
  do {
    //String currentColorStr = nf(hue(color(currentColor)), 0, 3);
    //println("currently comparing " + currentColorStr + " to " + hueStr);
    if(nf(hue(color(currentColor)), 0, 3).compareTo(hueStr) == 0 ){
      //println(Colors.getColorAsString(color(hue)) + " == " + Colors.getColorAsString(currentColor));
      //println("Returning " + Colors.getColorAsString(currentColor));
      return currentColor;
    }
    /*
    if (Math.abs(hue - hue(color(currentColor)) ) < THRESHOLD) {
      println(Colors.getColorAsString(color(hue)) + " == " + Colors.getColorAsString(currentColor));
      //System.out.println("f1 and f2 are equal using threshold\n");
      return currentColor;
    } else {
      //System.out.println("f1 and f2 are not equal using threshold\n");
      println(Colors.getColorAsString(color(hue)) + " != " + Colors.getColorAsString(currentColor));
    }
*/


    currentColor = Colors.nextColor(currentColor);
  } while (currentColor != startColor);
  return Colors.BLACK;
}

public int getColorFromEnum(int current)
  {
    switch(current)
    {
    case Colors.RED:
      return color(Colors.RED);
    case Colors.GREEN:
      return color(Colors.BLUE);
    case Colors.BLUE:
      return color(Colors.MAGENTA);
    case Colors.MAGENTA:
      return color(Colors.YELLOW);
    case Colors.YELLOW:
      return color(Colors.CYAN);
    case Colors.CYAN:
      return color(Colors.WHITE);
    case Colors.WHITE:
      return color(Colors.BROWN);
    case Colors.BROWN:
      return color(Colors.BLACK);
    case Colors.BLACK:
      return color(Colors.RED);
    default:
      return color(Colors.WHITE);
    }
  }
public class LoadingBar
{

  final int fontSize = 220;
  final int offsetX = 13;
  final int offsetY = 9;

  PFont dotMatrix;

  int totalDist;
  int startPos;

  int speed;
  boolean reversed;
  float duration;

  int currentPos;

  boolean isPlaying = false;
  boolean isLoading = false;

  int count = 0;
  int nextAction = 0;
  int holdCounts = 10;


  int percent;

  Timer timer;


  LoadingBar() {
    timer = new Timer(65);
    this.percent = 0;

    //dotMatrix = createFont("DOTMATRI.TTF", 110);
    dotMatrix = createFont("DOTMBold.TTF", 110);

    this.duration = 5;
    this.reversed = false;

    if (reversed) {
      this.startPos = 0;
      this.totalDist = width;
    } else {
      this.startPos = width;
      this.totalDist = 0;
    }
    this.currentPos = startPos;
  }

  public void setDuration(float duration)
  {
    this.duration = duration;
  }

  public boolean isPlaying()
  {
    return isPlaying;
  }

  public void start()
  {
    isLoading = true;
  }

  public void stop()
  {
    isLoading = false;
  }

  public void reset()
  {
    isLoading = false;
    count = 0;
    percent = 0;
  }

  public boolean isLoading()
  {
    return isLoading;
  }

  public void draw()
  {
    pushMatrix();
    pushStyle();


    if (timer.update()) {
      count++;
      if(count < holdCounts+10){
        isLoading = true;
      }else if (percent < 100) {
        percent++;
        isLoading = true;
      } else if (percent == 100 && nextAction == 0) {
        nextAction = count + holdCounts;
      } else {
        if (count > nextAction) {
          isLoading = false;
        }
      }
    }
    rectMode(CORNER);
    fill(color(255, 0, 0));  // Set fill to white
    rect(0, 0, ((width/100)*percent), height);  // Draw white rect using CORNER mode

    textFont(dotMatrix);
    textSize(230); 
    textAlign(LEFT, CENTER);
    fill(color(255, 255, 255));  // Set fill to white
    text(percent+"%", (width/3)-30, (height/2.2f));
    /*
    else{
     rectMode(CORNER);
     fill(color(255, 0, 0));  // Set fill to white
     rect(0, 0, width, height);  // Draw white rect using CORNER mode
     
     textFont(dotMatrix);
     textSize(230); 
     textAlign(LEFT, CENTER);
     fill(color(255, 255, 255));  // Set fill to white
     text("DONE.", (width/3)-100, (height/2.2));
     }*/


    popMatrix();
    popStyle();
  }
}
/*
 * Simple Open Pixel Control client for Processing,
 * designed to sample each LED's color from some point on the canvas.
 *
 * Micah Elizabeth Scott, 2013
 * This file is released into the public domain.
 */




public class OPC
{
  Socket socket;
  OutputStream output;
  String host;
  int port;

  int[] pixelLocations;
  byte[] packetData;
  byte firmwareConfig;
  String colorCorrection;
  boolean enableShowLocations;

  OPC(PApplet parent, String host, int port)
  {
    this.host = host;
    this.port = port;
    this.enableShowLocations = true;
    //parent.registerDraw(this);
    parent.registerMethod("draw", this);
  }

  // Set the location of a single LED
  public void led(int index, int x, int y)  
  {
    // For convenience, automatically grow the pixelLocations array. We do want this to be an array,
    // instead of a HashMap, to keep draw() as fast as it can be.
    if (pixelLocations == null) {
      pixelLocations = new int[index + 1];
    } else if (index >= pixelLocations.length) {
      pixelLocations = Arrays.copyOf(pixelLocations, index + 1);
    }

    pixelLocations[index] = x + width * y;
  }

  // Set the location of several LEDs arranged in a strip.
  // Angle is in radians, measured clockwise from +X.
  // (x,y) is the center of the strip.
  public void ledStrip(int index, int count, float x, float y, float spacing, float angle, boolean reversed)
  {
    float s = sin(angle);
    float c = cos(angle);
    for (int i = 0; i < count; i++) {
      led(reversed ? (index + count - 1 - i) : (index + i), 
        (int)(x + (i - (count-1)/2.0f) * spacing * c + 0.5f), 
        (int)(y + (i - (count-1)/2.0f) * spacing * s + 0.5f));
    }
  }

  // Set the location of several LEDs arranged in a grid. The first strip is
  // at 'angle', measured in radians clockwise from +X.
  // (x,y) is the center of the grid.
  public void ledGrid(int index, int stripLength, int numStrips, float x, float y, 
    float ledSpacing, float stripSpacing, float angle, boolean zigzag)
  {
    float s = sin(angle + HALF_PI);
    float c = cos(angle + HALF_PI);
    for (int i = 0; i < numStrips; i++) {
      ledStrip(index + stripLength * i, stripLength, 
        x + (i - (numStrips-1)/2.0f) * stripSpacing * c, 
        y + (i - (numStrips-1)/2.0f) * stripSpacing * s, ledSpacing, 
        angle, zigzag && (i % 2) == 1);
    }
  }

  // Set the location of 64 LEDs arranged in a uniform 8x8 grid.
  // (x,y) is the center of the grid.
  public void ledGrid8x8(int index, float x, float y, float spacing, float angle, boolean zigzag)
  {
    ledGrid(index, 8, 8, x, y, spacing, spacing, angle, zigzag);
  }

  // Should the pixel sampling locations be visible? This helps with debugging.
  // Showing locations is enabled by default. You might need to disable it if our drawing
  // is interfering with your processing sketch, or if you'd simply like the screen to be
  // less cluttered.
  public void showLocations(boolean enabled)
  {
    enableShowLocations = enabled;
  }

  // Enable or disable dithering. Dithering avoids the "stair-stepping" artifact and increases color
  // resolution by quickly jittering between adjacent 8-bit brightness levels about 400 times a second.
  // Dithering is on by default.
  public void setDithering(boolean enabled)
  {
    if (enabled)
      firmwareConfig &= ~0x01;
    else
      firmwareConfig |= 0x01;
    sendFirmwareConfigPacket();
  }

  // Enable or disable frame interpolation. Interpolation automatically blends between consecutive frames
  // in hardware, and it does so with 16-bit per channel resolution. Combined with dithering, this helps make
  // fades very smooth. Interpolation is on by default.
  public void setInterpolation(boolean enabled)
  {
    if (enabled)
      firmwareConfig &= ~0x02;
    else
      firmwareConfig |= 0x02;
    sendFirmwareConfigPacket();
  }

  // Put the Fadecandy onboard LED under automatic control. It blinks any time the firmware processes a packet.
  // This is the default configuration for the LED.
  public void statusLedAuto()
  {
    firmwareConfig &= 0x0C;
    sendFirmwareConfigPacket();
  }    

  // Manually turn the Fadecandy onboard LED on or off. This disables automatic LED control.
  public void setStatusLed(boolean on)
  {
    firmwareConfig |= 0x04;   // Manual LED control
    if (on)
      firmwareConfig |= 0x08;
    else
      firmwareConfig &= ~0x08;
    sendFirmwareConfigPacket();
  } 

  // Set the color correction parameters
  public void setColorCorrection(float gamma, float red, float green, float blue)
  {
    colorCorrection = "{ \"gamma\": " + gamma + ", \"whitepoint\": [" + red + "," + green + "," + blue + "]}";
    sendColorCorrectionPacket();
  }

  // Set custom color correction parameters from a string
  public void setColorCorrection(String s)
  {
    colorCorrection = s;
    sendColorCorrectionPacket();
  }

  // Send a packet with the current firmware configuration settings
  public void sendFirmwareConfigPacket()
  {
    if (output == null) {
      // We'll do this when we reconnect
      return;
    }

    byte[] packet = new byte[9];
    packet[0] = 0;          // Channel (reserved)
    packet[1] = (byte)0xFF; // Command (System Exclusive)
    packet[2] = 0;          // Length high byte
    packet[3] = 5;          // Length low byte
    packet[4] = 0x00;       // System ID high byte
    packet[5] = 0x01;       // System ID low byte
    packet[6] = 0x00;       // Command ID high byte
    packet[7] = 0x02;       // Command ID low byte
    packet[8] = firmwareConfig;

    try {
      output.write(packet);
    } 
    catch (Exception e) {
      dispose();
    }
  }

  // Send a packet with the current color correction settings
  public void sendColorCorrectionPacket()
  {
    if (colorCorrection == null) {
      // No color correction defined
      return;
    }
    if (output == null) {
      // We'll do this when we reconnect
      return;
    }

    byte[] content = colorCorrection.getBytes();
    int packetLen = content.length + 4;
    byte[] header = new byte[8];
    header[0] = 0;          // Channel (reserved)
    header[1] = (byte)0xFF; // Command (System Exclusive)
    header[2] = (byte)(packetLen >> 8);
    header[3] = (byte)(packetLen & 0xFF);
    header[4] = 0x00;       // System ID high byte
    header[5] = 0x01;       // System ID low byte
    header[6] = 0x00;       // Command ID high byte
    header[7] = 0x01;       // Command ID low byte

    try {
      output.write(header);
      output.write(content);
    } 
    catch (Exception e) {
      dispose();
    }
  }

  // Automatically called at the end of each draw().
  // This handles the automatic Pixel to LED mapping.
  // If you aren't using that mapping, this function has no effect.
  // In that case, you can call setPixelCount(), setPixel(), and writePixels()
  // separately.
  public void draw()
  {
    if (pixelLocations == null) {
      // No pixels defined yet
      return;
    }

    if (output == null) {
      // Try to (re)connect
      connect();
    }
    if (output == null) {
      return;
    }

    int numPixels = pixelLocations.length;
    int ledAddress = 4;

    setPixelCount(numPixels);
    loadPixels();

    for (int i = 0; i < numPixels; i++) {
      int pixelLocation = pixelLocations[i];
      int pixel = pixels[pixelLocation];

      packetData[ledAddress] = (byte)(pixel >> 16);
      packetData[ledAddress + 1] = (byte)(pixel >> 8);
      packetData[ledAddress + 2] = (byte)pixel;
      ledAddress += 3;

      if (enableShowLocations) {
        //println("i: " + i + " pixelLoc: " + pixelLocation);
        pixels[pixelLocation] = 0xFFFFFF ^ pixel;
      }
    }

    writePixels();

    if (enableShowLocations) {
      updatePixels();
    }
  }


  public int getNumPixels()
  {
    return pixelLocations.length;
  }

  public Point getLocationByIndex(int index)
  {
    if (index > getNumPixels()) {
      return null;
    }

    return new Point( (pixelLocations[index] % width), (pixelLocations[index]/width));
  }

  public int getLocationByIndexAsInt(int index)
  {
    if (index > getNumPixels()) {
      return -1;
    }

    return pixelLocations[index];
  }

  // Change the number of pixels in our output packet.
  // This is normally not needed; the output packet is automatically sized
  // by draw() and by setPixel().
  public void setPixelCount(int numPixels)
  {
    int numBytes = 3 * numPixels;
    int packetLen = 4 + numBytes;
    if (packetData == null || packetData.length != packetLen) {
      // Set up our packet buffer
      packetData = new byte[packetLen];
      packetData[0] = 0;  // Channel
      packetData[1] = 0;  // Command (Set pixel colors)
      packetData[2] = (byte)(numBytes >> 8);
      packetData[3] = (byte)(numBytes & 0xFF);
    }
  }

  // Directly manipulate a pixel in the output buffer. This isn't needed
  // for pixels that are mapped to the screen.
  public void setPixel(int number, int c)
  {
    int offset = 4 + number * 3;
    if (packetData == null || packetData.length < offset + 3) {
      setPixelCount(number + 1);
    }

    packetData[offset] = (byte) (c >> 16);
    packetData[offset + 1] = (byte) (c >> 8);
    packetData[offset + 2] = (byte) c;
  }

  // Read a pixel from the output buffer. If the pixel was mapped to the display,
  // this returns the value we captured on the previous frame.
  public int getPixel(int number)
  {
    int offset = 4 + number * 3;
    if (packetData == null || packetData.length < offset + 3) {
      return 0;
    }
    return (packetData[offset] << 16) | (packetData[offset + 1] << 8) | packetData[offset + 2];
  }

  // Transmit our current buffer of pixel values to the OPC server. This is handled
  // automatically in draw() if any pixels are mapped to the screen, but if you haven't
  // mapped any pixels to the screen you'll want to call this directly.
  public void writePixels()
  {
    if (packetData == null || packetData.length == 0) {
      // No pixel buffer
      return;
    }
    if (output == null) {
      // Try to (re)connect
      connect();
    }
    if (output == null) {
      return;
    }

    try {
      output.write(packetData);
    } 
    catch (Exception e) {
      dispose();
    }
  }

  public void dispose()
  {
    // Destroy the socket. Called internally when we've disconnected.
    if (output != null) {
      println("Disconnected from OPC server");
    }
    socket = null;
    output = null;
  }

  public void connect()
  {
    // Try to connect to the OPC server. This normally happens automatically in draw()
    try {
      socket = new Socket(host, port);
      socket.setTcpNoDelay(true);
      output = socket.getOutputStream();
      println("Connected to OPC server");
    } 
    catch (ConnectException e) {
      dispose();
    } 
    catch (IOException e) {
      dispose();
    }

    sendColorCorrectionPacket();
    sendFirmwareConfigPacket();
  }
}
public class Peg
{

  int DIAMETER = 20;
  Point p;
  int c;
  float hue;
  float brightness;

  Peg(Point p) {
    this.p = p;
    this.c = Colors.BLACK;
    this.brightness = 1.0f;
  }

  Peg(Point p, int dia) {
    this.p = p;
    this.c = Colors.BLACK;
    this.DIAMETER = dia;
    this.brightness = 1.0f;
  }
  
  Peg(Peg p) {
    this.p = p.p;
    this.c = p.c;
    this.DIAMETER = p.DIAMETER;
    this.brightness = p.brightness;
  }

  public Point getPoint()
  {
    return this.p;
  }

  public int getX()
  {
    return this.p.getX();
  }

  public int getY()
  {
    return this.p.getY();
  }

  public int getColor()
  {
    return this.c;
  }

  public int getColorAsInt()
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
  

  public float getColorAsHue()
  {
    return hue(this.c);
  }

  public void setColor(int c)
  {
    this.c = c;
  }

  public void setHue(float hue)
  {
    this.hue = hue;
    //colorMode(HSB, 100, 255, 255);
    //this.c = color(hue, 0, 255);
    //colorMode(RGB, 255);
  }

  public void nextColor()
  {
    this.c = Colors.nextColor(this.c);
  }

  public void setBrigthness(int brightness)
  {
    brightness = constrain(brightness, 0, 100);
    this.brightness = brightness / 100.0f;
  }

  public int calcColor()
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

  public void drawHue()
  {
    pushMatrix();
    pushStyle();

    fill(this.hue);

    stroke(0xffffffff);
    ellipse(p.getX(), p.getY(), DIAMETER, DIAMETER);
    //stroke(#ffffff);
    //arc(p.getX(), p.getY(), DIAMETER, DIAMETER, 0, 2*3.14159);
    popMatrix();
    popStyle();
  }

  public void draw()
  {
    pushMatrix();
    pushStyle();

    int dispColor = calcColor();
    fill(dispColor);

    stroke(0xffffffff);
    ellipse(p.getX(), p.getY(), DIAMETER, DIAMETER);
    //stroke(#ffffff);
    //arc(p.getX(), p.getY(), DIAMETER, DIAMETER, 0, 2*3.14159);
    popMatrix();
    popStyle();
  }
}
public class PegGrid
{
  final static boolean staggered = false;
  final static int GRID_W = 38;
  final static int GRID_H = 24;

  final int DIAMETER = width/GRID_W;

  PApplet parent;
  OPC opc;
  String ip = "127.0.0.1";
  int port = 7890;

  Peg[] pegs = new Peg[GRID_W*GRID_H];



  PrintWriter output;


  PegGrid(PApplet parent, String ip, int port) {
    this.parent = parent;
    this.ip = ip;
    this.port = port;

    //parent.registerDraw(this);

    opc = new OPC(parent, ip, port);
    opc.showLocations(false);

    generateGrid();
    //opc.ledGrid(0, 38, 24, width/2.0, height/2.0, DIAMETER, DIAMETER, 0, false);

    for (int i = 0; i < pegs.length; i++) {
      Point p = opc.getLocationByIndex(i);
      pegs[i] = new Peg(p, PApplet.parseInt(DIAMETER*0.9f));
      //println("peg[" + i + "]: ( " + pegs[i].getX() + ", " + pegs[i].getY() + " )");
    }
    String timestamp = str(month()) + str(day()) + str(hour()) + str(minute()) + str(second()) + str(millis());
    output = createWriter("history" + timestamp + ".txt");
  }

  private void generateGrid()
  { 
    int index = 0;
    int stripLength = GRID_W;
    int numStrips = GRID_H;
    float x = width/2.0f;
    float y = height/2.0f;
    float ledSpacing = DIAMETER;
    float stripSpacing = DIAMETER;
    float angle = 0;
    boolean zigzag = true;
    boolean reversed = false;

    float s = sin(angle + HALF_PI);
    float c = cos(angle + HALF_PI);
    for (int i = 0; i < numStrips; i++) {
      //reversed = ((i % 2) == 1); //Use if alternating every row.

      if ( i % 8 == 0) {
        reversed = !reversed;
      }
      /*
      //Use if alternating FadeCandy's on different sides.
       if( (i != 0) && ((i % 8) == 0) ){
       reversed = !reversed; 
       }
       */

      if (staggered) {
        opc.ledStrip(index + stripLength * i, stripLength, 
          (x + (i - (numStrips-1)/2.0f) * stripSpacing * c) + (reversed?(DIAMETER/2):0), 
          (y + (i - (numStrips-1)/2.0f) * stripSpacing * s), 
          ledSpacing, 
          angle, zigzag && reversed);
      } else {
        opc.ledStrip(index + stripLength * i, stripLength, 
          (x + (i - (numStrips-1)/2.0f) * stripSpacing * c), 
          (y + (i - (numStrips-1)/2.0f) * stripSpacing * s), 
          ledSpacing, 
          angle, zigzag && reversed);
      }
    }
  }

  /* ******************** COLOR FUNCTIONS ******************** */

  public void nextColorAtCoord(int xpos, int ypos)
  {
    int idx = getIndexAtPoint(xpos, ypos);
    nextColorAtIdx(idx);
  }

  public int getColorAtCoord(int xpos, int ypos)
  {
    println("xpos: " + xpos + " ypos: " + ypos);
    int idx = getIndexAtPoint(xpos, ypos);
    return pegs[idx].getColor();
  }

  public void setColorAtCoord(int xpos, int ypos, int c)
  {
    int idx = getIndexAtPoint(xpos, ypos);
    pegs[idx].setColor(c);
  }

  public void nextColorAtIdx(int idx)
  {
    pegs[idx].nextColor();
  }

  public void setAll(int c)  
  {
    for (int i = 0; i < pegs.length; i++) {
      pegs[i].setColor(c);
    }
  }

  public void setRow(int row, int c)
  {
    for (int i = 0; i < GRID_W; i++) {
      int idx = getIndexAtPoint(i, row);
      pegs[idx].setColor(c);
    }
  }

  public void setCol(int col, int c)
  {
    for (int i = 0; i < GRID_W; i++) {
      int idx = getIndexAtPoint(col, i);
      pegs[idx].setColor(c);
    }
  }

  public void setAllBrightness(int b)
  {
    for (int i = 0; i < pegs.length; i++) {
      pegs[i].setBrigthness(b);
    }
  }

  public void setAllOff()
  {
    setAll(Colors.BLACK);
  }

  public void setAllRandom()
  {
    for (int i = 0; i < pegs.length; i++) {
      int c = color(random(0, 255), random(0, 255), random(0, 255));
      pegs[i].setColor(c);
    }
  }

  public void setAllRandomStandard()
  {
    for (int i = 0; i < pegs.length; i++) {
      pegs[i].setColor(Colors.randomColor());
    }
  }

  public void writeState()
  {
    for (int i = 0; i < pegs.length; i++) {
      String hexStr = hex(pegs[i].getColor());
      if ("FF000000".compareTo(hexStr) == 0) {
        output.print("0");
      } else {
        output.print(hex(pegs[i].getColor()) );
      }

      if (i != pegs.length-1) {
        output.print(",");
      }
    }
    output.println();
  }

  public void loadImg()
  {
    loadPixels();

    for (int i = 0; i < pegs.length; i++) {
      int pixelLocation = opc.getLocationByIndexAsInt(i);
      int pixel = pixels[pixelLocation];
      pegs[i].setColor(pixel);
    }
    updatePixels();
  }
  /*
  public void saveImg()
   {
   loadPixels();
   
   for (int i = 0; i < pegs.length; i++) {
   int pixelLocation = opc.getLocationByIndexAsInt(i);
   int pixel = pixels[pixelLocation];
   pegs[i].setColor(pixel);
   }
   updatePixels();
   }
   */
  /*
  //TODO REMOVE - Testing loading an image into an off-screen object to prevent
   //possible flickering. 
   public void loadImg(PImage img)
   {
   img.loadPixels();
   
   for (int i = 0; i < pegs.length; i++) {
   int pixelLocation = opc.getLocationByIndexAsInt(i);
   int pixel = img.pixels[pixelLocation];
   pegs[i].setColor(pixel);
   }
   img.updatePixels();
   }
   */

  public Peg[] getPegs()
  {
    return this.pegs;
  }

  public void draw()
  {
    pushMatrix();
    pushStyle();
    for (int i = 0; i < pegs.length; i++) {
      pegs[i].draw();
    }
    popMatrix();
    popStyle();
  }

  public Peg mousePressed(int xpos, int ypos)
  { 
    Point mP = new Point(mouseX, mouseY);
    for (int i = 0; i < pegs.length; i++) {
      Point pP = pegs[i].getPoint();

      if (containmentCheck(mP, pP, DIAMETER/2)) {
        println("Clicked peg " + i + "."); 
        if (config.usePaintColor) {
          colorMode(HSB, 255);
          pegs[i].setColor(config.paintColor);
          colorMode(RGB, 255);
        } else {
          pegs[i].nextColor();
        }

        return pegs[i];
      }
    }
    return null;
  }

  private boolean containmentCheck(Point p1, Point p2, int radius)
  {
    //if d^2 <= r^2 we're in the circle. Via Pythagorean theorem
    //d^2 = (p1.x - p2.x)^2 + (p1.y - p2.y)^2 

    int px = (p1.getX() - p2.getX());
    int py = (p1.getY() - p2.getY());

    int r2 = radius*radius;
    int d2 = (px*px) + (py*py);

    if (d2 <= r2) {
      return true;
    }
    return false;
  } 

  public int getIndexAtPoint(int x, int y)
  {
    //println("getting point at ( " + x + ", " + y + ")");
    if ( (x < GRID_W) && (y < GRID_H) ) {
      return (((y % 2) == 1)? (GRID_W -1 - x) : x) + GRID_W * y;
    }
    return -1;
  }
}
public class Point
{
  int x, y;

  Point(int x, int y) {
    this.x = x;
    this.y = y;
  }

  public int getX() {
    return this.x;
  }

  public int getY() {
    return this.y;
  }
}
public class RippleGenerator
{
  int lifespan;

  ArrayList<Ripple> ripples;//an arraylist of the waves emitted

  RippleGenerator(int lifespan) {
    this.lifespan = lifespan;

    ripples = new ArrayList<Ripple>();
  }

  public void addRipple(Point p, int c)
  {
    if (ripples == null) {
      ripples = new ArrayList<Ripple>();
    }
    ripples.add(new Ripple(8, p, c, lifespan));
  }

  public void draw() {
    pushMatrix();
    pushStyle();
    for (int i = ripples.size ()-1; i>=0; i--) {
      Ripple rip = ripples.get(i);
      rip.draw();

      if ( !rip.isAlive() ) {
        ripples.remove(i);
      }
    }

    /*
    if (cycles%(period*2)==0) {
     println("Adding ripple.");
     ripples.add(new Ripple(2, new Point(x, y), color(255, 255, 255), 200));
     } else if (cycles%(period*2)==period) {
     println("Adding ripple.");
     ripples.add(new Ripple(2, new Point(x, y), color(0, 0, 0), 200));
     }
     
     cycles++;
     */
    popMatrix();
    popStyle();
  }
}

class Ripple //a circle with an increasing radius
{ 

  boolean showOrigin = true;

  Point position;

  float velocity;//the speed of the waves
  float radius;//the distance the wave has traveled
  int c;//the color reprasents weather it's a top or buttom

  int lifesize; //the max size of the ripple before it dies.


  Ripple(float velocity, Point p, int c, int lifesize) {
    this.position = p;
    this.velocity = velocity;
    this.c = c;
    this.radius = 0;

    this.lifesize = lifesize;
  }

  public boolean isAlive()
  {
    return (radius < lifesize);
  }

  public void draw() {
    pushMatrix();
    pushStyle();
    /*
    if (showOrigin) {
     fill(0);//display and move the generator
     ellipse(position.getX(), position.getY(), 10, 10);
     }
     */

    radius += velocity;
    strokeWeight(20);
    stroke(c);
    noFill();

    ellipse(position.getX(), position.getY(), radius*2, radius*2);

    popMatrix();
    popStyle();
  }
}
 


public class Screensaver
{
  Timer timer = new  Timer(1000);

  Peg[] pegs = new Peg[PegGrid.GRID_W*PegGrid.GRID_H];

  String path;
  String filename;

  FileInputStream inputStream = null;
  Scanner sc = null;


  Screensaver(String filename) {
    this.path = filename;
    //this.filename = filename;
    loadFile();
    timer.start();
  }

  public void setPegs(Peg[] pegs)
  {
   for (int i = 0; i < pegs.length; i++) {
     this.pegs[i] = new Peg(pegs[i]);
   }
     
  }
  
  public void setAllRandom()
  {
    for (int i = 0; i < pegs.length; i++) {
      int c = color(random(0, 255), random(0, 255), random(0, 255));
      pegs[i].setColor(c);
    }
  }

  public void loadFile()
  {
    println("Loading file: " + this.path);
    try {
      inputStream = new FileInputStream(path);
      sc = new Scanner(inputStream, "UTF-8");
      // note that Scanner suppresses exceptions
      if (sc.ioException() != null) {
        throw sc.ioException();
      }
    }
    catch(Exception e)
    {
      println("EXCEPTION LOADING FILE: " + e.getMessage());
    }
  }

  boolean once = false;
  public String getFrame()
  {
    String line = "";
    if (sc.hasNextLine()) {
      line = sc.nextLine();
      // System.out.println(line);
    } else {
      if (!once) {
        once = true;
        println("END OF FILE.");
      }
    }
    return line;
  }


  public void closeFile()
  {
    try {
      if (inputStream != null) {
        inputStream.close();
      }
      if (sc != null) {
        sc.close();
      }
    }
    catch(Exception e) {
      println(e.getMessage());
    }
  }

  private void loadPegData()
  {
    String[] hues = getFrame().split(",");
    for (int i = 0; i < pegs.length; i++) {
      //println("i: " + i + " hue: " + hues[i]);
      pegs[i].setColor( getColorFromHue(Float.parseFloat(hues[i])) );
    }
    //println("");
    //println("");
    //println("");
  }
  
  public void draw() {
    for (int i = 0; i < pegs.length; i++) {
      pegs[i].draw();
    }
  }
  
  

/*
  void draw() {
    
    //if(!config.nextFrame){
    //  return;
    //}else{
    //  config.nextFrame = false;      
    //}
    
    
    
    pushMatrix();
    pushStyle();
    
    boolean updateCycle = timer.update(); 
    String[] hues = null;

    if (updateCycle)
    {
      //println("Updating hues: " + timer.getTicks());
      hues = getFrame().split(",");
    }


    for (int i = 0; i < pegs.length; i++) {

      //println("i: " + i + " hue: " + hues[i]);
      if (updateCycle)
      {
        if (hues.length != pegs.length) {
          break;
        }
        int c = getColorFromHue(Float.parseFloat(hues[i]));
        if (Float.parseFloat(hues[i]) != 0)
        {
          println("Current: " + hex(pegs[i].getColor()) + " New: " + hex(c) );
        }

        pegs[i].setColor( c );
      }
      pegs[i].draw();
    }
    popMatrix();
    popStyle();
  }
  */
}
public class ScrollingText
{

  PFont font;
  int fontSize = 500;
  int currentX;

  String text;

  boolean loop = false;
  boolean isRunning = false;
  boolean prevRunning = false;

  ScrollingText() {
    font = createFont("BPdotsSquareBold.otf", 110);
    this.text = "LITEBRITE";
    this.currentX = width;
  }

  public void start() 
  {
    currentX = width;
    isRunning = true;
  }
  
  public boolean hasFinished()
  {
    return (prevRunning && !isRunning);
  }
  
  public boolean isRunning()
  {
   return isRunning; 
  }

  public void stop() 
  {
    currentX = width;
    isRunning = false;
  }

  public void setLooping(boolean loop)
  {
    this.loop = loop;
  }


  public void setText(String text)
  {
    this.text = text;
  }

  public void draw()
  {
    prevRunning = isRunning;
    if (!isRunning) {
      return;
    }
    pushMatrix();
    pushStyle();


    textFont(font);
    textSize(fontSize); 
    textAlign(LEFT, CENTER);
    fill(color(255, 255, 255));  // Set fill to white
    text(text, currentX, (height/2.2f));

    if (currentX + PApplet.parseInt(textWidth(text)) > 0) {
      currentX -= config.scrollSpeed;
    } else {
      if (!loop) {
        println("NOT RUNNING.");
        isRunning = false;
      }
      currentX = width;
    }

    popMatrix();
    popStyle();
  }
}
public class Timer
{
  boolean isEnabled = false;

  int ticks;

  int interval;
  int timer;

  Timer(int interval) {
    this.interval = interval;
    this.timer = 0;
    this.ticks = 0;
  }

  public void setInterval(int interval)
  {
    this.interval = interval;
  }

  public int getTicks()
  {
    return ticks;
  }

  public boolean isEnabled()
  {
    return isEnabled;
  }

  public void start()
  {
    isEnabled = true;
  }

  public void stop()
  {
    isEnabled = false;
  }

  public void reset()
  {
    ticks = 0;
    timer = millis() + interval;
  }


  public boolean update() {
    if (millis() > timer) {
      timer = millis() + interval;
      if (isEnabled) {
        ticks++;
      }
      return true;
    } else {
      return false;
    }
  }
}
/* =========================================================
 * ====                   WARNING                        ===
 * =========================================================
 * The code in this tab has been generated from the GUI form
 * designer and care should be taken when editing this file.
 * Only add/edit code inside the event handlers i.e. only
 * use lines between the matching comment tags. e.g.

 void myBtnEvents(GButton button) { //_CODE_:button1:12356:
     // It is safe to enter your event code here  
 } //_CODE_:button1:12356:
 
 * Do not rename this tab!
 * =========================================================
 */

synchronized public void settings_draw(PApplet appc, GWinData data) { //_CODE_:settings:557361:
  appc.background(230);
} //_CODE_:settings:557361:

public void cbx_ripple_clicked(GCheckbox source, GEvent event) { //_CODE_:cbx_ripple:843597:
  println("cbx_ripple - GCheckbox >> GEvent." + event + " @ " + millis());
  config.rippleEnabled = cbx_ripple.isSelected();
} //_CODE_:cbx_ripple:843597:

public void bttn_clear_click(GButton source, GEvent event) { //_CODE_:bttn_:607940:
  println("button1 - GButton >> GEvent." + event + " @ " + millis());
  grid.setAllOff();
} //_CODE_:bttn_:607940:

public void bttn_saveImg_click(GButton source, GEvent event) { //_CODE_:bttn_saveImg:999764:
  println("button1 - GButton >> GEvent." + event + " @ " + millis());
  saveFrame();
} //_CODE_:bttn_saveImg:999764:

public void cbx_desktop_clicked(GCheckbox source, GEvent event) { //_CODE_:cbx_desktop:798569:
  println("cbx_desktop - GCheckbox >> GEvent." + event + " @ " + millis());
  config.showDesktop = cbx_desktop.isSelected();
} //_CODE_:cbx_desktop:798569:

public void bttn_intro_click(GButton source, GEvent event) { //_CODE_:bttn_intro:966216:
  println("bttn_intro - GButton >> GEvent." + event + " @ " + millis());
  config.loadingSequenceEnabled = true;
  startLoadingSequence();
} //_CODE_:bttn_intro:966216:

public void sld_brightness_change(GSlider source, GEvent event) { //_CODE_:sld_brightness:248301:
  //println("slider1 - GSlider >> GEvent." + event + " @ " + millis());
  grid.setAllBrightness(source.getValueI());
} //_CODE_:sld_brightness:248301:

public void cbx_random_clicked(GCheckbox source, GEvent event) { //_CODE_:cbx_random:585846:
  println("cbx_random - GCheckbox >> GEvent." + event + " @ " + millis());
  config.randomPegsEnabled = cbx_random.isSelected();
  if (!config.randomPegsEnabled) {
    grid.setAllOff();
  }else{
    config.randomPegSpeed = PApplet.parseInt(sld_randPegSpeed.getValueF() * 1000); 
  }
} //_CODE_:cbx_random:585846:

public void cbx_rainbow_clicked(GCheckbox source, GEvent event) { //_CODE_:cbx_rainbow:294234:
  println("cbx_rainbow - GCheckbox >> GEvent." + event + " @ " + millis());
  config.rainbowEnabled = cbx_rainbow.isSelected();
  if (!config.rainbowEnabled) {
    grid.setAllOff();
  } else {
    config.rainbowSpeed = sld_rainSpeed.getValueF();
  }
} //_CODE_:cbx_rainbow:294234:

public void sld_rainSpeed_change(GSlider source, GEvent event) { //_CODE_:sld_rainSpeed:356317:
  println("sld_rainSpeed - GSlider >> GEvent." + event + " @ " + millis());
  config.rainbowSpeed = source.getValueF();
} //_CODE_:sld_rainSpeed:356317:

public void bttn_scrollingText_click(GButton source, GEvent event) { //_CODE_:bttn_scrollingText:631403:
  println("button1 - GButton >> GEvent." + event + " @ " + millis());
  title.start();
} //_CODE_:bttn_scrollingText:631403:

public void sld_randPegSpeed_change(GSlider source, GEvent event) { //_CODE_:sld_randPegSpeed:729248:
  println("slider1 - GSlider >> GEvent." + event + " @ " + millis());
  config.randomPegSpeed = PApplet.parseInt(source.getValueF() * 1000);
} //_CODE_:sld_randPegSpeed:729248:

public void sld_scrollSpeed_change(GSlider source, GEvent event) { //_CODE_:sld_scrollSpeed:237074:
  println("slider2 - GSlider >> GEvent." + event + " @ " + millis());
  config.scrollSpeed = sld_scrollSpeed.getValueI();
} //_CODE_:sld_scrollSpeed:237074:

public void cbx_capture_time_clicked1(GCheckbox source, GEvent event) { //_CODE_:cbx_capture_time:805883:
  println("cbx_capture_time - GCheckbox >> GEvent." + event + " @ " + millis());
  config.captureUsageEnabled = cbx_capture_time.isSelected();
} //_CODE_:cbx_capture_time:805883:

public void sld_paintColor_change1(GSlider source, GEvent event) { //_CODE_:sld_paintColor:615317:
  //println("slider1 - GSlider >> GEvent." + event + " @ " + millis());
  int rc = sld_paintColor.getValueI();
  colorMode(HSB, 255);
  updatePaintColorView(color(rc, 255, 255));
  config.paintColor = color(rc, 255, 255);
  colorMode(RGB, 255);
} //_CODE_:sld_paintColor:615317:

public void cbx_usePaint_clicked(GCheckbox source, GEvent event) { //_CODE_:cbx_usePaint:453036:
  println("cbx_usePaint - GCheckbox >> GEvent." + event + " @ " + millis());
  config.usePaintColor = cbx_usePaint.isSelected();
} //_CODE_:cbx_usePaint:453036:

public void cbx_write_csv_clicked1(GCheckbox source, GEvent event) { //_CODE_:cbx_write_csv:299993:
  println("cbx_write_csv - GCheckbox >> GEvent." + event + " @ " + millis());
  config.write_csv = cbx_write_csv.isSelected();
} //_CODE_:cbx_write_csv:299993:

public void bttn_nextFrame_click(GButton source, GEvent event) { //_CODE_:bttn_nextFrame:823620:
  println("bttn_nextFrame - GButton >> GEvent." + event + " @ " + millis());
  
  config.nextFrame = true;
} //_CODE_:bttn_nextFrame:823620:



// Create all the GUI controls. 
// autogenerated do not edit
public void createGUI(){
  G4P.messagesEnabled(false);
  G4P.setGlobalColorScheme(GCScheme.BLUE_SCHEME);
  G4P.setMouseOverEnabled(false);
  surface.setTitle("LiteBrite Controller");
  settings = GWindow.getWindow(this, "Settings", 0, 0, 800, 600, P3D);
  settings.noLoop();
  settings.setActionOnClose(G4P.KEEP_OPEN);
  settings.addDrawHandler(this, "settings_draw");
  label_settings = new GLabel(settings, 10, 100, 80, 20);
  label_settings.setTextAlign(GAlign.CENTER, GAlign.MIDDLE);
  label_settings.setText("Settings");
  label_settings.setTextBold();
  label_settings.setOpaque(false);
  cbx_ripple = new GCheckbox(settings, 10, 130, 120, 20);
  cbx_ripple.setIconAlign(GAlign.LEFT, GAlign.MIDDLE);
  cbx_ripple.setText("Ripple Effect");
  cbx_ripple.setOpaque(false);
  cbx_ripple.addEventHandler(this, "cbx_ripple_clicked");
  bttn_ = new GButton(settings, 700, 560, 80, 30);
  bttn_.setText("Clear");
  bttn_.addEventHandler(this, "bttn_clear_click");
  bttn_saveImg = new GButton(settings, 700, 520, 80, 30);
  bttn_saveImg.setText("Save");
  bttn_saveImg.addEventHandler(this, "bttn_saveImg_click");
  cbx_desktop = new GCheckbox(settings, 10, 160, 120, 20);
  cbx_desktop.setIconAlign(GAlign.LEFT, GAlign.MIDDLE);
  cbx_desktop.setText("Show Desktop");
  cbx_desktop.setOpaque(false);
  cbx_desktop.addEventHandler(this, "cbx_desktop_clicked");
  bttn_intro = new GButton(settings, 10, 40, 80, 30);
  bttn_intro.setText("Intro Sequence");
  bttn_intro.addEventHandler(this, "bttn_intro_click");
  sld_brightness = new GSlider(settings, 190, 310, 293, 44, 20.0f);
  sld_brightness.setLimits(1, 0, 100);
  sld_brightness.setNumberFormat(G4P.INTEGER, 0);
  sld_brightness.setOpaque(false);
  sld_brightness.addEventHandler(this, "sld_brightness_change");
  cbx_random = new GCheckbox(settings, 10, 190, 120, 20);
  cbx_random.setIconAlign(GAlign.LEFT, GAlign.MIDDLE);
  cbx_random.setText("Random Pegs");
  cbx_random.setOpaque(false);
  cbx_random.addEventHandler(this, "cbx_random_clicked");
  cbx_rainbow = new GCheckbox(settings, 10, 220, 120, 20);
  cbx_rainbow.setIconAlign(GAlign.LEFT, GAlign.MIDDLE);
  cbx_rainbow.setText("Rainbow Effect");
  cbx_rainbow.setOpaque(false);
  cbx_rainbow.addEventHandler(this, "cbx_rainbow_clicked");
  sld_rainSpeed = new GSlider(settings, 140, 210, 190, 40, 10.0f);
  sld_rainSpeed.setShowValue(true);
  sld_rainSpeed.setLimits(1.0f, 0.01f, 10.0f);
  sld_rainSpeed.setNumberFormat(G4P.DECIMAL, 2);
  sld_rainSpeed.setOpaque(false);
  sld_rainSpeed.addEventHandler(this, "sld_rainSpeed_change");
  bttn_scrollingText = new GButton(settings, 9, 249, 121, 21);
  bttn_scrollingText.setText("Scrolling Text");
  bttn_scrollingText.addEventHandler(this, "bttn_scrollingText_click");
  sld_randPegSpeed = new GSlider(settings, 140, 180, 190, 40, 10.0f);
  sld_randPegSpeed.setShowValue(true);
  sld_randPegSpeed.setLimits(0.5f, 0.0f, 1.0f);
  sld_randPegSpeed.setNumberFormat(G4P.DECIMAL, 2);
  sld_randPegSpeed.setOpaque(false);
  sld_randPegSpeed.addEventHandler(this, "sld_randPegSpeed_change");
  sld_scrollSpeed = new GSlider(settings, 140, 240, 190, 40, 10.0f);
  sld_scrollSpeed.setShowValue(true);
  sld_scrollSpeed.setLimits(5, 0, 100);
  sld_scrollSpeed.setNumberFormat(G4P.INTEGER, 0);
  sld_scrollSpeed.setOpaque(false);
  sld_scrollSpeed.addEventHandler(this, "sld_scrollSpeed_change");
  cbx_capture_time = new GCheckbox(settings, 590, 520, 110, 30);
  cbx_capture_time.setIconAlign(GAlign.LEFT, GAlign.MIDDLE);
  cbx_capture_time.setText("Capture Usage");
  cbx_capture_time.setOpaque(false);
  cbx_capture_time.addEventHandler(this, "cbx_capture_time_clicked1");
  cbx_capture_time.setSelected(true);
  //paintColor_view = new GView(settings, 330, 500, 80, 70, P3D);
  sld_paintColor = new GSlider(settings, 20, 500, 310, 70, 30.0f);
  sld_paintColor.setLimits(255, 0, 255);
  sld_paintColor.setNumberFormat(G4P.INTEGER, 0);
  sld_paintColor.setOpaque(false);
  sld_paintColor.addEventHandler(this, "sld_paintColor_change1");
  cbx_usePaint = new GCheckbox(settings, 20, 480, 120, 20);
  cbx_usePaint.setIconAlign(GAlign.LEFT, GAlign.MIDDLE);
  cbx_usePaint.setText("Use paint color");
  cbx_usePaint.setOpaque(false);
  cbx_usePaint.addEventHandler(this, "cbx_usePaint_clicked");
  cbx_write_csv = new GCheckbox(settings, 589, 486, 117, 29);
  cbx_write_csv.setIconAlign(GAlign.LEFT, GAlign.MIDDLE);
  cbx_write_csv.setText("Write CSV");
  cbx_write_csv.setOpaque(false);
  cbx_write_csv.addEventHandler(this, "cbx_write_csv_clicked1");
  cbx_write_csv.setSelected(true);
  bttn_nextFrame = new GButton(settings, 699, 445, 80, 30);
  bttn_nextFrame.setText("Next Frame");
  bttn_nextFrame.addEventHandler(this, "bttn_nextFrame_click");
  settings.loop();
}

// Variable declarations 
// autogenerated do not edit
GWindow settings;
GLabel label_settings; 
GCheckbox cbx_ripple; 
GButton bttn_; 
GButton bttn_saveImg; 
GCheckbox cbx_desktop; 
GButton bttn_intro; 
GSlider sld_brightness; 
GCheckbox cbx_random; 
GCheckbox cbx_rainbow; 
GSlider sld_rainSpeed; 
GButton bttn_scrollingText; 
GSlider sld_randPegSpeed; 
GSlider sld_scrollSpeed; 
GCheckbox cbx_capture_time; 
GView paintColor_view; 
GSlider sld_paintColor; 
GCheckbox cbx_usePaint; 
GCheckbox cbx_write_csv; 
GButton bttn_nextFrame; 
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "ProcessingController" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
