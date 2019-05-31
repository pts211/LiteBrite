/* =========================================================
 * ====                   WARNING                        ===
 * =========================================================
 * The code in this tab has been generated from the GUI form
 * designer and care should be taken when editing this file.
 * Only add/edit code inside the event handlers i.e. only
 * use lines between the matching comment tags. e.g.

 void myBtnEvents(GButton button) { //_CODE_:button1:12356:
     // It is safe to enter your event code here  
 } //_CODE_:button1:12356:
 
 * Do not rename this tab!
 * =========================================================
 */

synchronized public void settings_draw(PApplet appc, GWinData data) { //_CODE_:settings:557361:
  appc.background(230);
} //_CODE_:settings:557361:

public void cbx_ripple_clicked(GCheckbox source, GEvent event) { //_CODE_:cbx_ripple:843597:
  println("cbx_ripple - GCheckbox >> GEvent." + event + " @ " + millis());
  config.rippleEnabled = cbx_ripple.isSelected();
} //_CODE_:cbx_ripple:843597:

public void bttn_clear_click(GButton source, GEvent event) { //_CODE_:bttn_:607940:
  println("button1 - GButton >> GEvent." + event + " @ " + millis());
  grid.setAllOff();
} //_CODE_:bttn_:607940:

public void bttn_saveImg_click(GButton source, GEvent event) { //_CODE_:bttn_saveImg:999764:
  println("button1 - GButton >> GEvent." + event + " @ " + millis());
  saveFrame();
} //_CODE_:bttn_saveImg:999764:

public void cbx_desktop_clicked(GCheckbox source, GEvent event) { //_CODE_:cbx_desktop:798569:
  println("cbx_desktop - GCheckbox >> GEvent." + event + " @ " + millis());
  config.showDesktop = cbx_desktop.isSelected();
} //_CODE_:cbx_desktop:798569:

public void bttn_intro_click(GButton source, GEvent event) { //_CODE_:bttn_intro:966216:
  println("bttn_intro - GButton >> GEvent." + event + " @ " + millis());
  config.loadingSequenceEnabled = true;
  startLoadingSequence();
} //_CODE_:bttn_intro:966216:

public void sld_brightness_change(GSlider source, GEvent event) { //_CODE_:sld_brightness:248301:
  //println("slider1 - GSlider >> GEvent." + event + " @ " + millis());
  grid.setAllBrightness(source.getValueI());
} //_CODE_:sld_brightness:248301:

public void cbx_random_clicked(GCheckbox source, GEvent event) { //_CODE_:cbx_random:585846:
  println("cbx_random - GCheckbox >> GEvent." + event + " @ " + millis());
  config.randomPegsEnabled = cbx_random.isSelected();
  if (!config.randomPegsEnabled) {
    grid.setAllOff();
  }else{
    config.randomPegSpeed = int(sld_randPegSpeed.getValueF() * 1000); 
  }
} //_CODE_:cbx_random:585846:

public void cbx_rainbow_clicked(GCheckbox source, GEvent event) { //_CODE_:cbx_rainbow:294234:
  println("cbx_rainbow - GCheckbox >> GEvent." + event + " @ " + millis());
  config.rainbowEnabled = cbx_rainbow.isSelected();
  if (!config.rainbowEnabled) {
    grid.setAllOff();
  } else {
    config.rainbowSpeed = sld_rainSpeed.getValueF();
  }
} //_CODE_:cbx_rainbow:294234:

public void sld_rainSpeed_change(GSlider source, GEvent event) { //_CODE_:sld_rainSpeed:356317:
  println("sld_rainSpeed - GSlider >> GEvent." + event + " @ " + millis());
  config.rainbowSpeed = source.getValueF();
} //_CODE_:sld_rainSpeed:356317:

public void bttn_scrollingText_click(GButton source, GEvent event) { //_CODE_:bttn_scrollingText:631403:
  println("button1 - GButton >> GEvent." + event + " @ " + millis());
  title.start();
} //_CODE_:bttn_scrollingText:631403:

public void sld_randPegSpeed_change(GSlider source, GEvent event) { //_CODE_:sld_randPegSpeed:729248:
  println("slider1 - GSlider >> GEvent." + event + " @ " + millis());
  config.randomPegSpeed = int(source.getValueF() * 1000);
} //_CODE_:sld_randPegSpeed:729248:

