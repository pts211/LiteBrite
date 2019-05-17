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
  
  PegGrid(PApplet parent, String ip, int port){
    this.parent = parent;
    this.ip = ip;
    this.port = port;
    
    //parent.registerDraw(this);
    
    opc = new OPC(parent, ip, port);
    opc.showLocations(false);
    
    generateGrid();
    
    for (int i = 0; i < pegs.length; i++) {
        Point p = opc.getLocationByIndex(i);
        pegs[i] = new Peg(p, int(DIAMETER*0.9));
        //println("peg[" + i + "]: ( " + pegs[i].getX() + ", " + pegs[i].getY() + " )");
    }
  }
  
  private void generateGrid()
  { 
    int index = 0;
    int stripLength = GRID_W;
    int numStrips = GRID_H;
    float x = width/2.0;
    float y = height/2.0;
    float ledSpacing = DIAMETER;
    float stripSpacing = DIAMETER;
    float angle = 0;
    boolean zigzag = true;
    
    float s = sin(angle + HALF_PI);
    float c = cos(angle + HALF_PI);
    for (int i = 0; i < numStrips; i++) {
      boolean reversed = ((i % 2) == 1);
      
      if(staggered){
        opc.ledStrip(index + stripLength * i, stripLength,
          (x + (i - (numStrips-1)/2.0) * stripSpacing * c) + (reversed?(DIAMETER/2):0),
          (y + (i - (numStrips-1)/2.0) * stripSpacing * s),
          ledSpacing,
          angle, zigzag && reversed);
      }else{
        opc.ledStrip(index + stripLength * i, stripLength,
          (x + (i - (numStrips-1)/2.0) * stripSpacing * c),
          (y + (i - (numStrips-1)/2.0) * stripSpacing * s),
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
  
  public void setAllOff()
  {
    setAll(Colors.BLACK);
  }
  
  public void setAllRandom()
  {
    for (int i = 0; i < pegs.length; i++) {
        pegs[i].setColor(Colors.randomColor());
    } 
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
  
  public void draw()
  {
    for (int i = 0; i < pegs.length; i++) {
      pegs[i].draw();
    }
  }
  
  public void mousePressed(int xpos, int ypos)
  { 
    Point mP = new Point(mouseX, mouseY);
    for (int i = 0; i < pegs.length; i++) {
      Point pP = pegs[i].getPoint();
      
      if(containmentCheck(mP, pP, DIAMETER/2)){
        println("Clicked peg " + i + "."); 
        pegs[i].nextColor();
        break;
      }
    }
  }
  
  private boolean containmentCheck(Point p1, Point p2, int radius)
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
  
  public int getIndexAtPoint(int x, int y)
  {
    //println("getting point at ( " + x + ", " + y + ")");
    if( (x < GRID_W) && (y < GRID_H) ){
      return (((y % 2) == 1)? (GRID_W -1 - x) : x) + GRID_W * y;
      
    }
    return -1;
  }
  
}