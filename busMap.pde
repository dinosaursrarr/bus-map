//java imports
import java.util.Collections;
import java.util.Iterator;
import java.io.File;
import java.util.Date;

//data containers
busStopList busStops;
stopLabelList stopLabels;
busRouteList busRoutes;
stopPairList stopPairs;
controlList controls;

//what to include?
booleanHolder drawLabels = new booleanHolder(false);
booleanHolder drawStops = new booleanHolder(true);
booleanHolder drawRoutes = new booleanHolder(true);
booleanHolder drawPanel = new booleanHolder(true);
booleanHolder drawControlPanel = new booleanHolder(false);

//map controls
PVector defaultCentreOS = new PVector(531547, 823348); //mostyn gardens, in lambeth
PVector centreOS = new PVector(defaultCentreOS.x, defaultCentreOS.y); //centre on the OS Grid map //starting detail
floatHolder zoomFactor = new floatHolder(0.0075, 0.0005, 0.02);

//make it resizable
boolean runOnce = false; //don't want to check for resizing on first go, as it hasn't set up the time/date yet
boolean justResized = false; //need a flag for when it's been resized or the mouse events go wrong -> pmouseX is before resizing, mouseX afterwards so not directly comparable
int currentWidth = 600; //keep track of size so we can resize the window
int currentHeight = 600; //keep track of size so we can resize the window

//labels
intHolder labelMouseRange = new intHolder(5, 0, 10); //how close can you get to a stop before the label pops out?
floatHolder labelWeight = new floatHolder(1, 0, 10); //how thick is the line between label and stop?
PFont newJohnston;
busStop selectedStop;

//selecting a stop
boolean chooseStop = false;
boolean chosenStop = false;

//symbols
PShape tubeLogo;
PShape trainLogo;
PShape dlrLogo;
PShape riverLogo;
PShape tramLogo;

//output of images and movie frames
boolean filmRecord = false;
String movieOutput; //where to save frames?
String screenshotOutput; //where to save screenshots?
boolean selectedConfig = false; //flag to make the program wait for you to choose input/output
boolean selectedScreenshot = false; //flag to make the program wait for you to choose input/output
boolean selectedFrames = false; //flag to make the program wait for you to choose input/output
String screenshotType = "jpg"; //file format for screenshots
String frameType = "tif"; //file format for movie films

//drawing the lines
booleanHolder scaleRouteOpacity = new booleanHolder(false);
floatHolder minRouteOpacity = new floatHolder(50, 0, 255);
floatHolder maxRouteOpacity = new floatHolder(255, 0, 255);
booleanHolder scaleRouteWeight = new booleanHolder(false);
floatHolder minRouteWeight = new floatHolder(1, 0, 10);
floatHolder maxRouteWeight = new floatHolder(10, 0, 10);

//colours
colourHolder backgroundColour = new colourHolder(color(0)); //colour behind it all
colourHolder stopColour = new colourHolder(color(255, 255, 255, 50)); //colour of the stops
colourHolder routeColour = new colourHolder(color(255, 0, 0, 50));
ArrayList<colourHolder> routeColours;