public void sld_scrollSpeed_change(GSlider source, GEvent event) { //_CODE_:sld_scrollSpeed:237074:
  println("slider2 - GSlider >> GEvent." + event + " @ " + millis());
  config.scrollSpeed = sld_scrollSpeed.getValueI();
} //_CODE_:sld_scrollSpeed:237074:

public void cbx_scrollingTextLoop_clicked(GCheckbox source, GEvent event) { //_CODE_:cbx_scrollingTextLoop:257090:
  println("checkbox1 - GCheckbox >> GEvent." + event + " @ " + millis());
  config.scrollingTextLoopEnabled = cbx_scrollingTextLoop.isSelected();
  title.setLooping(config.scrollingTextLoopEnabled);
} //_CODE_:cbx_scrollingTextLoop:257090:

public void cbx_capture_time_clicked1(GCheckbox source, GEvent event) { //_CODE_:cbx_capture_time:805883:
  println("cbx_capture_time - GCheckbox >> GEvent." + event + " @ " + millis());
  config.captureUsageEnabled = cbx_capture_time.isSelected();
} //_CODE_:cbx_capture_time:805883:

public void sld_paintColor_change1(GSlider source, GEvent event) { //_CODE_:sld_paintColor:615317:
  println("slider1 - GSlider >> GEvent." + event + " @ " + millis());
  int rc = sld_paintColor.getValueI();
  colorMode(HSB, 255);
  updatePaintColorView(color(rc, 255, 255));
  colorMode(RGB, 255);
} //_CODE_:sld_paintColor:615317:



