// Daniel Shiffman
// http://codingtra.in
// http://patreon.com/codingtrain
// Code for: https://youtu.be/ce-2l2wRqO8

// Blob class
class Blob {
  float minx;
  float miny;
  float maxx;
  float maxy;

  Blob(float x, float y) {
    minx = x;
    miny = y;
    maxx = x;
    maxy = y;
  }

  void show() {
    stroke(100,100,100);
    strokeWeight(4);
    rectMode(CORNERS);
    ellipse(minx+(maxx-minx)/2, miny+(maxy-miny)/2, maxx-minx, maxy-miny);
  }

  void add(float x, float y) {
    minx = min(minx, x);
    miny = min(miny, y);
    maxx = max(maxx, x);
    maxy = max(maxy, y);
  }
  
  float size() {
    return (maxx-minx)*(maxy-miny); 
  }

  boolean isNear(float x, float y) {
    float cx = (minx + maxx) / 2;
    float cy = (miny + maxy) / 2;

    float d = distSq(cx, cy, x, y);
    if (d < distThreshold*distThreshold) {
      return true;
    } else {
      return false;
    }
  }
}
