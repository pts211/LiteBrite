public class Timer
{
  boolean isEnabled = false;

  int ticks;

  int interval;
  int timer;

  Timer(int interval, int unit) {

    switch(unit)
    {
    case UnitTime.MILLISECOND:
      this.interval = interval;
      break;
    case UnitTime.SECOND:
      this.interval = interval*1000;
      break;
    case UnitTime.MINUTE:
      this.interval = interval*1000*60;
      break;
    case UnitTime.HOUR:
      this.interval = interval*1000*60*60;
      break;
    }
    this.timer = 0;
    this.ticks = 0;
  }

  Timer(int interval) {
    this.interval = interval;
    this.timer = 0;
    this.ticks = 0;
  }

  void setInterval(int interval)
  {
    this.interval = interval;
  }

  int getTicks()
  {
    return ticks;
  }

  boolean isEnabled()
  {
    return isEnabled;
  }

  void start()
  {
    isEnabled = true;
    timer = millis() + interval;
  }

  void stop()
  {
    isEnabled = false;
  }

  void reset()
  {
    ticks = 0;
    timer = millis() + interval;
  }


  boolean update() {
    if (millis() > timer) {
      timer = millis() + interval;
      if (isEnabled) {
        ticks++;
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }
}

public static class UnitTime
{


  public final static int MILLISECOND = 0;
  public final static int SECOND = 1;
  public final static int MINUTE = 2;
  public final static int HOUR = 3;

  UnitTime() {
  }
}
