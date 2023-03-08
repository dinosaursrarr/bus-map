class stopPair {
  busStop firstStop;
  busStop secondStop;
  int busCount;
  float opacity;
  float weight; 
//  busRoute route; //link back to the route you're on
  boolean onScreen;
  
  stopPair(busStop s1, busStop s2) {
    //further west comes first
    if (s1.easting < s2.easting) {
      firstStop = s1;
      secondStop = s2;
    }
    else {
      firstStop = s2;
      secondStop = s1;
    }
    //if neither is further west, further south wins
    if (s1.easting == s2.easting) {
      if (s1.northing <= s2.northing) {
        firstStop = s1;
        secondStop = s2;
      }
      else {
        firstStop = s2;
        secondStop = s1;
      }
    }
    busCount = 1;
  }
  
  //will equal true if it's the same memory location. but it should be!
  boolean equals(stopPair otherPair) {
    if (((firstStop == otherPair.firstStop) && (secondStop == otherPair.secondStop)) || ((firstStop == otherPair.secondStop) && (secondStop == otherPair.firstStop))) {
      return true;
    }
    return false;
  }
}

class stopPairList {
  private ArrayList<stopPair> pairs;
  int busiest;
  
  stopPairList() {
    pairs = new ArrayList<stopPair>();
    busiest = 1;
  }
  
  void add(stopPair p) {
    pairs.add(p);
  }
  
  int size() {
    return pairs.size();
  }
  
  stopPair getCode(int code1, int code2) {
    int s1 = min(code1, code2); //always stored a certain way round
    int s2 = max(code1, code2);
    
    for (int i = 0; i < pairs.size(); i++) {
      stopPair thisPair = (stopPair)pairs.get(i);
      if ((thisPair.firstStop.code == s1) && (thisPair.secondStop.code == s2)) {
        return thisPair;
      }
    }
    return null;
  }
  
  stopPair getLBSL(String code1, String code2) {
    String s1;
    String s2;
    
    //store it with the lower code first
    if (code1.compareTo(code2) <= 0) {
      s1 = code1;
      s2 = code2;
    }
    else {
      s1 = code2;
      s2 = code1;
    }
    
    for (int i = 0; i < pairs.size(); i++) {
      stopPair thisPair = (stopPair)pairs.get(i);
      if ((thisPair.firstStop.lbsl.equals(s1)) && (thisPair.secondStop.lbsl.equals(s2))) {
        return thisPair;
      }
    }
    return null;
  }

  //identify if it's a matching pair by location -> stored with western first (and southern first in a tie-break)
  stopPair getLocation(int easting1, int northing1, int easting2, int northing2) {
    int western = min(easting1, easting2);
    int eastern = max(easting1, easting2);
    int southern = min(northing1, northing2);
    int northern = max(northing1, northing2);
    
    for (int i = 0; i < pairs.size(); i++) {
      stopPair thisPair = (stopPair)pairs.get(i);
      if (western == eastern) {
        if ((thisPair.firstStop.northing == southern) && (thisPair.secondStop.northing == northern)) {
          return thisPair;
        }
      }
      else {
        //easting1 and northing1 are the first stop
        if (western == easting1) {
          if ((thisPair.firstStop.northing == northing1) && (thisPair.secondStop.northing == northing2)) {
            return thisPair;
          }
        }
        else {
          if ((thisPair.firstStop.northing == northing2) && (thisPair.secondStop.northing == northing1)) {
            return thisPair;
          }
        }
      }
    }
    return null;
  }
 
  void updateScales() {
    for (int i = 0; i < pairs.size(); i++) {
      stopPair thisPair = (stopPair)pairs.get(i);
      thisPair.opacity = map(thisPair.busCount, 0, busiest, minRouteOpacity.value, maxRouteOpacity.value);
      thisPair.weight = map(thisPair.busCount, 0, busiest, minRouteWeight.value, maxRouteWeight.value);
    }
  }
  
 void updateScreen() {
   for (int i = 0; i < pairs.size(); i++) {
     stopPair thisPair = (stopPair)pairs.get(i);
     thisPair.onScreen = isOnScreen(thisPair.firstStop.screen, thisPair.secondStop.screen);
   }
 }
 
// void savePairs(String filePath) {
//   String[] pairsInfo = new String[pairs.size()];
//   for (int i = 0; i < pairs.size(); i++) {
//     stopPair thisPair = (stopPair)pairs.get(i);
//     String[] thisInfo = new String[x];
//     thisInfo[0] = thisPair.firstStop.easting + "/" + thisPair.firstStop.northing;
//     thisInfo[1] = thisPair.secondStop.easting + "/" + thisPair.secondStop.northing;
//     thisInfo[2] = thisPair.busCount;
//     for (int j = 0; j < thisPair.
//   }
// }
 
 void draw() {
   noFill();
   strokeCap(ROUND);
   if (!scaleRouteWeight.value) {
     strokeWeight(1);
   }
   if (!scaleRouteOpacity.value) {
     stroke(routeColour.value);
   }
   for (int i = 0; i < pairs.size(); i++) {
     stopPair thisPair = (stopPair)pairs.get(i);
     if (thisPair.onScreen) {
       if (scaleRouteOpacity.value) {
         stroke(red(routeColour.value), green(routeColour.value), blue(routeColour.value), thisPair.opacity);
       }
       if (scaleRouteWeight.value) {
         strokeWeight(thisPair.weight);
       }
       line(thisPair.firstStop.screen.x, thisPair.firstStop.screen.y, thisPair.secondStop.screen.x, thisPair.secondStop.screen.y); 
     }
   }
 } 
}

class stopPairRoute {
  stopPair pair;
  ArrayList<busRoute> routes;
  
  stopPairRoute(stopPair p, busRoute r) {
    pair = p;
    routes = new ArrayList<busRoute>();
    routes.add(r);
  }
}
