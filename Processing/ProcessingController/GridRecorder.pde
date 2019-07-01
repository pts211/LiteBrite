public class GridRecorder
{
  final static int GRID_W = 38;
  final static int GRID_H = 24;

  final static int MIN_USAGE = 50;

  int usageCount = 0;

  Peg[] pegs = new Peg[PegGrid.GRID_W*PegGrid.GRID_H];
  PrintWriter output;

  GridRecorder() {
  }

  public void startNewFile()
  {
    startNewFile(false);
  }

  public void startNewFile(boolean force)
  {
    if (force || usageCount > MIN_USAGE) {
      closeFile();
      createFile();  
      usageCount = 0;
    }
  }

  public void createFile()
  {
    String timestamp = getFormattedYMD() + "_" + getFormattedTime(false);
    output = createWriter("recordings/"+ getFormattedYMD() + "/recording_" + timestamp + ".csv");
  }

  public void closeFile()
  {
    output.flush();
    output.close();
  }

  public void setPegs(Peg[] pegs)
  {
    //A reference to the pegs to be recorded.
    this.pegs = pegs;
  }

  public void captureState()
  {
    captureHeader();
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

    usageCount++;
  }

  public void captureClear()
  {
    captureHeader();
    output.println("clear");
  }
  
  public void captureWake()
  {
    captureHeader();
    output.println("wake");
  }
  
  public void captureSleep()
  {
    captureHeader();
    output.println("sleep");
  }

  private void captureHeader()
  {
    if (output == null) {
      createFile();
    }
    //String timestamp = str(hour()) + ":" + str(minute()) + ":" + str(second()); 
    output.print(getFormattedTime(true));
    output.print(",");
  }

  private String getFormattedYMD()
  {
    int y = year();
    int m = month();
    int d = day();

    return y + ((m < 10)?"0"+str(m):str(m)) + ((d < 10)?"0"+str(d):str(d));
  }

  private String getFormattedTime(boolean delim)
  {
    int h = hour();
    int m = minute();
    int s = second();

    if (delim) {
      return((h < 10)?"0"+str(h):str(h)) + ":" + ((m < 10)?"0"+str(m):str(m)) + ":" + ((s < 10)?"0"+str(s):str(s));
    } else {
      return((h < 10)?"0"+str(h):str(h)) + ((m < 10)?"0"+str(m):str(m)) + ((s < 10)?"0"+str(s):str(s));
    }
  }

  public Peg[] getPegs()
  {
    return this.pegs;
  }
}
