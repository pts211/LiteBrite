import java.io.*; 
import java.util.*;

public class GhostPegGrid
{
  Peg[] pegs = new Peg[PegGrid.GRID_W*PegGrid.GRID_H];
  
  GhostPegGrid() {
    
  }

  void setPegs(Peg[] pegs)
  {
   for (int i = 0; i < pegs.length; i++) {
     this.pegs[i] = new Peg(pegs[i]);
   }
     
  }
  
  void setAllRandom()
  {
    for (int i = 0; i < pegs.length; i++) {
      color c = color(random(0, 255), random(0, 255), random(0, 255));
      pegs[i].setColor(c);
    }
  }
  
  public void setAllRandomStandard()
  {
    for (int i = 0; i < pegs.length; i++) {
      pegs[i].setColor(Colors.randomColor());
    }
  }

  
  void draw() {
    for (int i = 0; i < pegs.length; i++) {
      pegs[i].draw();
    }
  }
  
  public void setColorAtCoord(int xpos, int ypos, color c)
  {
    int idx = getIndexAtPoint(xpos, ypos);
    pegs[idx].setColor(c);
  }
  
  
  public int getIndexAtPoint(int x, int y)
  {
    //println("getting point at ( " + x + ", " + y + ")");
    if ( (x < PegGrid.GRID_W) && (y < PegGrid.GRID_H) ) {
      return (((y % 2) == 1)? (PegGrid.GRID_W -1 - x) : x) + PegGrid.GRID_W * y;
    }
    return -1;
  }
  
}