void setup() {
  //initialise the display
  size(800, 600, P2D);
  background(0);
 
//  selectInput("Select a configuration file (optional):", "loadConfig");
//  while(!selectedConfig) {
//    print("");
//  }
 
  //font
  newJohnston = loadFont("JohnstonITC-Medium-12.vlw"); //http://www.rmweb.co.uk/community/index.php?/topic/8826-br-corporate-rail-alphabet-fonts/
  textFont(newJohnston, 12);
  
  //route colours
  routeColours = new ArrayList<colourHolder>();
  routeColours.add(new colourHolder(#3399FF));
  routeColours.add(new colourHolder(#990033));
  routeColours.add(new colourHolder(#00CC33));
  routeColours.add(new colourHolder(#663399));
  routeColours.add(new colourHolder(#CCFF33));
  routeColours.add(new colourHolder(#993300));
  routeColours.add(new colourHolder(#999999));
  routeColours.add(new colourHolder(#FFFFFF));
  routeColours.add(new colourHolder(#CC3333));
  routeColours.add(new colourHolder(#FF6600));
  routeColours.add(new colourHolder(#66FF99));
  routeColours.add(new colourHolder(#CC66CC));
  routeColours.add(new colourHolder(#6666CC));
  routeColours.add(new colourHolder(#99CCCC));
  routeColours.add(new colourHolder(#006633));
  routeColours.add(new colourHolder(#CCCC00));
  routeColours.add(new colourHolder(#CC0000));
  routeColours.add(new colourHolder(#FF9999));
  routeColours.add(new colourHolder(#FF9900));
  routeColours.add(new colourHolder(#6699FF));
  routeColours.add(new colourHolder(#990099));
  routeColours.add(new colourHolder(#33CC33));
  routeColours.add(new colourHolder(#FF9966));
  routeColours.add(new colourHolder(#FFFF99));
  
  //data containers
  stopLabels = new stopLabelList();
  stopPairs = new stopPairList();
  
  //check the data used is fresh -> if not, go get new stuff
  Date d = new Date();
  long currentTime = d.getTime();
  
  String stopsFilename = "busStops.csv";
  String routesFilename = "busRoutes.csv";
  
  File stopsFile = new java.io.File(dataPath(stopsFilename));
//  if ((currentTime - stopsFile.lastModified()) > (1000 * 24 * 60 * 60)) {
//    println("Stops data expired");
//    try {
//      String[] newStops = loadStrings("http://www.dinosaursandmoustaches.com/busStops.csv");
//      File oldStops = new java.io.File(dataPath("old-" + stopsFilename));
//      stopsFile.renameTo(oldStops);
//      saveStrings(dataPath(stopsFilename), newStops);
//      println("New stops data downloaded, attempting to download replacement at " + millis() + " milliseconds");
//    }
//    catch (Exception e) {
//      println("Could not download new bus stop data");
//    }
//  }
  
  File routesFile = new java.io.File(dataPath(routesFilename));
//  if ((currentTime - routesFile.lastModified()) > (1000 * 24 * 60 * 60)) {
//    println("Routes data expired, attempting to download replacement at " + millis() + " milliseconds");
//    try {
//      String[] newRoutes = loadStrings("http://www.dinosaursandmoustaches.com/busRoutes.csv");
//      File oldRoutes = new java.io.File(dataPath("old-" + routesFilename));
//      routesFile.renameTo(oldRoutes);
//      saveStrings(dataPath(routesFilename), newRoutes);
//      println("New routes data downloaded");
//    }
//    catch (Exception e) {
//      println("Could not download new bus route data");
//    }
//  }
  
  //load the data
  busStops = new busStopList(stopsFilename);
  busRoutes = new busRouteList(routesFilename);
  busRoutes.makePairs();
  busStops.sortRoutes();
  
  //load symbols
  tubeLogo = loadShape("tubeRoundel.svg");
  trainLogo = loadShape("National_Rail_logo.svg");
  dlrLogo = loadShape("DLR_no-text_roundel.svg");
  riverLogo = loadShape("riverRoundel.svg");
  tramLogo = loadShape("Tramlink_no-text_roundel.svg");
  
  controls = new controlList();
  controls.load();
  
  //make the window resizable!
  registerMethod("pre", this);
  if (surface != null) {
    surface.setResizable(true);
  }
}

//makeshift window update event
void pre() {
  if (runOnce && (width != currentWidth || height != currentHeight)) {
    if ((width < 600) || (height < 400)) {
      surface.setSize(max(width, 600), max(height, 400));
    }
    busStops.updateScreen();
    stopPairs.updateScreen();
    controls.errorText = wordWrap("Insufficient room to draw the control panel.", width - 50);
    controls.widthText = wordWrap("Please make the window wider.", width - 50);
    controls.heightText = wordWrap("Please make the window taller.", width - 50);
    justResized = true;
    currentWidth = width;
    currentHeight = height;
  }
}

void draw() {
  runOnce = true;
  background(backgroundColour.value);
  
  //draw the bus routes - either everything or ones for the selected stop
  if (drawRoutes.value) {
    if (selectedStop == null) {
      stopPairs.draw();
    }
    else {
      selectedStop.drawRoutes();
    }
  }
  
  //draw points for the stops
  busStops.draw(); //the toggle occurs inside the function
  
  //draw labels when you mouse over
  if (drawLabels.value) {
    stopLabels.draw();
  }
  
  //draw details of the stop you last clicked on
  if (drawPanel.value) {
    if (selectedStop != null) {
      selectedStop.drawDetails();
    }
  }
  
  if (drawControlPanel.value) {
    controls.draw();
  }
  
  if (!drawControlPanel.value) {
    //buttons at the bottom of the screen
    if (mouseY <= 100) {
      colorMode(RGB, 60);
      int alphaValue = 100 - mouseY;
      if (mouseY <= 40) {
        alphaValue = 60;
      }
      
      //draw the boxes
      int boxWidth = int((width - 40.0) / 4); 
      noFill();
      stroke(255, 255, 255, alphaValue);
      strokeWeight(1);
      rect(10, 10, boxWidth, 24); //control panel
      rect(10 + (1 * (boxWidth + 5)), 10, boxWidth, 24); //save config
      rect(10 + (2 * (boxWidth + 5)), 10, boxWidth, 24); //take screenshot
      if (filmRecord) {
        fill(255, 255, 255, alphaValue);
      }
      else {
        noFill();
      }
      rect(10 + (3 * (boxWidth + 5)), 10, boxWidth, 24); //record frames
      
      //draw the text
      fill(255, 255, 255, alphaValue);
      textAlign(CENTER);
      text("Controls", (20 + (1 * boxWidth)) / 2, 26);
      text("Save config", (20 + (3 * (5 + boxWidth))) / 2, 26);
      text("Screenshot", (20 + (5 * (5 + boxWidth))) / 2, 26);
      if (filmRecord) {
        fill(0, 0, 0, alphaValue);
      }
      else {
        fill(255, 255, 255, alphaValue);
      }
      text("Record", (20 + (7 * (5 + boxWidth))) / 2, 26);

      //put things back to normal
      textAlign(LEFT);      
      colorMode(RGB, 255); 
    }
  }
  
  if (filmRecord && (movieOutput != null)) {
    //it wouldn't read the screenshot type from the variable - it would only save as png otherwise
    if (frameType.equals("jpg") || frameType.equals("jpeg")) {
      saveFrame(movieOutput + "/########" + ".jpg");
    }
    else if (frameType.equals("png")) {
      saveFrame(movieOutput + "/########" + ".png");
    }
    else if (frameType.equals("tga")) {
      saveFrame(movieOutput + "/########" + ".tga");
    }
    else {
      saveFrame(movieOutput + "/########" + ".tif");
    }  
  }
}

void mouseClicked() {
  //only select a stop in the right circumstances
  if (drawControlPanel.value) {
    if (controls.colourPicker == null) {
      controls.update(false);
    }
    else {
      controls.colourPicker.updatePopup(false);
    }
  }
  else {
    //clicked on the buttons at the top
    if (mouseY > 40) {
      if (!drawPanel.value || selectedStop == null || mouseY < (height - 100)) {
        chooseStop = true;
        chosenStop = false;
      }
    }
    else {
      if ((mouseY <= 30) && (mouseY >= 10)) {
        int boxWidth = int((width - 40.0) / 4); 
        //buttons at the buttom of the screen
        if ((mouseX >= 10) && (mouseX <= 10 + boxWidth)) {
          //launch control panel
          controls.colourPicker = null;
          drawControlPanel.value = true;
        }
        
        if ((mouseX >= 15 + boxWidth) && (mouseX <= 15 + (2 * boxWidth))) {
          //save config
          selectOutput("Choose where to save your configuration file:", "saveConfig"); 
        } 
        
        if ((mouseX >= 20 + (2 * boxWidth)) && (mouseX <= 20 + (3 * boxWidth))) {
          //screenshots -> pick where to save and then save them there
          if (screenshotOutput == null) {
            selectedScreenshot = false;
            selectFolder("Choose where to save screenshots:", "screenshotChooser");
            while (!selectedScreenshot) {
              print("");
            }
          }
          saveScreenshot();
        }
        
        if ((mouseX >= 25 + (3 * boxWidth)) && (mouseX <= 25 + (4 * boxWidth))) {
          //record film frames
          filmRecord = !filmRecord;
          if (filmRecord) {
            selectFolder("Choose where to save movie frames:", "movieChooser");
            selectedFrames = false;
            while(!selectedFrames) {
              print("");
            }
          }
          else {
            println("Stopping recording at frame " + frameCount + " and saving in " + movieOutput);
          }
        }
      }
    }
  }
}

void mouseDragged() {
  if (justResized) {
    justResized = false;
  }
  else {
    if (drawControlPanel.value) {
      if (controls.colourPicker == null) {
        controls.update(true);
      }
      else {
        controls.colourPicker.updatePopup(true);
      }
    }
    else {
      if (mouseY > 40) {
        if (!drawPanel.value || selectedStop == null || mouseY < (height - 100)) {
          //move the map around
          centreOS.x -= (mouseX - pmouseX) / zoomFactor.value;
          centreOS.y -= (mouseY - pmouseY) / zoomFactor.value;
          busStops.updateScreen();
          stopPairs.updateScreen();
        }
      }
    }
  }
}

void keyPressed() {
  if (key == '-') { //zoom out
    zoomFactor.value /= 1.03;
    busStops.updateScreen();
    stopPairs.updateScreen();
  }
  if (key == '=') { //zoom in
    zoomFactor.value *= 1.03;
    busStops.updateScreen();
    stopPairs.updateScreen();
  }
  
  if (key == ' ') { //space = reset
    zoomFactor.reset();
    centreOS.x = defaultCentreOS.x;
    centreOS.y = defaultCentreOS.y;
    selectedStop = null;
    drawStops.reset();
    drawLabels.reset();
    drawRoutes.reset();
    drawPanel.reset();
    scaleRouteOpacity.reset();
    scaleRouteWeight.reset();
    backgroundColour.reset();
    stopColour.reset();
    routeColour.reset();
    for (int i = 0; i < routeColours.size(); i++) {
      routeColours.get(i).reset();
    }
    busStops.updateScreen();
    stopPairs.updateScreen();
  }
  
  if (key == 'z') {
    drawControlPanel.value = !drawControlPanel.value;
    controls.colourPicker = null;
  }
  
  if (key == 'x') {
    //save configuration
    selectOutput("Choose where to save your configuration file:", "saveConfig");
  }
  
  if (key == 'c') {
    //screenshots -> pick where to save and then save them there
    if (screenshotOutput == null) {
      selectedScreenshot = false;
      selectFolder("Choose where to save screenshots:", "screenshotChooser");
      while (!selectedScreenshot) {
        print("");
      }
    }
    saveScreenshot();
  }
  
  if (key == 'v') {
    filmRecord = !filmRecord;
    if (filmRecord) {
      selectFolder("Choose where to save movie frames:", "movieChooser");
      selectedFrames = false;
      while(!selectedFrames) {
        print("");
      }
    }
    else {
      println("Stopping recording at frame " + frameCount + " and saving in " + movieOutput);
    }
  }
}
