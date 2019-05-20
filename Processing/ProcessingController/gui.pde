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
  bttn_ = new GButton(settings, 20, 380, 80, 30);
  bttn_.setText("Clear");
  bttn_.addEventHandler(this, "bttn_clear_click");
  bttn_saveImg = new GButton(settings, 20, 340, 80, 30);
  bttn_saveImg.setText("Save");
  bttn_saveImg.addEventHandler(this, "bttn_saveImg_click");
  cbx_desktop = new GCheckbox(settings, 10, 160, 120, 20);
  cbx_desktop.setIconAlign(GAlign.LEFT, GAlign.MIDDLE);
  cbx_desktop.setText("Show Desktop");
  cbx_desktop.setOpaque(false);
  cbx_desktop.addEventHandler(this, "cbx_desktop_clicked");
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
