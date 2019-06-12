Timer randomPegTimer = new Timer(200);
Timer actionTimer = new Timer(400);

void startEffectTimers()
{
  randomPegTimer.start();
  actionTimer.start();
}

void randomPegs()
{
  randomPegTimer.setInterval(config.randomPegSpeed);

  if (randomPegTimer.update()) {
    grid.setAllRandom();
  }
}

void randomPegsScreensaver()
{
  randomPegTimer.setInterval(config.randomPegSpeed);

  if (randomPegTimer.update()) {
    ghostGrid.setAllRandom();
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

void rainbowCycleScreensaver()
{
  rc = (rc >= 255) ? (0) : (rc + config.rainbowSpeed);

  colorMode(HSB, 255);
  for (int i=0; i < PegGrid.GRID_W; i++) {
    for (int j=0; j < PegGrid.GRID_H; j++) {
      ghostGrid.setColorAtCoord(i, j, color(rc, 255, 255));
    }
  }
  colorMode(RGB, 255);
}

void startLoadingSequence()
{
  loadingBar.reset();
  loadingBar.start();
  actionTimer.start();
}


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



final double THRESHOLD = .01;
public int getColorFromHue(float hue)
{
  String hueStr = nf(hue, 0, 3);
  int startColor = Colors.RED;
  int currentColor = startColor;
  //nf(hue(color(currentColor)), 0, 3);
  
  if(hue == 0)
  {
   return 0; 
  }
  
  do {
    //String currentColorStr = nf(hue(color(currentColor)), 0, 3);
    //println("currently comparing " + currentColorStr + " to " + hueStr);
    if(nf(hue(color(currentColor)), 0, 3).compareTo(hueStr) == 0 ){
      //println(Colors.getColorAsString(color(hue)) + " == " + Colors.getColorAsString(currentColor));
      //println("Returning " + Colors.getColorAsString(currentColor));
      return currentColor;
    }
    /*
    if (Math.abs(hue - hue(color(currentColor)) ) < THRESHOLD) {
      println(Colors.getColorAsString(color(hue)) + " == " + Colors.getColorAsString(currentColor));
      //System.out.println("f1 and f2 are equal using threshold\n");
      return currentColor;
    } else {
      //System.out.println("f1 and f2 are not equal using threshold\n");
      println(Colors.getColorAsString(color(hue)) + " != " + Colors.getColorAsString(currentColor));
    }
*/


    currentColor = Colors.nextColor(currentColor);
  } while (currentColor != startColor);
  return Colors.BLACK;
}
