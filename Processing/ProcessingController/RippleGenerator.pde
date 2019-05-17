public class RippleGenerator
{
  int lifespan;

  ArrayList<Ripple> ripples;//an arraylist of the waves emitted
  
  RippleGenerator(int lifespan) {
    this.lifespan = lifespan;
    
    ripples = new ArrayList<Ripple>();
  }

  void addRipple(Point p, color c)
  {
    if(ripples == null){
      ripples = new ArrayList<Ripple>();
    }
     ripples.add(new Ripple(8, p, c, lifespan)); 
  }

  void draw() {

    for (int i = ripples.size ()-1; i>=0; i--) {
      Ripple rip = ripples.get(i);
      rip.draw();

      if ( !rip.isAlive() ) {
        ripples.remove(i);
      }
    }

/*
    if (cycles%(period*2)==0) {
      println("Adding ripple.");
      ripples.add(new Ripple(2, new Point(x, y), color(255, 255, 255), 200));
    } else if (cycles%(period*2)==period) {
      println("Adding ripple.");
      ripples.add(new Ripple(2, new Point(x, y), color(0, 0, 0), 200));
    }

    cycles++;
    */
  }
}

class Ripple //a circle with an increasing radius
{ 

  boolean showOrigin = true;

  Point position;

  float velocity;//the speed of the waves
  float radius;//the distance the wave has traveled
  color c;//the color reprasents weather it's a top or buttom

  int lifesize; //the max size of the ripple before it dies.


  Ripple(float velocity, Point p, color c, int lifesize) {
    this.position = p;
    this.velocity = velocity;
    this.c = c;
    this.radius = 0;

    this.lifesize = lifesize;
  }

  boolean isAlive()
  {
    return (radius < lifesize);
  }

  void draw() {
    /*
    if (showOrigin) {
      fill(0);//display and move the generator
      ellipse(position.getX(), position.getY(), 10, 10);
    }
    */
    
    radius += velocity;
    strokeWeight(20);
    stroke(c);
    noFill();

    ellipse(position.getX(), position.getY(), radius*2, radius*2);
    
    strokeWeight(1);
  }
}

