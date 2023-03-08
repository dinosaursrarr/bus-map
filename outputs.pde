//choose a folder to record into, otherwise stop
void movieChooser(java.io.File selection) {
  selectedFrames = true;
  if (selection == null) {
    filmRecord = false;
    movieOutput = null;
    println("No folder chosen to save movie frames to");
  }
  else {
    movieOutput = selection.getAbsolutePath();
    println("Starting recording at frame " + frameCount + " and saving in " + movieOutput);
  }
}

void screenshotChooser(java.io.File selection) {
  selectedScreenshot = true;
  if (selection == null) {
    println("Cannot save screenshots unless you select a folder to save them into");
  }
  else {
    screenshotOutput = selection.getAbsolutePath();
  }
}

void saveScreenshot() {
  if (screenshotOutput != null) {
    java.io.File folder = new java.io.File(screenshotOutput);
    int exportFileCount = folder.list().length;
    //it wouldn't read the screenshot type from the variable - it would only save as png otherwise
    if (screenshotType.equals("jpg") || screenshotType.equals("jpeg")) {
      save(screenshotOutput + "/" + exportFileCount + "-busMap.jpg");
    }
    else if (screenshotType.equals("png")) {
      save(screenshotOutput + "/" + exportFileCount + "-busMap.png");
    }
    else if (screenshotType.equals("tga")) {
      save(screenshotOutput + "/" + exportFileCount + "-busMap.tga");
    }
    else {
      save(screenshotOutput + "/" + exportFileCount + "-busMap.tif");
    }
    println("Saved screenshot at " + screenshotOutput + "/" + exportFileCount + "-busMap." + screenshotType);
  }
}
