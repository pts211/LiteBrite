
class ImageCarousel {
  
  int windowW;
  int windowH;

  PGraphics display;

  //Image loading
  int currentImg = -1;
  PImage[] imgs;

  Point lp;
  int lpWidth;
  int lpHeight;


  ImageCarousel(int w, int h) {
    this.windowW = w;
    this.windowH = h;
    
    settings();
    println("UserScreen width: " + windowW);
    println("UserScreen height: " + windowH);
    
  }


  void settings()
  {
    lp = new Point(windowW/2, windowH/3);
    lpWidth = int(windowW*0.8);
    lpHeight = int(lpWidth / ASPECT_RATIO);
    println("lpWidth: " + lpWidth);
    println("lpHeight: " + lpHeight);

    display = createGraphics(windowW, windowH);
  }

  void draw() {

    display.beginDraw();
    display.background(200);
    display.stroke(255);
    display.rectMode(CENTER);
    display.rect(lp.getX(), lp.getY(), lpWidth, lpHeight);
    display.endDraw();


    //Large Preview
    //rectMode(CENTER);

    //ellipse(random(width), random(height), random(50), random(50));
    //rect(lp.getX(), lp.getY(), lpWidth, lpHeight);
    //ellipse(random(width), random(height), random(50), random(50));
  }
  
  PGraphics getDisplay()
  {
    return display;
  }

  void mousePressed() {
    println("mousePressed in secondary window");
  }


  void loadImages()
  {
    println("UserScreen: Loading Images.");
    //Image loading
    String path = "/Users/ps022648/Desktop/DevCon/GIT/LiteBrite/Processing/ProcessingController/images";
    println("\tpath: " + path);
    String[] filenames = listFileNames(path);
    printArray(filenames);

    imgs = new PImage[filenames.length];
    for (int i = 0; i < filenames.length; i++) {
      imgs[i] = loadImage(path+"/"+filenames[i]);
    }
    println("Controller: Loading Images. Done.");
  }
}
