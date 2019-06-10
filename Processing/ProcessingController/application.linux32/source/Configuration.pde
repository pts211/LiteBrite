
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
  public color paintColor;
  
  public boolean nextFrame = false;
  
  Configuration() {
  }
}
