public class Peg
{
  
  int DIAMETER = 20;
  Point p;
  color c;
  
  Peg(Point p){
    this.p = p;
    this.c = Colors.BLACK;
  }
  
  Peg(Point p, int dia){
    this.p = p;
    this.c = Colors.BLACK;
    this.DIAMETER = dia;
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
    stroke(#ffffff);
    ellipse(p.getX(), p.getY(), DIAMETER, DIAMETER);
    //stroke(#ffffff);
    //arc(p.getX(), p.getY(), DIAMETER, DIAMETER, 0, 2*3.14159);
    
  }
  
  
  
}
