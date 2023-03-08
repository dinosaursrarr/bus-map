//force directed label for each station
class stopLabel {
  String tooltip; //text it contains
  float tooltipWidth; //how wide is the text?
  busStop stop; //which stop is it for?
  PVector screen; //where is the centre of it on the screen?
  PVector velocity; //how fast is it moving
  int creationTime; //when was it added to the map?
  PVector topLeft; //where does the box start??
  
  stopLabel(busStop thisStop) {
    tooltip = thisStop.name;
    tooltipWidth = textWidth(tooltip);
    stop = thisStop;
    //make space for logos if we're having them
    if (stop.tube) {
      tooltipWidth += 18;
    }
    if (stop.train) {
      tooltipWidth += 18;
    }
    if (stop.dlr) {
      tooltipWidth += 18;
    }
    if (stop.tram) {
      tooltipWidth += 18;
    }
    if (stop.river) {
      tooltipWidth += 18;
    }
    if (stop.tube || stop.train || stop.dlr || stop.tram || stop.river) {
      tooltipWidth -= 1;
    }
    creationTime = millis();
    velocity = new PVector();
    
    //put it a certain distance in the direction of the mouse
    float angle = random(0, 2*PI);
    PVector direction = new PVector(50 * sin(angle), 50 * cos(angle));
    screen = PVector.add(stop.screen, direction);
    topLeft = new PVector(screen.x - (tooltipWidth / 2) - 4, screen.y - 12);
    
    stopLabels.add(this);
  }
  
  //repel itself from other locations
  void repel(PVector otherLocation) {
    float d = PVector.dist(screen, otherLocation); //distance to the other one
    float radius = tooltipWidth; //limit on how far the force reaches
    float strength = -1; //tweakable
    float ramp = 0.4; //tweakable
    if (d > 0 && d < radius) { //if in range
      float s = pow(d / radius, 1 / ramp); //no idea how this works -> got it from the Generative Design book
      float f = s * 9 * strength * (1 / (s + 1) + ((s - 3) / 4)) / d;
      PVector df = PVector.sub(screen, otherLocation);
      df.mult(f);
      
      velocity.x -= df.x;
      velocity.y -= df.y;
    }
  }
  
  //is this label overlapping/overlapped by another one?
  boolean overlapping(stopLabel otherLabel) {
    float longestWidth = max(tooltipWidth, otherLabel.tooltipWidth);
      if (abs(topLeft.x - otherLabel.topLeft.x) < (longestWidth + 8)) {
        if (abs(topLeft.y - otherLabel.topLeft.y) < 17) {
          return true; //yes, if top left corners of each are too close
        }
      }
    return false;
  }
  
  //make it force-directed - this is the magic
  void update() {
    //remove if it's too old
    int timeNow = millis();
    if ((timeNow - creationTime) > 1000) {
      stop.label = null;
      stopLabels.remove(this);
    }
    
    //repel all other nodes
    boolean foundOverlap = false;
    for (int i = 0; i < stopLabels.size(); i++) {
      stopLabel otherLabel = stopLabels.get(i);
      if (otherLabel == null) { //can't repel a blank label
        break;
      }
      if (otherLabel == this) { //can't repel yourself
        continue;
      }
      repel(otherLabel.screen); //repel other labels in range
      repel(stop.screen); //also repel the station -> stretches the label line so it's not blocking the other lines
      
      if (!foundOverlap) { //keep checking if you're overlapping someone until you are, or you run out of ones to check
        if (overlapping(otherLabel)) {
          foundOverlap = true;
        }
      }
    }
    
    //if it's not overlapping anyone, then you can just stop moving around
    if (!foundOverlap) {
      if (PVector.dist(getNearestCorner(), stop.screen) > 35) { //so long as the nearest corner is far enough from the station -> wasn't accurate enough when working off the centre point
        velocity = new PVector(0, 0); //STOP!
      }
    }
    
    screen.add(velocity); //get new location!
    
    //stay in the limits of the window
    if ((screen.x - (tooltipWidth / 2) - 4) < 0) {
      screen.x = (tooltipWidth / 2) + 5;
      velocity.x *= -0.5; //bounce off the walls
    }
    if ((screen.x + (tooltipWidth / 2) + 4) > width) {
      screen.x = width - (tooltipWidth / 2) - 5;
      velocity.x *= -0.5;
    }
    if ((screen.y - 12) < 0) {
      screen.y = 13;
      velocity.y *= -0.5;
    }
    int bottomLimit = height;
    if (drawPanel.value && (selectedStop != null)) {
      bottomLimit = height - 100;
    }
    
    if ((screen.y + 12) > bottomLimit) {
      screen.y = bottomLimit - 13;
      velocity.y *= -0.5;
    }
    topLeft = new PVector(screen.x - (tooltipWidth / 2) - 4, screen.y - 12); //update top left position
  }
  
