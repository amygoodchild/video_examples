/*
/
/ Video examples
/ Also includes Fadecandy code so these can all be seen on LEDs. 
/ Collated by Amy Goodchild
/ Several examples by Daniel Shiffman
/
*/

// Import the video library.
import processing.video.*;

//Declare a capture object.
Capture video;

// Read from the camera when a new image is available
void captureEvent(Capture video) {
  video.read();
}

// Fadecandy server
OPC opc;

// updates the amount of rotation for the rotating function
float rotation;

// For the squiggle function
float x;
float y;

// For the blob tracking function
color trackColor; 
float threshold = 30;
float distThreshold = 75;
ArrayList<Blob> blobs = new ArrayList<Blob>();

void setup() { 
  // Sets the size of the canvas
  size(640, 480);
  
  // Sets the color mode. Most of these use HSB (hue, saturation, brightness)
  // But the blob tracking one uses RGB (red, green, blue)
  colorMode(RGB,100);
  
  // Start the background as black
  background(0);
  
  // Start x and y in the center for the squiggle function 
  x = width/2;  
  y = height/2;
  
  // Default color to track in blob tracking
  trackColor = color(100, 0, 0);
  
  // Connect to the fadecandy server
  opc = new OPC(this, "127.0.0.1", 7890);
  
  // Set this to false if you don't want to see the dots
  opc.showLocations(true);
   
  // Maps the LED strip across the canvas
  // opc.ledStrip(index, number of leds in strip, x location, y location, spacing, angle, direction)
  opc.ledStrip(0, 15, width/2, 50, 40, 0, false);
  opc.ledStrip(64, 15, width/2, 100, 40, 0, false);
  opc.ledStrip(64*2, 15, width/2, 150, 40, 0, false);
  opc.ledStrip(64*3, 15, width/2, 200, 40, 0, false);
  opc.ledStrip(64*4, 15, width/2, 250, 40, 0, false);
  opc.ledStrip(64*5, 15, width/2, 300, 40, 0, false);
  opc.ledStrip(64*6, 15, width/2, 350, 40, 0, false); 
  opc.ledStrip(64*7, 15, width/2, 400, 40, 0, false);
  // Leave this whole section alone for now
  
  
  // Prints a list of the available cameras
  String[] cameras = Capture.list();
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println(i + " " + cameras[i]);
    }
  } 
  
  // Initialize Video Capture object.
  video = new Capture(this, 640, 480);
  
  // Start the capturing process.
  video.start();
  

}

void draw() {  
  // You can uncomment any one of these functions to see different examples. 
  // The full functions are below if you want to look at the code
  
  
  normalVideo();
  //tintVideo();
  //rotateVideo();
  //pickOutColors();
  
  //change colormode to RGB for this one:
  blobTracking();
}

void normalVideo(){
  // Just draws the image as a video. The 0,0 refers to the x,y position of the top left of the video
  image(video,0,0);
}

void tintVideo(){
  // Creates a variable for hue. Sets the hue using the mouse's X position. 
  // Because mouseX can go from 0 to width, while hue only goes from 0 to 100, we use mapping to convert from one to the other
  float hue = map(mouseX, 0, width, 0, 100);
  
  // Creates a variable for saturation. Sets the saturation using the mouse's Y position. 
  // Because mouseY can go from 0 to height, while saturation only goes from 0 to 100, we use mapping to convert from one to the other
  float saturation = map(mouseY, 0, height, 0, 100);
  
  // Tint everything with the selected hue and saturation
  tint(hue, saturation, 100); 
  
  // Draw the video, which will be affected by the tint
  image(video, 0, 0);
}

void rotateVideo(){
  // Adds 0.01 radians to the rotation angle every frame
  rotation+=0.01;
  
  // Move to the middle of the canvas
  translate(width/2, height/2);  
  
  // Rotate by the rotation angle
  rotate(rotation); 
  
  // Creates variables for video width and height, and sets them using the mouse's X position and Y position.
  // I also mapped it so that the minimum width/height is 30 and the maximum is bigger than the actual width, 
  // because it makes it more fun to play with!
  float videoWidth = map(mouseX, 0,width, 30,width+500);
  float videoHeight = map(mouseY, 0,height, 30,height+500);
  
  // Draws the video image at the selected size
  imageMode(CENTER);  
  image(video, 0, 0, videoWidth, videoHeight);
}

void pickOutColors(){
  // Loads the pixels in the current frame into an array
  loadPixels();
  
  // Steps through each pixel one by one
  for (int x = 0; x < video.width; x++) {    
    for (int y = 0; y < video.height; y++) {    
      
      // Calculates number of the pixel, from the x and y location
      int loc = x + y * video.width;      
    
      // Get the hue value of this pixel 
      float hue = hue (video.pixels[loc]);   
      
      // Rounds the hue value for this pixel to the nearest 10
      float basicHue = round(hue/10)*10;
      
      // Sets the opacity of the pixel based on the mouse's x position
      float opacity = map(mouseX, 0, width, 0, 40);
      
      // Changes this pixel to that rounded figure. 
      pixels[loc] = color(basicHue,90,100,opacity);  
    }  
  }  
  
  // This prints the pixels to the frame so we can see them
  updatePixels();
  
}

void blobTracking(){
  
  // Loads the pixels in the video into an array
  video.loadPixels();
  
  // Displays the video
  image(video, 0, 0);

  // Clears the array list of blobs
  blobs.clear();

  // Begin loop to walk through every pixel
  for (int x = 0; x < video.width; x++ ) {
    for (int y = 0; y < video.height; y++ ) {
      
      // Figures out the number of this pixel in the array, based on the x and y position
      int loc = x + y * video.width;
      
      // Gets the r,g,b values of this pixel in the array, and the r,g,b values of the track color
      color currentColor = video.pixels[loc];
      float r1 = red(currentColor);
      float g1 = green(currentColor);
      float b1 = blue(currentColor);
      float r2 = red(trackColor);
      float g2 = green(trackColor);
      float b2 = blue(trackColor);
      
      // Checks how "far apart" (or how different) those r,g,b values are
      float d = distSq(r1, g1, b1, r2, g2, b2); 

      // If the colours are similar...
      if (d < threshold) {
        
        // Checks if this pixel is near another one that we've already found to be similar
        boolean found = false;
        for (Blob b : blobs) {
          if (b.isNear(x, y)) {
            b.add(x, y);
            // if it is near another blob, add this pixel to that blob
            found = true;
            break;
          }
        }
        
        // if it's not near any other blobs, create a new blob
        if (!found) {
          Blob b = new Blob(x, y);
          blobs.add(b);
        }
      }
    }
  }

  // Show all of the blobs
  for (Blob b : blobs) {
    if (b.size() > 500) {
      b.show();
    }
  }
}

// This function figures out the distance between two points in 2D space
float distSq(float x1, float y1, float x2, float y2) {
  float d = (x2-x1)*(x2-x1) + (y2-y1)*(y2-y1);
  return d;
}

// This function figures out the distance between two points in 3D space (like a color)
float distSq(float x1, float y1, float z1, float x2, float y2, float z2) {
  float d = (x2-x1)*(x2-x1) + (y2-y1)*(y2-y1) +(z2-z1)*(z2-z1);
  return d;
}

void mousePressed() {
  // Save color where the mouse is clicked in trackColor variable
  int loc = mouseX + mouseY*video.width;
  trackColor = video.pixels[loc];
  
  println("hue: " + hue(trackColor));
}
