//This is a sketch to control the LiteBrite created for DevCon 2019.
//Author: Paul Sites (ps022648)



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

void setup()
{
  //Configure network.
  udp = new UDP( this, 5400 );
  //udp.log( true );     // <-- printout the connection activity
  udp.listen( true );
  
  size(900, 600, P3D);
  colorMode(HSB, 100);
  
  grid = new PegGrid(this, 7890);
 
  
  //Test receiving a message.
  processMessage("192.168.1.4", "10000001000000000000001000000000000000");
}

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
    default:
      break;
  }
}

void draw()
{
  background(0);
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
      grid.nextColorAtCoord(x, yidx);
    } 
  }
  
}
