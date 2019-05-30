Timer randomPegTimer = new Timer(200);

void randomPegs()
{
  randomPegTimer.setInterval(config.randomPegSpeed);

  if (randomPegTimer.update()) {
    grid.setAllRandom();
  }
}

void startLoadingSequence()
{
  loadingBar.reset();
  loadingBar.start();
  actionTimer.start();
}

Timer actionTimer = new Timer(400);
void loadScreen()
{
  if (loadingBar.isLoading()) {
    loadingBar.draw();
    actionTimer.reset();
  } else {
    if (actionTimer.update())
    {
      int ticks = actionTimer.getTicks();
      if (ticks < 8)
      {
        grid.setAllRandom();
      } else if (ticks == 8 && actionTimer.isEnabled()) {
        config.loadingSequenceEnabled = false;
        actionTimer.stop();
        grid.setAllOff();
        config.scrollSpeed = 20;
        title.start();
      } /*else if (!title.isRunning() && !actionTimer.isEnabled()){
       println("Starting timer");
       
       actionTimer.start();
       } else if (ticks >12) {
       config.loadingSequenceEnabled = false;
       grid.setAllOff();
       } else{
       grid.setAllRandom();
       }
       */
    }
  }
}

float rc;
void rainbowCycle()
{
  rc = (rc >= 255) ? (0) : (rc + config.rainbowSpeed);

  colorMode(HSB, 255);
  for (int i=0; i < PegGrid.GRID_W; i++) {
    for (int j=0; j < PegGrid.GRID_H; j++) {
      grid.setColorAtCoord(i, j, color(rc, 255, 255));
    }
  }
  colorMode(RGB, 255);
}


color Wheel(byte WheelPos) {
  if (WheelPos < 85) {
    return color(WheelPos * 3, 255 - WheelPos * 3, 0);
  } else if (WheelPos < 170) {
    WheelPos -= 85;
    return color(255 - WheelPos * 3, 0, WheelPos * 3);
  } else {
    WheelPos -= 170;
    return color(0, WheelPos * 3, 255 - WheelPos * 3);
  }
}
