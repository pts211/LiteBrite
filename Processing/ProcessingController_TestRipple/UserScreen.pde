
class UserScreen extends PApplet {
  
  //Image loading
  int currentImg = -1;
  PImage[] imgs;

  ImageCarousel ic;

  UserScreen() {
    super();
    PApplet.runSketch(new String[] {
      this.getClass().getSimpleName()
    }
    , this);
  }

  void settings() {
    size(1000, 800);
    println("UserScreen: Creating ImageCarousel."); 
    ic = new ImageCarousel(width, height);
    println("UserScreen: Creating ImageCarousel. Done.");
  }

  void setup() {
    settings();
    background(150);
  }

  void draw() {
    background(0);
    ic.draw();
    
    imageMode(CENTER);
    image(ic.getDisplay(), width/2, height/2);
    //ellipse(random(width), random(height), random(50), random(50));
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

