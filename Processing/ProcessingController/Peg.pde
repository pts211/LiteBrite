public class Peg
{
  
  int diameter = 20;
  Point p;
  color c;
  
  Peg(Point p){
    this.p = p;
    this.c = #ffffff;
  }
  
  Point getPoint()
  {
    return this.p; 
  }
  
  int getX()
  {
    return this.p.getX(); 
  }
  
  int getY()
  {
    return this.p.getY(); 
  }
  
  void setColor(color c)
  {
    this.c = c; 
  }
  
  void nextColor()
  {
    this.c = Colors.nextColor(this.c); 
  }
  
  void draw()
  {
    fill(c);
    ellipse(p.getX(), p.getY(), diameter, diameter);
  }
  
  
  
}
