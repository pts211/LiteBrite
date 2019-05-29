
public class AnimatedTransistion
{
  Gif gif;
  int totalDist;
  int startPos;
  int speed;
  boolean reversed;

  float duration;

  int currentPos;

  boolean isPlaying = false;


  AnimatedTransistion(Gif gif, float duration, boolean reversed) {
    this.gif = gif;
    this.duration = duration;
    this.reversed = reversed;

    if (reversed) {
      this.startPos = gif.width *2;
    } else {
      this.startPos = -gif.width *2;
    }
    this.currentPos = startPos;

    totalDist = Math.abs(startPos) + width;

    //println("total distance is:" + totalDist);
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
    //30fps
    //dist 1760
    speed = int(totalDist/(frameRate*duration));
    if (reversed) {
      speed *= -1;
    }
    println("framerate: " + frameRate);
    println("speed: " + speed);
    gif.play();
    isPlaying = true;
  }

  void reset()
  {
    isPlaying = false;
    currentPos = startPos;
    gif.stop();
  }

  void draw()
  {
    pushMatrix();
    pushStyle();
    imageMode(CORNER);
    image(gif, currentPos, 0, width, height);
    currentPos += speed;

    if (currentPos > width && !reversed) {
      reset();
    } else if ( currentPos < (-gif.width*2) && reversed) {
      reset();
    }
    popMatrix();
    popStyle();
  }
}
