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


Configuration config;

//Desktop Display
import java.awt.Robot;
import java.awt.image.BufferedImage;
import java.awt.Rectangle;

import java.nio.*;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.Files;

// import UDP library
import hypermedia.net.*;
import gifAnimation.*;
// Need G4P library
import g4p_controls.*;
// You can remove the PeasyCam import if you are not using
// the GViewPeasyCam control or the PeasyCam library.
import peasy.*;

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
List<PImage> imgs;

//Ripples
RippleGenerator ripGen;

//Desktop Viewer
DesktopViewer desktop;

//Loading Sequence
LoadingBar loadingBar;

//Scrolling Text
ScrollingText title;

//GhostPegGrid - This peg grid is not persisted to the display. It is just an overlay. 
GhostPegGrid ghostGrid;


GridRecorder recorder;

//Recording playback
PlaybackManager playManager;
Playback player;

Clock clock;
Timer idleTimer;
Timer shortIdleTimer;
Timer workDisplayTimer;

void settings() {
  size(SCREEN_WIDTH, int(SCREEN_WIDTH/ASPECT_RATIO)); //Don't even think about doing a print statement before this.
}

void setup()
{
  colorMode(RGB, 100);
  //frameRate(30);
  println("Controller: Initializing Display Parameters. Done.");  
  grid = new PegGrid(this, "127.0.0.1", 7890);

  config = new Configuration();

  clock = new Clock();

  idleTimer = new Timer(config.IDLE_TIMEOUT, config.IDLE_TIMEOUT_UNIT);
  idleTimer.start();

  shortIdleTimer = new Timer(config.SHORT_IDLE_TIMEOUT, config.SHORT_IDLE_TIMEOUT_UNIT);
  shortIdleTimer.start();

  workDisplayTimer = new Timer(config.WORKDISPLAY_TIMEOUT, config.WORKDISPLAY_TIMEOUT_UNIT);

  initNetworking();
  loadImages();
  loadGifs();

  //Ripples
  ripGen = new RippleGenerator(400);

  createGUI();
  customGUI();

  desktop = new DesktopViewer(SCREEN_WIDTH, int(SCREEN_WIDTH/ASPECT_RATIO));

  loadingBar = new LoadingBar();

  ghostGrid = new GhostPegGrid();
  ghostGrid.setPegs(grid.getPegs());

  recorder = new GridRecorder();
  recorder.setPegs(grid.getPegs());


  playManager = new PlaybackManager();
  playManager.listFiles();
  playManager.setRandomIndex();

  player = new Playback(playManager.getActiveFilePath());
  player.setPegs(grid.getPegs());




  //config.loadingSequenceEnabled = true;
  //startLoadingSequence();

  title = new ScrollingText();

  startEffectTimers();
}

void initNetworking()
{
  println("Controller: Initializing Network.");
  //Configure network.

  udp = new UDP( this, INPUT_PORT);
  udp.log( true );     // <-- printout the connection activity
  udp.listen( true );
  println("Controller: Initializing Network. Done.");
  println("Controller: Initializing Network. Done.");
}

void loadImages()
{
  println("Controller: Loading Images.");
  //Image loading
  //String path = "/home/robot/Desktop/LiteBrite/Processing/ProcessingController/images";
  String path = dataPath("../images");
  println("\tpath: " + path);
  String[] filenames = listFileNames(path);
  printArray(filenames);


  imgs = new ArrayList();
  for (int i = 0; i < filenames.length; i++) {
    String filename = filenames[i].toUpperCase();
    if ( filename.contains(".JPG") 
      || filename.contains(".PNG") 
      || filename.contains(".GIF") ) {
      imgs.add(loadImage(path+"/"+filenames[i]));
    }
  }
  println("Controller: Loading Images. Done.");
}

void loadGifs()
{
  pacman = new Gif(this, dataPath("../animated/pacman-animation-crop-tail.gif"));
  pac = new AnimatedTransistion(pacman, 3, false);

  blinky = new Gif(this, dataPath("../animated/blinky-animation-crop.gif"));
  blink = new AnimatedTransistion(blinky, 3, true);

  coffee = new Gif(this, dataPath("../animated/coffee_crop_invert_wide.gif"));
  coffee.loop();  
  coffee.play();
}

void draw()
{
  if ( shortIdleTimer.update() ) {
    if ( pressesSinceIdle < config.MIN_ACTIVITY ) {
      config.isIdle = true;
    }
    //println("pressesSinceIdle: " + pressesSinceIdle);
  }

  if (idleTimer.update()) {
    updatePlayback();
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
    grid.setAllOff();
    //If we load a saved LiteBrite image then we don't ant to scale it.
    PImage img = imgs.get(currentImg);
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
    processIdleTimers();
    desktop.draw();
  }
  if (config.randomPegsEnabled) {
    processIdleTimers();
    randomPegs();
  }
  if (config.loadingSequenceEnabled) {
    processIdleTimers();
    loadScreen();
  }
  if (config.rainbowEnabled) {
    processIdleTimers();
    rainbowCycle();
  }
  if (config.playbackEnabled) {
    processIdleTimers();
    player.draw();
  }

  if (config.isMorning && config.isIdle)
  {
    image(coffee, width/2  - coffee.width*3/2, height / 2 - coffee.height*3/2, coffee.width * 3, coffee.height * 3);
  } else if ( config.isIdle )
  {
    //randomPegsScreensaver();
    //ghostGrid.draw();
    workPlaybackScreensaver();
  }

  title.draw();
  tf_playbackDir.setText(playManager.getActiveFileName());
}

