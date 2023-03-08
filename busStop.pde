class busStop {
  String lbsl; //unique ID, key field
  int code; //5 digit for texting the bus tracker
  String name; //what's it called?
  int easting; //OS Grid map
  int northing; //OS Grid map
  int heading; //which direction it faces?
  String stopArea; //from the data, unknown use
  boolean virtual; //is it a virtual bus stop. if yes, remove it!

  PVector screen; //where on the screen to draw it?
  boolean onScreen;
  PVector normal; //what direction is perpendicular to the average line going through this stop? (unit length)
  float scale; //how big to draw it?
  int busCount; //how many routes go here?  
  stopLabel label;
  ArrayList<stopRoute> routes; //which routes stop here? which legs?
  ArrayList<stopPairRoute> routePairs; //which pairs of stops stop here?

  //interchanges
  boolean tube = false;
  boolean train = false;
  boolean dlr = false;
  boolean tram = false;
  boolean river = false;

  busStop(String[] stopData) {
    //process the data from the file
    this.lbsl = trim(stopData[0]);
    this.code = int(trim(stopData[1]));
    int eastingStart = 4;

    //name - get the basic info into one string
    if (stopData[3].charAt(0) != '"') {
      this.name = stopData[3];
    }
    else {
      String nameString = stopData[3];
      while (eastingStart < stopData.length - 5) {
        nameString = nameString + stopData[eastingStart]; 
        eastingStart++;
      }
      this.name = nameString;
    }

    //see if it has connections!
    if (this.name.indexOf("<>") != -1) {
      this.tube = true;
      this.name = this.name.replace("<>", "");
    }
    if (this.name.indexOf("#") != -1) {
      this.train = true;
      this.name = this.name.replace("#", "");
    }
    if (this.name.indexOf("[DLR]") != -1) {
      this.dlr = true;
      this.name = this.name.replace("[DLR]", "");
    }
    if (this.name.indexOf("(DLR)") != -1) {
      this.dlr = true;
      this.name = this.name.replace("(DLR)", "");
    }
    if (this.name.indexOf(">T<") != -1) {
      this.tram = true;
      this.name = this.name.replace(">T<", "");
    }
    if (this.name.indexOf("<T>") != -1) {
      this.tram = true;
      this.name = this.name.replace("<T>", "");
    }
    if (this.name.indexOf(">R<") != -1) {
      this.river = true;
      this.name = this.name.replace(">R<", "");
    }
    if (this.name.indexOf("<R>") != -1) {
      this.river = true;
      this.name = this.name.replace("<R>", "");
    }

    //tidy up the name 
    while (this.name.indexOf ("  ") != -1) { //get rid of double spaces
      this.name = this.name.replace("  ", " ");
    }
    this.name = this.name.replace("\"", ""); //get rid of speech marks
    this.name = titleCase(this.name);

    this.easting = int(trim(stopData[eastingStart]));
    this.northing = int(trim(stopData[eastingStart + 1]));
    this.heading = int(trim(stopData[eastingStart + 2]));
    this.stopArea = trim(stopData[eastingStart + 3]);

    //virtual bus stops are used to give the route waypoints but there's not an actual stop there
    if (trim(stopData[eastingStart + 4]).equals("1")) {
      this.virtual = true;
    }
    else {
      this.virtual = false;
    }

    //work out starting place to draw it
    this.screen = screenCoordinates(easting, northing);
    this.onScreen = isOnScreen(this.screen);

    //container to store routes
    routes = new ArrayList<stopRoute>();
  }

  // adds a pop out label to the list
  void addLabel() {
    if (label == null) { //if it doesn't already have a label, see if there's one with the same name
      stopLabel findLabel = stopLabels.find(this.name);
      if (findLabel == null) { //if not, make one
        new stopLabel(this);
      }
      else { //if yes, make it exist longer
        findLabel.creationTime = millis();
      }
    }
    else { //renewed lease of life for existing label
      label.creationTime = millis();
    }
  }

  //makes life easier for drawing -> compiles together a list of the routes, which is helpful for getting colours
  ArrayList<busRoute> getRoutes() {
    ArrayList<busRoute> routeList = new ArrayList<busRoute>(); 
    for (int i = 0; i < routes.size(); i++) {
      stopRoute thisStopRoute = (stopRoute)routes.get(i);
      routeList.add(thisStopRoute.route);
    }
    return routeList;
  }

  //which combo of leg of this route is this stop on?
  stopRoute getStopRoute(String routeNumber) {
    for (int i = 0; i < routes.size(); i++) {
      stopRoute thisStopRoute = (stopRoute)routes.get(i);
      if (thisStopRoute.route.routeNumber.equals(routeNumber)) {
        return thisStopRoute;
      }
    }
    return null;
  }

  //draw the popup panel with details of the bus stop and its route
  void drawDetails() {
    //set up a bit at the bottom of the screen
    fill(0);
    noStroke();
    rect(0, height - 100, width, 100);
    stroke(255);
    strokeWeight(1);
    line(0, height - 100, width, height - 100);

    //stop name
    fill(255);
    textAlign(LEFT);
    text(this.name, 12, height - 80);

    //symbols for interchanges
    float startX = 12 + textWidth(this.name) + 4;
    float startY = height - 90;
    noStroke();
    if (this.tube) {
      fill(255);
      rect(startX - 1, startY - 1, 18, 14);
      shape(tubeLogo, startX, startY, 16, 12);
      startX += 18;
    }
    if (this.train) {
      fill(255);
      rect(startX - 1, startY - 1, 18, 14);
      shape(trainLogo, startX, startY, 16, 12);
      startX += 18;
    }
    if (this.dlr) {
      fill(255);
      rect(startX - 1, startY - 1, 18, 14);
      shape(dlrLogo, startX, startY, 16, 12);
      startX += 18;
    }
    if (this.river) {
      fill(255);
      rect(startX - 1, startY - 1, 18, 14);
      shape(riverLogo, startX, startY, 16, 12);
      startX += 18;
    }
    if (this.tram) {
      fill(255);
      rect(startX - 1, startY - 1, 18, 14);
      shape(tramLogo, startX, startY, 16, 12);
      startX += 18;
    }

    //show the stop code
    if (this.code > 0) {
      textAlign(RIGHT);
      text(this.code, width - 12, height - 80);
    }

    //boxes for routes -> up to 24 of the buggers
    int widthDiff = 12;
    int heightDiff = 72;
    int boxRow = floor(width - widthDiff) / 48;
    
    for (int i = 0; i < routes.size(); i++) {
      if (i == boxRow) {
        widthDiff = 12;
        heightDiff -= 36;
      }
      //box for the route number
      fill(routeColours.get(i).value);
      noStroke();
      rect(widthDiff, height - heightDiff, 40, 30);

      //route number in the box
      fill(0);
      stopRoute thisStopRoute = (stopRoute)routes.get(i);

      textAlign(CENTER);
      int boxLeft = widthDiff;
      int boxRight = widthDiff + 40;
      text(thisStopRoute.route.routeNumber, (boxLeft + boxRight) / 2.0, height - heightDiff + 20);

      widthDiff += 48;
    }
  }

  //draw the lines stopping at this stop
  void drawRoutes() {
    //safety first - check we have routes and if not, get them
    if (routePairs == null) {
      getRoutePairs();
    }

    //now draw the lines!
    strokeWeight(2); // leaves a gap between lines for clarity!
    ArrayList<busRoute> routeList = getRoutes(); //need a list of the routes in order so we can get the colours right
    for (int i = 0; i < routePairs.size(); i++) {
      stopPairRoute thisPairRoute = (stopPairRoute)routePairs.get(i);
      stopPair thisPair = thisPairRoute.pair;

      for (int j = 0; j < thisPairRoute.routes.size(); j++) {
        //colour each line according to the route
        busRoute thisRoute = (busRoute)thisPairRoute.routes.get(j);
        int colourNumber = routeList.indexOf(thisRoute); 
        stroke(routeColours.get(colourNumber).value);

        //if either stop is on screen, work out the correct offset for this route at each stop, and join them up
        if (thisPair.firstStop.onScreen || thisPair.secondStop.onScreen) {
          PVector firstScreen = routeScreen(thisPair.firstStop, thisRoute);
          PVector secondScreen = routeScreen(thisPair.secondStop, thisRoute);
          line(firstScreen.x, firstScreen.y, secondScreen.x, secondScreen.y);
        }
      }
    }
  }

  //when drawing multiple routes, need to offset them from where we draw the stop itself, so you can see them going in parallel
  PVector routeScreen(busStop thatStop, busRoute thisRoute) {
    ArrayList sharedRoutes = this.commonRoutes(thatStop);
    int routeIndex = sharedRoutes.indexOf(thisRoute);

    PVector stopNormal = thatStop.normal;
    if (stopNormal == null) {
      thatStop.getNormal();
      stopNormal = thatStop.normal;
    }

    float offsetCount = routeIndex - ((sharedRoutes.size() - 1) / 2.0);
    float xOffset = 3 * offsetCount * stopNormal.x;
    float yOffset = 3 * offsetCount * stopNormal.y;

    return new PVector(thatStop.screen.x - xOffset, thatStop.screen.y - yOffset);
  }

  //work out which line is perpendicular to the average line through the stop
  void getNormal() {
    float dx = 0;
    float dy = 0;
    for (int i = 0; i < routes.size(); i++) {
      stopRoute thisStopRoute = (stopRoute)routes.get(i);
      if (thisStopRoute.outwardLeg) {
        PVector legResult = getNormalLeg(thisStopRoute, true);
        dx += legResult.x;
        dy += legResult.y;
      }
      if (thisStopRoute.returnLeg) {
        PVector legResult = getNormalLeg(thisStopRoute, false);
        dx += legResult.x;
        dy += legResult.y;
      }
    }
    normal = new PVector(-dy, dx);
    normal.normalize();
  }

  //use to save duplication in getNormal() - where we have two legs
  PVector getNormalLeg(stopRoute s, boolean outwardLeg) {
    ArrayList<busStop> stopList;
    if (outwardLeg) {
      stopList = s.route.outwardLeg;
    }
    else {
      stopList = s.route.returnLeg;
    }

    float dx = 0;
    float dy = 0;
    for (int j = 0; j < stopList.size(); j++) {
      busStop thatStop = (busStop)stopList.get(j);
      if (thatStop == this) {
        busStop otherStop;
        if (j > 0) {
          otherStop = (busStop)stopList.get(j - 1);
          dx += (thatStop.screen.x - otherStop.screen.x);
          dy += (thatStop.screen.y - otherStop.screen.y);
        }
        if (j < stopList.size() - 1) {
          otherStop = (busStop)stopList.get(j + 1);
          dx += (otherStop.screen.x - thatStop.screen.x);
          dy += (otherStop.screen.y - thatStop.screen.y);
        }
      }
    }

    return new PVector(dx, dy);
  } 

  //work out which pairs of stops are on the routes that stop here
  void getRoutePairs() {
    routePairs = new ArrayList<stopPairRoute>(); //combo of pair + routes

    //for each route
    for (int i = 0; i < routes.size(); i++) {
      stopRoute thisStopRoute = (stopRoute)routes.get(i);
      busRoute thisRoute = thisStopRoute.route;

      //get the right legs!
      if (thisStopRoute.outwardLeg) {
        extractPairs(thisStopRoute.route.outwardLeg, thisRoute);
      }
      if (thisStopRoute.returnLeg) {
        extractPairs(thisStopRoute.route.returnLeg, thisRoute);
      }
    }
  }

  //extract pairs from a particular leg of a journey and add to routePiars
  private void extractPairs(ArrayList<busStop> stops, busRoute thisRoute) {
    //for each stop on the outward leg (except the last one)
    for (int j = 0; j < stops.size() - 1; j++) {
      busStop firstStop = (busStop)stops.get(j);
      busStop secondStop = (busStop)stops.get(j + 1);
      stopPair thisPair = new stopPair(firstStop, secondStop);

      //does it exist already?
      stopPairRoute thisStopPairRoute = null;
      for (int k = 0; k < routePairs.size(); k++) {
        stopPairRoute resultPair = (stopPairRoute)routePairs.get(k);
        if (resultPair.pair.equals(thisPair)) {
          thisStopPairRoute = resultPair;
          break;
        }
      }

      //if it exists, add this route to its routes
      if (thisStopPairRoute != null) {
        //only add it if we don't already have it
        if (!thisStopPairRoute.routes.contains(thisRoute)) {
          thisStopPairRoute.routes.add(thisRoute);
        }
      }
      else {
        thisStopPairRoute = new stopPairRoute(thisPair, thisRoute);
        routePairs.add(thisStopPairRoute);
      }
    }
  }

  //which routes do this stop and that stop have in common?
  ArrayList<busRoute> commonRoutes(busStop thatStop) {
    ArrayList<busRoute> results = new ArrayList<busRoute>();
    for (int i = 0; i < routes.size(); i++) {
      stopRoute thisStopRoute = (stopRoute)routes.get(i);
      busRoute thisRoute = thisStopRoute.route;
      for (int j = 0; j < thatStop.routes.size(); j++) {
        stopRoute thatStopRoute = (stopRoute)thatStop.routes.get(j);
        busRoute thatRoute = thatStopRoute.route;
        if (thisRoute == thatRoute) {
          results.add(thisRoute);
          break;
        }
      }
    }
    return results;
  }
}

