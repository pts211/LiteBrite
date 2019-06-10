public class LoadingBar
{

  final int fontSize = 220;
  final int offsetX = 13;
  final int offsetY = 9;

  PFont dotMatrix;

  int totalDist;
  int startPos;

  int speed;
  boolean reversed;
  float duration;

  int currentPos;

  boolean isPlaying = false;
  boolean isLoading = false;

  int count = 0;
  int nextAction = 0;
  int holdCounts = 10;


  int percent;

  Timer timer;


  LoadingBar() {
    timer = new Timer(65);
    this.percent = 0;

    //dotMatrix = createFont("DOTMATRI.TTF", 110);
    dotMatrix = createFont("DOTMBold.TTF", 110);

    this.duration = 5;
    this.reversed = false;

    if (reversed) {
      this.startPos = 0;
      this.totalDist = width;
    } else {
      this.startPos = width;
      this.totalDist = 0;
    }
    this.currentPos = startPos;
  }

  void setDuration(float duration)
  {
    this.duration = duration;
  }

  boolean isPlaying()
  {
    return isPlaying;
  }

  void start()
  {
    isLoading = true;
  }

  void stop()
  {
    isLoading = false;
  }

  void reset()
  {
    isLoading = false;
    count = 0;
    percent = 0;
  }

  boolean isLoading()
  {
    return isLoading;
  }

  void draw()
  {
    pushMatrix();
    pushStyle();


    if (timer.update()) {
      count++;
      if(count < holdCounts+10){
        isLoading = true;
      }else if (percent < 100) {
        percent++;
        isLoading = true;
      } else if (percent == 100 && nextAction == 0) {
        nextAction = count + holdCounts;
      } else {
        if (count > nextAction) {
          isLoading = false;
        }
      }
    }
    rectMode(CORNER);
    fill(color(255, 0, 0));  // Set fill to white
    rect(0, 0, ((width/100)*percent), height);  // Draw white rect using CORNER mode

    textFont(dotMatrix);
    textSize(230); 
    textAlign(LEFT, CENTER);
    fill(color(255, 255, 255));  // Set fill to white
    text(percent+"%", (width/3)-30, (height/2.2));
    /*
    else{
     rectMode(CORNER);
     fill(color(255, 0, 0));  // Set fill to white
     rect(0, 0, width, height);  // Draw white rect using CORNER mode
     
     textFont(dotMatrix);
     textSize(230); 
     textAlign(LEFT, CENTER);
     fill(color(255, 255, 255));  // Set fill to white
     text("DONE.", (width/3)-100, (height/2.2));
     }*/


    popMatrix();
    popStyle();
  }
}
