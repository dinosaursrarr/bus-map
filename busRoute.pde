class busRoute {
  String routeNumber; //some are non-numeric, eg. D6
  ArrayList<busStop> outwardLeg;
  ArrayList<busStop> returnLeg;
  
  busRoute(String rN) {
    routeNumber = rN;
    outwardLeg = new ArrayList<busStop>();
    returnLeg = new ArrayList<busStop>();
  }
}

class busRouteList {
  private ArrayList<busRoute> routes;
  
  //load the data file into routes
  busRouteList(String filePath) {
    //load the data file
    String[] routeFile = loadStrings(filePath);
    println("Loaded bus routes by " + millis() + " milliseconds");
    
    //create new container
    routes = new ArrayList<busRoute>();
    
    //go through data line by line
    for (int i = 1; i < routeFile.length; i++) {
      String[] routeData = split(routeFile[i], ",");
      
      //only bother if it's a valid line
      if (routeData.length > 5) {
        String routeNumber = trim(routeData[0]);
        
        boolean outwardLeg = true;
        if ((int(trim(routeData[1])) % 2) == 0) {
          outwardLeg = false;
        }
        
        //get the stop and check it's real
        String stopLBSL = trim(routeData[3]);
        busStop thisStop = busStops.get(stopLBSL);
        if (thisStop != null) {
          //add it to the route!
          busRoute thisRoute = this.get(routeNumber);
          
          //add a new bus route if it doesn't already exist
          if (thisRoute == null) {
            thisRoute = new busRoute(routeNumber);
            routes.add(thisRoute);
          }
          
          ArrayList<busStop> thisLeg;
          int legNumber;
          //work out which leg it's for
          if (outwardLeg) {
            thisLeg = thisRoute.outwardLeg;
            legNumber = 1;
          }
          else {
            thisLeg = thisRoute.returnLeg;
            legNumber = 2;
          }
          
          //add the stop to this route of the leg
          thisLeg.add(thisStop);
          
          //add route/leg to the stop
          stopRoute thisStopRoute = thisStop.getStopRoute(routeNumber);
          if (thisStopRoute == null) {
            //make a new one
            thisStopRoute = new stopRoute(thisRoute, outwardLeg, !outwardLeg);
            thisStop.routes.add(thisStopRoute);
          }
          else {
            //it's already there, just flag that they stop both ways
            thisStopRoute.outwardLeg = true;
            thisStopRoute.returnLeg = true;
          }
        }
      }
    }
    println("Processed bus routes by " + millis() + " milliseconds");
  }
  
  int size() {
    return routes.size();
  }
  
  //how many stops on a route?
  int totalStops() {
    int count = 0;
    for (int i = 0; i < routes.size(); i++) {
      busRoute thisRoute = (busRoute)routes.get(i);
      count += thisRoute.outwardLeg.size();
      count += thisRoute.returnLeg.size();
    }
    return count;
  }
  
  //lookup by number
  busRoute get(String routeNumber) {
    for (int i = 0; i < routes.size(); i++) {
      busRoute thisRoute = (busRoute)routes.get(i);
      if (thisRoute.routeNumber.equals(routeNumber)) {
        return thisRoute;
      }
    }
    return null;
  }
  
  //
  ArrayList<busStop> getStops(String routeNumber, boolean outward) {
    for (int i = 0; i < routes.size(); i++) {
      busRoute thisRoute = (busRoute)routes.get(i);
      if (thisRoute.routeNumber.equals(routeNumber)) {
        if (outward) {
          return thisRoute.outwardLeg;
        }
        else {
          return thisRoute.returnLeg;
        }
      }
    }
    return null;
  }
  
  //this is the time-consuming bit -> looking up to see if this pair already exists
  void makePairs() {
    for (int i = 0; i < routes.size(); i++) {
      busRoute thisRoute = (busRoute)routes.get(i);
      for (int j = 0; j < thisRoute.outwardLeg.size() - 1; j++) {
        busStop firstStop = (busStop)thisRoute.outwardLeg.get(j);
        busStop secondStop = (busStop)thisRoute.outwardLeg.get(j + 1);
        
        stopPair thisPair = stopPairs.getLocation(firstStop.easting, firstStop.northing, secondStop.easting, secondStop.northing);
        if (thisPair == null) {
          thisPair = new stopPair(firstStop, secondStop);
          stopPairs.add(thisPair);
        }
        else {
          thisPair.busCount++;
          if (thisPair.busCount > stopPairs.busiest) {
            stopPairs.busiest = thisPair.busCount;
          }
        }
      }
      for (int j = 0; j < thisRoute.returnLeg.size() - 1; j++) {
        busStop firstStop = (busStop)thisRoute.returnLeg.get(j);
        busStop secondStop = (busStop)thisRoute.returnLeg.get(j + 1);
        
        stopPair thisPair = stopPairs.getLocation(firstStop.easting, firstStop.northing, secondStop.easting, secondStop.northing);
        if (thisPair == null) {
          thisPair = new stopPair(firstStop, secondStop);
          stopPairs.add(thisPair);
        }
        else {
          thisPair.busCount++;
          if (thisPair.busCount > stopPairs.busiest) {
            stopPairs.busiest = thisPair.busCount;
          }
        }
      }
    }
    stopPairs.updateScales();
    stopPairs.updateScreen();
    println("Made bus stop pairs by " + millis() + " milliseconds");
  }
}

class stopRoute implements Comparable {
  busRoute route;
  boolean outwardLeg = false;
  boolean returnLeg = false;
  
  stopRoute(busRoute r, boolean out, boolean rtn) {
    route = r;
    if (out) {
      outwardLeg = true;
    }
    if (rtn) {
      returnLeg = true;
    }
  }
  
  int compareTo(Object s) {
    stopRoute sR = (stopRoute)s;
    
    String route1 = this.route.routeNumber;
    int iRoute1 = int(route1);
    String route2 = sR.route.routeNumber;
    int iRoute2 = int(route2);
    
    //case 1: a is non-numeric, b is numeric -> b comes first
    if ((iRoute1 == 0) && (iRoute2 != 0)) {
      return 1;
    }
    //case 2: a is numeric, b is non-numeric -> a comes first
    if ((iRoute1 != 0) && (iRoute2 == 0)) {
      return -1;
    }
    //case 3: both are numeric -> lowered number comes first
    if ((iRoute1 != 0) && (iRoute2 != 0)) {
      return iRoute1 - iRoute2;
    }
    //case 4: neither is numeric -> sort as strings
    return route1.compareTo(route2);
  }
}