//container for bus stops, unsurprisingly
class busStopList {
  private HashMap<String, busStop> stops;
  int busiest; //track which is the busiest station

  //create a list of stops from a data file
  busStopList(String filePath) {
    //load the data file
    String[] stopFile = loadStrings(filePath);
    println("Loaded bus stops by " + millis() + " milliseconds");

    //set up the parameters
    busiest = 0;
    stops = new HashMap<String, busStop>();

    //process the info, line by line
    for (int i = 1; i < stopFile.length; i++) {
      String[] stopData = split(stopFile[i], ',');
      if (stopData.length >= 8) {
        busStop thisStop = new busStop(stopData);
        if ((thisStop.northing != 0) && (thisStop.northing != 999999)) {
          stops.put(thisStop.lbsl, thisStop);
        }
      }
    }
    println("Processed bus stops by " + millis() + " milliseconds");
  }

  //work out where each stop should be on the screen - ie. when zoomed/panned
  void updateScreen() {
    Iterator i = stops.values().iterator();
    while (i.hasNext ()) {
      busStop thisStop = (busStop)i.next();
      if (thisStop != null) {
        thisStop.screen = screenCoordinates(thisStop.easting, thisStop.northing);
        thisStop.onScreen = isOnScreen(thisStop.screen);
      }
    }
  }