boolean processIdleTimers()
{

  shortIdleTimer.reset();
  idleTimer.reset();
  if (config.isIdle || config.isSleeping) {
    config.isIdle = false;
    config.isSleeping = false;

    pressesSinceIdle = 0;
    recorder.captureWake();
    return true;
  }
  pressesSinceIdle++;



  return false;
}

// ****************************************
// ****************************************
//        Input Handlers
// ****************************************
// ****************************************
void mousePressed()
{ 
  if ( processIdleTimers() ) {
    return;
  }

  Peg peg = grid.mousePressed(mouseX, mouseY);

  if ( peg != null) {
    if (config.captureUsageEnabled) {
      screenshot();
    }
    if (config.write_csv) {
      recorder.captureState();
    }
    if (config.rippleEnabled) {
      ripGen.addRipple(peg.getPoint(), peg.getColor());
    }
  }
}

void keyPressed()
{
  if ( processIdleTimers() ) {
    return;
  }

  switch(key)
  {
  case 'c':
    recorder.captureClear();
    recorder.startNewFile();
    pac.start();
    shortIdleTimer.start();
    pressesSinceIdle = 0;
    break;
  case 'C':
    recorder.captureClear();
    recorder.startNewFile();
    blink.start();
    shortIdleTimer.start();
    pressesSinceIdle = 0;
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
  case 'N':
    updatePlayback();
    break;
  case 'o':
    recorder.captureClear();
    recorder.startNewFile();
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


// Playback Control Functions

void restartPlayback()
{
  player.loadNewFile(playManager.getActiveFilePath());
}

void updatePlayback()
{
  String newRecordingPath = playManager.nextFilePath();
  player.loadNewFile(newRecordingPath);
}

void previousPlayback()
{
  String newRecordingPath = playManager.previousFilePath();
  player.loadNewFile(newRecordingPath);
}

void increasePlaybackSpeed()
{
  config.playbackSpeed *= 2;

  lbl_recSpeed.setText(config.playbackSpeed + "X");
  lbl_recSpeed.setTextBold();
}

void decreasePlaybackSpeed()
{
  config.playbackSpeed /= 2;
  if (config.playbackSpeed <= 0) {
    config.playbackSpeed = 1;
  }

  lbl_recSpeed.setText(config.playbackSpeed + "X");
  lbl_recSpeed.setTextBold();
}

void saveRecordingFile()
{
  String saveDir = config.favoriteRecordingSaveDir;
  File src = playManager.getActiveFile();

  //src.getName();
  try {
    Files.copy(src.toPath(), Paths.get(saveDir + "/" + src.getName()));
  }
  catch(Exception e) {
    //TODO
    println(e);
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

int pressesSinceIdle = 0;
void processMessage(String ip, String message)
{
  if ( processIdleTimers() ) {
    return;
  }
  
  String ystr = ip.substring(ip.lastIndexOf('.')+1, ip.length());
  int yidx = Integer.parseInt(ystr) - 1; //Change IP range to start at 1.
  //println("yidx: " + yidx);

  message = message.trim();

  boolean hasClearedOnce = false;
  //TODO Was using message.length, make sure that using the GRID_W works.
  for (int x = 0; x < PegGrid.GRID_W + 1; x++)
  {
    if (Integer.parseInt(String.valueOf(message.charAt(x))) == 1 && x < PegGrid.GRID_W ) {
      println("x:" + x);
      if (message.contains("c")) {
        grid.setRow(yidx, Colors.BLACK);
        grid.nextColorAtCoord(x, yidx);
        grid.nextColorAtCoord(x, yidx);
      } else if (grid.isBrushPeg(x, yidx) ) {
        grid.nextBrushPegColor();
      } else {
        grid.nextColorAtCoord(x, yidx);
      }
      if (config.captureUsageEnabled) {
        screenshot();
      }
      if (config.write_csv) {
        recorder.captureState();
      }
    }
    if (!hasClearedOnce && yidx == 9 && (Integer.parseInt(String.valueOf(message.charAt(38))) == 1)) {
      println("CLEAR BUTTON PRESSED!");
      hasClearedOnce = true;
      recorder.captureClear();
      recorder.startNewFile();

      if ( random(100) > 50 ) {
        pac.start();
      } else {
        blink.start();
      }

      shortIdleTimer.start();
      pressesSinceIdle = 0;
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
  if (currentImg >= imgs.size() ) {
    currentImg = -1;
  }
  hasDrawn = false;
}

void screenshot()
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
