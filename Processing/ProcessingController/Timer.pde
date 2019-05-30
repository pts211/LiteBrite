public class Timer
{
  int ticks;

  int interval;
  int timer;

  Timer(int interval) {
    this.interval = interval;
    this.timer = 0;
    this.ticks = 0;
  }

  int getTicks()
  {
    return ticks;
  }

  void reset()
  {
    ticks = 0;
  }


  boolean update() {
    if (millis() > timer) {
      timer = millis() + interval;
      ticks++;
      return true;
    } else {
      return false;
    }
  }
}
