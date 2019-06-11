
public class Clock
{
  int hour, minute, second;

  Clock() {
    hour = hour();
    minute = minute();
    second = second();
  }


  private void update()
  {
    hour = hour();
    minute = minute();
    second = second();
  }

  public void processTriggers()
  {
    update();
    if ( hour >= 18 && hour < 24 || hour < 6)
    {
      //NIGHT TIME - Sleep
      config.isSleeping = true;
    } else {
      config.isSleeping = false;
    }

    if ( hour >= 6 && hour < 10 )
    {
      config.isMorning = true;
    }
  }
}
