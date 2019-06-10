public class Timer
{
  boolean isEnabled = false;

  int ticks;

  int interval;
  int timer;

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
      }
      return true;
    } else {
      return false;
    }
  }
}
