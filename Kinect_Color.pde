/*
Ian Stewart
with starter code from Daniel Shiffman

Allows you to make drawings of different colors within the frame of the
xbox Kinect camera
*/

// libraries for Kinect and sound
import org.openkinect.freenect.*;
import org.openkinect.freenect2.*;
import org.openkinect.processing.*;
import org.openkinect.tests.*;
import java.util.Random;
import processing.sound.*;


Kinect kinect;

PImage depthImg;
PImage prevImg;

int minDrawDepth = 60;
int maxDrawDepth = 900;

float angle;
color imgColor = color(0);

Random rand = new Random();

SoundFile file;

void setup() {
 size(640, 480);
 
 kinect = new Kinect(this);
 kinect.initDepth();
 angle = kinect.getTilt();
 kinect.enableMirror(true);
 
 depthImg = new PImage(kinect.width, kinect.height);
 prevImg = new PImage(kinect.width, kinect.height);
 
 file = new SoundFile(this, "smash.mp3");
}

void draw() {
 
  depthImg.loadPixels();
  prevImg.loadPixels();
  
  int[] rawDepth = kinect.getRawDepth();
  int count = 0;
  
  // loop through every pixel
  for (int i = 0; i < rawDepth.length-1; i++) {
    
    // if person is within depth range or if the pixel was previously colored
    // color it again so pixels stay colored between draw calls
    if (rawDepth[i] >= minDrawDepth && rawDepth[i] <= maxDrawDepth || 
    prevImg.pixels[i] == color(imgColor)) {
      depthImg.pixels[i] = color(imgColor);
    }
    
    // if person is out of range and there was not previously color make the
    // pixel white
    else {
      depthImg.pixels[i] = color(255);
      count++;
    }
    
  }
  
  // if the amount of color takes up more than half the screen, reset
  if (count < ((kinect.height * kinect.width)/2)) {
    file.play();
    int r = rand.nextInt(254);
    int g = rand.nextInt(254);
    int b = rand.nextInt(254);
    imgColor = color(r, g, b);
  }
    
  // display image  
  image(depthImg, 0, 0);
  
  // roll depth image into previous image
  prevImg = depthImg;
  
  depthImg.updatePixels();
  prevImg.updatePixels();
  
  fill(255);
  text("TILT: " + angle, 10, 20);
  text("THRESHOLD: [" + minDrawDepth + ", " + maxDrawDepth + "]", 10, 36);
  
}

// key commands to adjust camera by Daniel Shiffman
void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      angle++;
    } else if (keyCode == DOWN) {
      angle--;
    }
    angle = constrain(angle, 0, 30);
    kinect.setTilt(angle);
  } else if (key == 'a') {
    minDrawDepth = constrain(minDrawDepth+10, 0, maxDrawDepth);
  } else if (key == 's') {
    minDrawDepth = constrain(minDrawDepth-10, 0, maxDrawDepth);
  } else if (key == 'z') {
    maxDrawDepth = constrain(maxDrawDepth+10, minDrawDepth, 2047);
  } else if (key =='x') {
    maxDrawDepth = constrain(maxDrawDepth-10, minDrawDepth, 2047);
  } else if (key == 'e') {
    
    loadPixels();
    
    for (int x = 0; x < kinect.width; x++) {
      for (int y = 0; y < kinect.height; y++) {
        depthImg.set(x,y,0);
        prevImg.set(x,y,0);
      }
    }
    
    updatePixels();
  }
}

  
