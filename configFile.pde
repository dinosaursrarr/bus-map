void loadConfig(java.io.File configFile) {
  //if possible load a config file from the data folder
  selectedConfig = true;
  String[] dataFile = loadStrings(configFile.getAbsolutePath());
  if (dataFile == null) {
    return;
  }
  
  //go through the lines and parse the config input
  for (int i = 0; i < dataFile.length; i++) {
    if (dataFile[i].length() == 0) {
      continue; //blank line
    }
    if (dataFile[i].charAt(0) == '/') {
      continue; //it's a comment
    }
    
    String[] data = split(dataFile[i], "=");
    if (data.length != 2) {
      continue; //looking for a key, value pair separated by an equals
    }
    String key = trim(data[0]);
    String value = trim(data[1]);
    
    //parse the input! -> get the value then go onto the next line
    if (key.equals("centreEasting")) {
      defaultCentreOS.x = float(value);
      centreOS.x = float(value);
      continue;
    }
    if (key.equals("centreNorthing")) {
      defaultCentreOS.y = float(value);
      centreOS.y = float(value);
      continue;
    }
    if (key.equals("zoomFactor")) {
      if (float(value) > 0) {
        zoomFactor = new floatHolder(float(value), min(float(value), zoomFactor.min), max(float(value), zoomFactor.max));
      }
      continue;
    }
    if (key.equals("drawStops")) {
      drawStops = new booleanHolder(Boolean.valueOf(value));
      continue;
    }
    if (key.equals("drawRoutes")) {
      drawRoutes = new booleanHolder(Boolean.valueOf(value));
      continue;
    }
    if (key.equals("drawPanel")) {
      drawPanel = new booleanHolder(Boolean.valueOf(value));
      continue;
    }
    if (key.equals("drawLabels")) {
      drawLabels = new booleanHolder(Boolean.valueOf(value));
      continue;
    }
    if (key.equals("scaleRouteOpacity")) {
      scaleRouteOpacity = new booleanHolder(Boolean.valueOf(value));
      continue;
    }
    if (key.equals("minRouteOpacity")) {
      minRouteOpacity = new floatHolder(float(value), min(float(value), minRouteOpacity.min), max(float(value), minRouteOpacity.max));
      continue;
    }
    if (key.equals("maxRouteOpacity")) {
      maxRouteOpacity = new floatHolder(float(value), min(float(value), maxRouteOpacity.min), max(float(value), maxRouteOpacity.max));
      continue;
    }
    if (key.equals("scaleRouteWeight")) {
      scaleRouteWeight = new booleanHolder(Boolean.valueOf(value));
      continue;
    }
    if (key.equals("minRouteWeight")) {
      minRouteWeight = new floatHolder(float(value), min(float(value), minRouteWeight.min), max(float(value), minRouteWeight.max));
      continue;
    }
    if (key.equals("maxRouteWeight")) {
      maxRouteWeight = new floatHolder(float(value), min(float(value), maxRouteWeight.min), max(float(value), maxRouteWeight.max));
      continue;
    }
    if (key.equals("backgroundColour")) {
      backgroundColour = new colourHolder(parseColour(value));
      continue;
    }
    if (key.equals("stopColour")) {
      stopColour = new colourHolder(parseColour(value));
      continue;
    }
    if (key.equals("normalRouteColour")) {
      routeColour = new colourHolder(parseColour(value));
      continue;
    }
    if (key.substring(0, key.length() - 1).equals("routeColour")) {
      int colourNumber = int(key.substring(key.length() - 1));
      if ((colourNumber >= 1) && (colourNumber <= 9)) {
        routeColours.set(colourNumber - 1, new colourHolder(parseColour(value)));
      }
      continue;
    }
    if (key.substring(0, key.length() - 2).equals("routeColour")) {
      int colourNumber = int(key.substring(key.length() - 2));
      if ((colourNumber >= 10) && (colourNumber <= 25)) {
        routeColours.set(colourNumber - 1, new colourHolder(parseColour(value)));
      }
    }
    if (key.equals("screenshotType")) {
      String fileType = value.toLowerCase();
      if (fileType.equals("jpg") || fileType.equals("jpeg") || fileType.equals("tif") || fileType.equals("tif") || fileType.equals("tiff") || fileType.equals("png") || fileType.equals("tga")) {
        screenshotType = fileType;
      }
      continue;
    }
    if (key.equals("frameType")) {
      String fileType = value.toLowerCase();
      if (fileType.equals("jpg") || fileType.equals("jpeg") || fileType.equals("tif") || fileType.equals("tif") || fileType.equals("tiff") || fileType.equals("png") || fileType.equals("tga")) {
        frameType = fileType;
      }
      continue;
    }
  }
  println("Config file loaded by " + millis() + " milliseconds");
}
    
color parseColour(String data) {
  String[] components = split(data, ","); //for colours, give an RGB value
  color c;
  
  //it's a grey, an RGB or an RGBA separated by commas 
  if (components.length == 1) {
    c = color(float(components[0]));
    return c;
  }
  if (components.length == 3) {
    c = color(float(components[0]), float(components[1]), float(components[2]));
    return c;
  }
  if (components.length == 4) {
   c = color(float(components[0]), float(components[1]), float(components[2]), float(components[3]));
   return c;
  }
  
  return color(0); //default to black
}

//export current set up
void saveConfig(java.io.File selection) {
  if (selection == null) {
  }
  else {
    String[] variables = new String[42];
    variables[0] = "centreEasting=" + str(centreOS.x);
    variables[1] = "centreNorthing=" + str(centreOS.y);
    variables[2] = "zoomFactor=" + str(zoomFactor.value);
    variables[3] = "drawStops=" + str(drawStops.value);
    variables[4] = "drawRoutes=" + str(drawRoutes.value);
    variables[5] = "drawPanel=" + str(drawPanel.value);
    variables[6] = "drawLabels=" + str(drawLabels.value);
    variables[7] = "scaleRouteOpacity=" + str(scaleRouteOpacity.value);
    variables[8] = "minRouteOpacity=" + str(minRouteOpacity.value);
    variables[9] = "maxRouteOpacity=" + str(maxRouteOpacity.value);
    variables[10] = "scaleRouteWeight=" + str(scaleRouteWeight.value);
    variables[11] = "minRouteWeight=" + str(minRouteWeight.value);
    variables[12] = "maxRouteWeight=" + str(maxRouteWeight.value);
    variables[13] = "screenshotType=" + screenshotType;
    variables[14] = "frameType=" + frameType;
    variables[15] = "backgroundColour=" + writeColour(backgroundColour.value);
    variables[16] = "stopColour=" + writeColour(stopColour.value);
    variables[17] = "normalRouteColour=" + writeColour(routeColour.value);
    for (int i = 0; i < routeColours.size(); i++) {
      variables[18 + i] = "routeColour" + (i + 1) + "=" + writeColour(routeColours.get(i).value);
    }
    
    String configPath = selection.getAbsolutePath();
    if (!configPath.endsWith(".txt")) {
      configPath += ".txt";
    }
    saveStrings(configPath, variables);
    println("Saved config file at " + configPath);
  }
}

String writeColour(color c) {
  int red = int(red(c));
  int green = int(green(c));
  int blue = int(blue(c));
  int alpha = int(alpha(c));
  
  return red + "," + green + "," + blue + "," + alpha;
}
