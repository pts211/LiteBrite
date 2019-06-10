import java.io.*; 
import java.util.*;

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

  void loadFile()
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
  String getFrame()
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


  void closeFile()
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
  
  void draw() {
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