  //how many bus stops in the list?
  int size() {
    return stops.size();
  }

  //give us a bus stop from the list
  busStop get(String lsbl) {
    return (busStop)stops.get(lsbl);
  }

  //look up a bus stop by 5 digit bustracker code
  busStop getCode(int code) {
    Iterator i = stops.values().iterator();
    while (i.hasNext ()) {
      busStop thisStop = (busStop)i.next();
      if (thisStop != null) {
        if (thisStop.code == code) {
          return thisStop;
        }
      }
    }
    return null;
  }

  //sort the routes at each stop into order
  void sortRoutes() {
    Iterator i = stops.values().iterator();
    while (i.hasNext ()) {
      busStop thisStop = (busStop)i.next();
      if (thisStop != null) {
        Collections.sort(thisStop.routes);
      }
    }
    println("Sorted bus routes at each stop by " + millis() + " milliseconds");
  }

  //draw a point for each stop
  void draw() {
    noFill();
    if (selectedStop == null) {
      strokeWeight(2);
      stroke(stopColour.value);
    }

    //handle mouse movements
    ArrayList<busStop> selectionCandidates = new ArrayList<busStop>();
    strokeWeight(2);
    stroke(stopColour.value);
    Iterator i = stops.values().iterator();
    while (i.hasNext ()) {
      busStop thisStop = (busStop)i.next();
      if (thisStop != null && !thisStop.virtual && thisStop.onScreen) {
        //normal stops in normal colour
        if (drawStops.value) {
          point(thisStop.screen.x, thisStop.screen.y);
        }
        //if the mouse is near stations, make a force-directed label
        if (!drawControlPanel.value) {
          if ((abs(thisStop.screen.x - mouseX) <= labelMouseRange.value) && (abs(thisStop.screen.y - mouseY) <= labelMouseRange.value)) {
            if (chooseStop) {
              selectionCandidates.add(thisStop); //don't just pick any stop - get the nearest one
            }
            else {
              thisStop.addLabel(); //add/update the label
            }
          }
        }
      }
    }

    //there may be several stops in range, so work out which is the nearest and select that one
    if (chooseStop) {
      float minDistance = 999999;
      PVector mousePos = new PVector(mouseX, mouseY);
      for (int j = 0; j < selectionCandidates.size(); j++) {
        busStop thisStop = (busStop)selectionCandidates.get(j);  
        float thisDistance = thisStop.screen.dist(mousePos);
        if (thisDistance < minDistance) {
          chosenStop = true;
          minDistance = thisDistance;
          selectedStop = thisStop;
        }
      }
      //will need the list of routes for drawing
      if (selectedStop != null) {
        if (selectedStop.routePairs == null) {
          selectedStop.getRoutePairs(); //so we can draw them!
        }
      }
      updateScreen();
    }

    //didn't find anything, so go back to overview mode
    if (chooseStop && !chosenStop) {
      if ((selectedStop != null) && (selectedStop.routePairs != null)) {
        selectedStop.routePairs = null;
      }
      //make sure we never run out of memory
      for (int j = 0; j < stops.size(); j++) {
        busStop thisStop = (busStop)stops.get(j);
        if (thisStop != null) {
          if (thisStop.normal != null) {
            thisStop.normal = null;
          }
        }
      }
      selectedStop = null;
      updateScreen();
    }
    chooseStop = false;
  }
}

