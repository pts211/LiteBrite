import java.util.Random;

public static class Colors
{
  private static Random rand = new Random();
  
  public final static int RED = #ff0000;
  public final static int GREEN = #00ff00;
  public final static int BLUE = #0000ff;
  public final static int MAGENTA = #ff00ff;
  public final static int YELLOW = #ffff00;
  public final static int CYAN = #00ffff;
  public final static int WHITE = #ffffff;
  public final static int BLACK = #000000;  
  
  Colors(){}
  
  public static int nextColor(int current)
  {
    switch(current)
    {
      case RED:
        return GREEN;
      case GREEN:
        return BLUE;
      case BLUE:
        return MAGENTA;
      case MAGENTA:
        return YELLOW;
      case YELLOW:
        return CYAN;
      case CYAN:
        return WHITE;
      case WHITE:
        return BLACK;
      case BLACK:
        return RED;
      default:
        return Colors.WHITE;
  }
  }
  
  public static int randomColor()
  {
    int n = rand.nextInt(8);

    switch(n)
    {
      case 1:
        return GREEN;
      case 2:
        return BLUE;
      case 3:
        return MAGENTA;
      case 4:
        return YELLOW;
      case 5:
        return CYAN;
      case 6:
        return WHITE;
      case 7:
        return BLACK;
      case 8:
        return RED;
      default:
        return Colors.WHITE;
    }
  }

  
}
