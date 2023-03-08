//wrapper for global controllable booleans so we can control with a control panel
class booleanHolder {
  boolean value;
  boolean defaultValue;
 
  booleanHolder(boolean v) {
    value = v;
    defaultValue = v;
  }
  
  booleanHolder(boolean v, boolean d) {
    value = v;
    defaultValue = d;
  }
  
  void reset() {
    value = defaultValue;
  }
}

//wrapper for global controllable ints so we can control with a control panel
class intHolder {
  int value;
  int defaultValue;
  int max;
  int min;
  
  intHolder(int v) {
    value = v;
    defaultValue = v;
    min = int(0.5 * v);
    max = int(1.5 * v);
  }
  
  intHolder(int v, int d) {
    value = v;
    defaultValue = d;
    min = int(0.5 * v);
    max = int(1.5 * v);
  }
  
  intHolder(int v, int mN, int mX, int d) {
    value = v;
    min = mN;
    max = mX;
    defaultValue = d;
  }
  
  intHolder(int v, int mN, int mX) {
    value = v;
    min = mN;
    max = mX;
  }
  
  void reset() {
    value = defaultValue;
  }
}

//wrapper for global controllable floats so we can control with a control panel
class floatHolder {
  float value;
  float defaultValue;
  float min;
  float max;
  
  floatHolder(float v) {
    value = v;
    defaultValue = v;
    min = 0.5 * v;
    max = 1.5 * v;
  }
  
  floatHolder(float v, float d) {
    value = v;
    defaultValue = d;
    min = 0.5 * v;
    max = 1.5 * v;
  }
  
  floatHolder(float v, float mN, float mX, float d) {
    value = v;
    min = mN;
    max = mX;
    defaultValue = d;
  }
  
  floatHolder(float v, float mN, float mX) {
    value = v;
    min = mN;
    max = mX;
    defaultValue = v;
  }
  
  void reset() {
    value = defaultValue;
  }
}

//wrapper for global controllable floats so we can control with a control panel
class colourHolder {
  color value;
  color defaultValue;
  
  colourHolder(color v) {
    value = v;
    defaultValue = v;
  }
  
  colourHolder(color v, color d) {
    value = v;
    defaultValue = d;
  }
  
  void reset() {
    value = defaultValue;
  }
  
  color nonAlpha() {
    float r = red(value);
    float g = green(value);
    float b = blue(value);
    
    return color(r, g, b);
  }
}
