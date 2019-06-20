import java.io.*; 
import java.util.*;

public class Playback
{
  Timer timer = new  Timer(1);

  Peg[] pegs = new Peg[PegGrid.GRID_W*PegGrid.GRID_H];

  String path;
  String filename;
  boolean endOfFile = false;

  FileInputStream inputStream = null;
  Scanner sc = null;


  Playback(String filename) {
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

  void loadNewFile(String newFile)
  {
    endOfFile = false;
    closeFile();
    this.path = newFile;
    loadFile();
  }
  
  boolean isFinished()
  {
    return endOfFile;
  }

  private void loadFile()
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

  String getFrame()
  {
    String line = "";
    while (line == "" || line.contains("clear") || line.contains("wake") )
    {
      if (sc.hasNextLine()) {
        line = sc.nextLine();
        // System.out.println(line);
      } else {
        if (!endOfFile) {
          endOfFile = true;
          println("END OF FILE.");
        }
        break;
      }
    } 


    return line;
  }


  private void closeFile()
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

  void draw() {

    //if(!config.nextFrame){
    //  return;
    //}else{
    //  config.nextFrame = false;      
    //}

    pushMatrix();
    pushStyle();

    boolean updateCycle = timer.update(); 
    String[] hexColors = null;


    if (updateCycle)
    {
      String line = "";

      for (int i = 0; i < config.playbackSpeed; i++) {
        line = getFrame();
      }

      //println("Updating hues: " + timer.getTicks() + " " + line);
      hexColors = line.split(",");
    }


    for (int i = 0; i < pegs.length; i++) {
      int j = 0;
      if (updateCycle)
      {
        if (hexColors.length == pegs.length) {
          j = i;     //if the row doesn't have a timestamp.
          int c = unhex(hexColors[j]);
          pegs[i].setColor( c );
        } else if (hexColors.length == pegs.length + 1) {
          j = i + 1; //if the row has a timestamp.
          int c = unhex(hexColors[j]);
          pegs[i].setColor( c );
        } else {
          //break;      //if the size is wrong. Maybe it was a bad write.
        }
      }
      pegs[i].draw();
    }
    popMatrix();
    popStyle();
  }
}
