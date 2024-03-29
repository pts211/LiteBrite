import java.io.*; 
import java.util.*;

public class PlaybackManager
{

  String path;
  File[] files;
  int activeFileIdx = 0;

  Playback activePlayback;

  PlaybackManager() {
    //this.path = "/Users/ps022648/Desktop/LiteBrite_Capture/20190611-20190620/current";
    this.path = dataPath("../../../" + config.RELATIVE_PLAYBACK_DIRETCTORY);
    println("path: " + this.path);
    this.files = loadFiles(path);
  }

  PlaybackManager(String directory) {
    this.path = directory;
    this.files = loadFiles(path);
  }
  
  void refreshFiles()
  {
    this.files = loadFiles(path);
    this.activeFileIdx = 0;
  }

  void setRandomIndex()
  {
    activeFileIdx = int( random(0, files.length-1) );
  }

  String getActiveFilePath()
  {
    return files[activeFileIdx].getAbsolutePath();
  }

  String getActiveFileName()
  {
    return files[activeFileIdx].getName();
  }

  File getActiveFile()
  {
    return files[activeFileIdx];
  }
  
  String previousFilePath() {
    if ( --activeFileIdx < 0) {
      println("END OF FILE LIST");
      println("END OF FILE LIST");
      println("END OF FILE LIST");
      println("END OF FILE LIST");
      activeFileIdx = files.length - 1;
    }
    println(files[activeFileIdx].getAbsolutePath());
    return files[activeFileIdx].getAbsolutePath();
  }

  String nextFilePath() {
    if ( ++activeFileIdx >= files.length) {
      println("END OF FILE LIST");
      println("END OF FILE LIST");
      println("END OF FILE LIST");
      println("END OF FILE LIST");
      activeFileIdx = 0;
    }
    println(files[activeFileIdx].getAbsolutePath());
    return files[activeFileIdx].getAbsolutePath();
  }

  void listFiles()
  {
    println("\nListing info about all files in a directory: ");

    for (int i = 0; i < files.length; i++) {
      File f = files[i];   
      if (!f.isDirectory()) {
        println("Full path: " + f.getAbsolutePath());
      }
    }
  } 

  // This function returns all the files in a directory as an array of File objects
  // This is useful if you want more info about the file
  File[] loadFiles(String dir) 
  {
    File file = new File(dir);
    if (file.isDirectory()) {
      File[] files = file.listFiles();
      return files;
    } else {
      return null;
    }
  }
}