// Create all the GUI controls. 
// autogenerated do not edit
public void createGUI(){
  G4P.messagesEnabled(false);
  G4P.setGlobalColorScheme(GCScheme.BLUE_SCHEME);
  G4P.setMouseOverEnabled(false);
  surface.setTitle("LiteBrite Controller");
  settings = GWindow.getWindow(this, "Settings", 0, 0, 800, 600, P3D);
  settings.noLoop();
  settings.setActionOnClose(G4P.KEEP_OPEN);
  settings.addDrawHandler(this, "settings_draw");
  label_settings = new GLabel(settings, 10, 100, 80, 20);
  label_settings.setTextAlign(GAlign.CENTER, GAlign.MIDDLE);
  label_settings.setText("Settings");
  label_settings.setTextBold();
  label_settings.setOpaque(false);
  cbx_ripple = new GCheckbox(settings, 10, 130, 120, 20);
  cbx_ripple.setIconAlign(GAlign.LEFT, GAlign.MIDDLE);
  cbx_ripple.setText("Ripple Effect");
  cbx_ripple.setOpaque(false);
  cbx_ripple.addEventHandler(this, "cbx_ripple_clicked");
  bttn_ = new GButton(settings, 700, 560, 80, 30);
  bttn_.setText("Clear");
  bttn_.addEventHandler(this, "bttn_clear_click");
  bttn_saveImg = new GButton(settings, 700, 520, 80, 30);
  bttn_saveImg.setText("Save");
  bttn_saveImg.addEventHandler(this, "bttn_saveImg_click");
  cbx_desktop = new GCheckbox(settings, 10, 160, 120, 20);
  cbx_desktop.setIconAlign(GAlign.LEFT, GAlign.MIDDLE);
  cbx_desktop.setText("Show Desktop");
  cbx_desktop.setOpaque(false);
  cbx_desktop.addEventHandler(this, "cbx_desktop_clicked");
  bttn_intro = new GButton(settings, 10, 40, 80, 30);
  bttn_intro.setText("Intro Sequence");
  bttn_intro.addEventHandler(this, "bttn_intro_click");
  sld_brightness = new GSlider(settings, 190, 310, 293, 44, 20.0);
  sld_brightness.setLimits(1, 0, 100);
  sld_brightness.setNumberFormat(G4P.INTEGER, 0);
  sld_brightness.setOpaque(false);
  sld_brightness.addEventHandler(this, "sld_brightness_change");
  cbx_random = new GCheckbox(settings, 10, 190, 120, 20);
  cbx_random.setIconAlign(GAlign.LEFT, GAlign.MIDDLE);
  cbx_random.setText("Random Pegs");
  cbx_random.setOpaque(false);
  cbx_random.addEventHandler(this, "cbx_random_clicked");
  cbx_rainbow = new GCheckbox(settings, 10, 220, 120, 20);
  cbx_rainbow.setIconAlign(GAlign.LEFT, GAlign.MIDDLE);
  cbx_rainbow.setText("Rainbow Effect");
  cbx_rainbow.setOpaque(false);
  cbx_rainbow.addEventHandler(this, "cbx_rainbow_clicked");
  sld_rainSpeed = new GSlider(settings, 140, 210, 190, 40, 10.0);
  sld_rainSpeed.setShowValue(true);
  sld_rainSpeed.setLimits(1.0, 0.01, 10.0);
  sld_rainSpeed.setNumberFormat(G4P.DECIMAL, 2);
  sld_rainSpeed.setOpaque(false);
  sld_rainSpeed.addEventHandler(this, "sld_rainSpeed_change");
  bttn_scrollingText = new GButton(settings, 9, 249, 121, 21);
  bttn_scrollingText.setText("Scrolling Text");
  bttn_scrollingText.addEventHandler(this, "bttn_scrollingText_click");
  sld_randPegSpeed = new GSlider(settings, 140, 180, 190, 40, 10.0);
  sld_randPegSpeed.setShowValue(true);
  sld_randPegSpeed.setLimits(0.5, 0.0, 1.0);
  sld_randPegSpeed.setNumberFormat(G4P.DECIMAL, 2);
  sld_randPegSpeed.setOpaque(false);
  sld_randPegSpeed.addEventHandler(this, "sld_randPegSpeed_change");
  sld_scrollSpeed = new GSlider(settings, 140, 240, 190, 40, 10.0);
  sld_scrollSpeed.setShowValue(true);
  sld_scrollSpeed.setLimits(5, 0, 100);
  sld_scrollSpeed.setNumberFormat(G4P.INTEGER, 0);
  sld_scrollSpeed.setOpaque(false);
  sld_scrollSpeed.addEventHandler(this, "sld_scrollSpeed_change");
  cbx_scrollingTextLoop = new GCheckbox(settings, 340, 250, 120, 20);
  cbx_scrollingTextLoop.setIconAlign(GAlign.LEFT, GAlign.MIDDLE);
  cbx_scrollingTextLoop.setText("Loop");
  cbx_scrollingTextLoop.setOpaque(false);
  cbx_scrollingTextLoop.addEventHandler(this, "cbx_scrollingTextLoop_clicked");
  cbx_capture_time = new GCheckbox(settings, 590, 520, 110, 30);
  cbx_capture_time.setIconAlign(GAlign.LEFT, GAlign.MIDDLE);
  cbx_capture_time.setText("Capture Usage");
  cbx_capture_time.setOpaque(false);
  cbx_capture_time.addEventHandler(this, "cbx_capture_time_clicked1");
  paintColor_view = new GView(settings, 330, 500, 80, 70, P3D);
  sld_paintColor = new GSlider(settings, 20, 500, 310, 70, 30.0);
  sld_paintColor.setLimits(255, 0, 255);
  sld_paintColor.setNumberFormat(G4P.INTEGER, 0);
  sld_paintColor.setOpaque(false);
  sld_paintColor.addEventHandler(this, "sld_paintColor_change1");
  settings.loop();
}

// Variable declarations 
// autogenerated do not edit
GWindow settings;
GLabel label_settings; 
GCheckbox cbx_ripple; 
GButton bttn_; 
GButton bttn_saveImg; 
GCheckbox cbx_desktop; 
GButton bttn_intro; 
GSlider sld_brightness; 
GCheckbox cbx_random; 
GCheckbox cbx_rainbow; 
GSlider sld_rainSpeed; 
GButton bttn_scrollingText; 
GSlider sld_randPegSpeed; 
GSlider sld_scrollSpeed; 
GCheckbox cbx_scrollingTextLoop; 
GCheckbox cbx_capture_time; 
GView paintColor_view; 
GSlider sld_paintColor; 
