public class ScrollingText
{

  PFont font;
  int fontSize = 500;
  int currentX;

  String text;

  boolean loop = false;
  boolean isRunning = false;
  boolean prevRunning = false;

  ScrollingText() {
    font = createFont("BPdotsSquareBold.otf", 110);
    this.text = "LITEBRITE";
    this.currentX = width;
  }

  void start() 
  {
    currentX = width;
    isRunning = true;
  }
  
  boolean hasFinished()
  {
    return (prevRunning && !isRunning);
  }
  
  boolean isRunning()
  {
   return isRunning; 
  }

  void stop() 
  {
    currentX = width;
    isRunning = false;
  }

  void setLooping(boolean loop)
  {
    this.loop = loop;
  }


  void setText(String text)
  {
    this.text = text;
  }

  void draw()
  {
    prevRunning = isRunning;
    if (!isRunning) {
      return;
    }
    pushMatrix();
    pushStyle();


    textFont(font);
    textSize(fontSize); 
    textAlign(LEFT, CENTER);
    fill(color(255, 255, 255));  // Set fill to white
    text(text, currentX, (height/2.2));

    if (currentX + int(textWidth(text)) > 0) {
      currentX -= config.scrollSpeed;
    } else {
      if (!loop) {
        println("NOT RUNNING.");
        isRunning = false;
      }
      currentX = width;
    }

    popMatrix();
    popStyle();
  }
}
