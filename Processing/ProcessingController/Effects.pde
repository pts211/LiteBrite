Timer randomPegTimer = new Timer(200);

void randomPegs()
{
  if (randomPegTimer.update()) {
    grid.setAllRandom();
  }
}

void startLoadingSequence()
{
  loadingBar.reset();
  loadingBar.start();
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
      grid.setAllRandom();
    } else if (actionTimer.getTicks() > 8) {
      config.loadingSequenceEnabled = false;
      grid.setAllOff();
    }
  }
}

float c;
void rainbowCycle()
{
  //if (c >= 255)  c=0;  else  c++;
  c = (c >= 255) ? (0) : (c+config.rainbowSpeed);
  for (int i=0; i < PegGrid.GRID_W; i++) {
    for (int j=0; j < PegGrid.GRID_H; j++) {
      colorMode(HSB, 255);
      grid.setColorAtCoord(i, j, color(c, 255, 255));
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
