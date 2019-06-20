
public class Configuration
{
  // ********** CONSTANTS ********** //
  
  
  //IdleTimer: This timer is used to wait a reasonable long time
  // so someones designs can be visible before going to a screensaver.
  public final int IDLE_TIMEOUT = 20;
  public final int IDLE_TIMEOUT_UNIT = UnitTime.MINUTE;
  
  //ShortIdleTimer: This timer is used to test if someone is actually using the LiteBrite
  // or if it was just a walkby press. If it's a walkby, we want to fairly quickly switch
  // back to the screensaver.
  public final int SHORT_IDLE_TIMEOUT = 10;
  public final int SHORT_IDLE_TIMEOUT_UNIT = UnitTime.SECOND;
  
  // The minium number of presses required in the short idle timeout period to
  // consider the LiteBrite "in use" so it doesn't go back to the screensaver.
  public final int MIN_ACTIVITY = 10;
  
  
  public boolean isIdle = false;
  public boolean isSleeping = false;
  public boolean isMorning = false;
  
  public boolean loadingSequenceEnabled = false;

  public boolean rippleEnabled = false;
  public boolean showDesktop = false;
  
  public boolean playbackEnabled = false;
  
  public boolean randomPegsEnabled = false;
  public int randomPegSpeed = 1000;
  
  public boolean rainbowEnabled = false;
  public float rainbowSpeed = 0.5;
  
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