  //get the location of the corner of the label box nearest to the station itself 
  PVector getNearestCorner() {
    PVector nearestCorner = new PVector();
    float lowestDistance = 999999;
    float width = tooltipWidth + 8;
    float height = 17;
    //these are the possibilities!
    PVector[] corners = {new PVector(topLeft.x, topLeft.y), new PVector(topLeft.x + width, topLeft.y), new PVector(topLeft.x, topLeft.y + height), new PVector(topLeft.x + width, topLeft.y + height)};
    //test each for length, return the the lowest one
    for (int i = 0; i < corners.length; i++) {
      float distance = PVector.dist(corners[i], stop.screen);
      if (distance < lowestDistance) {
        lowestDistance = distance;
        nearestCorner = corners[i];
      }
    } 
    return nearestCorner;
  }
}

class stopLabelList {
  private ArrayList<stopLabel> labels;
  
  stopLabelList(int capacity) {
    labels = new ArrayList<stopLabel>();
  }
  
  stopLabelList() {
    labels = new ArrayList<stopLabel>();
  }
  
  //have to pass on some of the arraylist methods to the array list
  void add(stopLabel label) {
    labels.add(label);
  }
  
  stopLabel find(String name) {
    for (int i = 0; i < labels.size(); i++) {
      stopLabel thisLabel = (stopLabel)labels.get(i);
      if (thisLabel.tooltip.equals(name)) {
        return thisLabel;
      }
    }
    return null;
  }
  
  void remove(stopLabel label) {
    labels.remove(label);
  }
  
  int size() {
    return labels.size();
  }
  
  stopLabel get(int i) {
    return (stopLabel)labels.get(i);
  }
  
  //now some of the interesting methods
  void draw() {
    //draw the lines to the labels first, so they're at the back
    textAlign(LEFT);
    strokeWeight(labelWeight.value);
    stroke(255);
    fill(255);
    for (int i = 0; i < labels.size(); i++) {
      stopLabel thisLabel = (stopLabel)labels.get(i);
      line(thisLabel.screen.x, thisLabel.screen.y, thisLabel.stop.screen.x, thisLabel.stop.screen.y);
    }
    //draw the labels themselves
    for (int i = 0; i < labels.size(); i++) {
      stopLabel thisLabel = (stopLabel)labels.get(i);
      fill(0);
      stroke(255);
      rect(thisLabel.screen.x - (thisLabel.tooltipWidth / 2) - 4, thisLabel.screen.y - 12, thisLabel.tooltipWidth + 8, 17);
      fill(255);
      text(thisLabel.tooltip, thisLabel.screen.x - (thisLabel.tooltipWidth / 2.0), thisLabel.screen.y);
      
      //draw the logos
      float logoStart = textWidth(thisLabel.tooltip) + thisLabel.screen.x - (thisLabel.tooltipWidth / 2.0) + 3;
      noStroke();
      if (thisLabel.stop.tube) {
        fill(255);
        rect(logoStart - 1, thisLabel.screen.y - 11, 18, 15);
        shape(tubeLogo, logoStart, thisLabel.screen.y - 10, 16, 12);
        logoStart += 18;
      }
      if (thisLabel.stop.train) {
        fill(255);
        rect(logoStart - 1, thisLabel.screen.y - 11, 18, 15);
        shape(trainLogo, logoStart, thisLabel.screen.y - 10, 16, 12);
        logoStart += 18;
      }
      if (thisLabel.stop.dlr) {
        fill(255);
        rect(logoStart - 1, thisLabel.screen.y - 11, 18, 15);
        shape(dlrLogo, logoStart, thisLabel.screen.y - 10, 16, 12);
        logoStart += 18;
      }
      if (thisLabel.stop.tram) {
        fill(255);
        rect(logoStart - 1, thisLabel.screen.y - 11, 18, 15);
        shape(tramLogo, logoStart, thisLabel.screen.y - 10, 16, 12);
        logoStart += 18;
      }
      if (thisLabel.stop.river) {
        fill(255);
        rect(logoStart - 1, thisLabel.screen.y - 11, 18, 15);
        shape(riverLogo, logoStart, thisLabel.screen.y - 10, 16, 12);
        logoStart += 18;
      }
      
      thisLabel.update();
    }
  }
}

String titleCase(String input) {
  input = input.toLowerCase().replace("\"", "");
  char[] charArray = input.toCharArray();
  for (int i = 0; i < charArray.length - 1; i++) {
    charArray[0] = str(charArray[0]).toUpperCase().charAt(0);
    if ((charArray[i] == ' ') || (charArray[i] == '(') || (charArray[i] == '-')) { //it's a space!
      charArray[i + 1] = str(charArray[i + 1]).toUpperCase().charAt(0);
    }
  }
  
  return new String(charArray);
}
