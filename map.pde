//map from OS Grid references to screen coordinates
PVector screenCoordinates(float easting, float northing) {
  PVector screenLocation = new PVector();
  //i checked this. now just use it.
  screenLocation.x = (width / 2f) + ((easting - centreOS.x) * zoomFactor.value);
  screenLocation.y = (height / 2f) + (((999999 - northing) - centreOS.y) * zoomFactor.value);
  return screenLocation;
}

//test if a location is on screen
boolean isOnScreen(PVector screenLocation) {
  if ((screenLocation.x < 0) || (screenLocation.x > width) || (screenLocation.y < 0) || (screenLocation.y > height)) {
    return false;
  }
  if (drawPanel.value && (selectedStop != null)) {
    if (screenLocation.y > height - 100) {
      return false;
    }
  }
  return true;
}

//for drawing lines - is the line on screen? ie. is 
boolean isOnScreen(PVector location1, PVector location2) {
  if ((location1.x > 0) && (location1.x < width) && (location2.x > 0) && (location2.x < width)) {
    //if both are above/below the screen in the same direction, it's not on screen. otherwise, it cuts across or is in the middle
    if (((location1.y < 0) && (location2.y < 0)) || ((location1.y > height) && (location2.y > height))) {
      return false;
    }
    else {
      return true;
    }
  }
  if ((location1.y > 0) && (location1.y < height) && (location2.y > 0) && (location2.y < height)) {
    //if both are left or right of the screen in the same direction, it's not on screen. otherwise, it cuts across or is in the middle
    if (((location1.x < 0) && (location2.x < 0)) || ((location1.x > width) && (location2.x > width))) {
      return false;
    }
    else {
      return true;
    }
  }
  return false;
}
