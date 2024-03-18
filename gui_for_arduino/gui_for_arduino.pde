/*
 ******** FILES INCLUDED ********
 1. "r2d2hq.png" image of R2D2 for startup screen
 2. "r2d2bg.png" pixel art r2d2 background for main screen
 3. "c3po.png" pixel art c3po for Obstacle Detected pop-up
 ******** LIBRARIES ADDED ********
 1. "ControlP5.*" adds buttons
 2. "processing.net.*" allows wifi communication
 *********************************
 TODO: CHANGE REFERENCE SPEED TO M/S
 rgb for r2d2 blue (4,84,168) */

import controlP5.*;  // gives button control
import processing.net.*; // allows wifi communication

Client myClient; // GUI is client, Arduino is server
ControlP5 cp5;

PFont font;
PImage startupImg; // r2d2 image for startup screen
PImage mainImg; // r2d2 image for main screen
PImage c3poImg; // c3po pops up during obstacle detection
char dataC;// read in from Server (Arduino)
char dataB = 'z';  // filters out dataC for relevant chars
int port = 5200;
int currentTime; // counter for refreshing screen
int itCount = 0; // iteration counter for draw loop
int r=255;
int g=255;
int b=255;
int w = 800; // window width
int h = 576; // window height
int objDistance = 0;
float travDistance = 0.0;
float referenceSpeed = 0.0;
float prevReferenceSpeed = 0.0;
float buggySpeed = 0.0;
float distanceTime = 0.0; // used for calculating speed
float prevDistanceTime = 0.0;
float distanceTimeDelta = 0.0;
boolean stop = true;
boolean followMode = false; // true = reference object, false = reference speed

void setup() {
  size (800, 576); // (width,height)
  myClient = new Client(this, "192.168.4.1", 5200); //port 5200
  font = createFont("hooge 05_55", 24);
  //font = createFont("Times New Roman", 24);
  startupImg = loadImage("r2d2hq.png");
  mainImg = loadImage("r2d2bg.png");
  c3poImg = loadImage("c3po.png");
  startup(); // displays intro screen
  addButtons(); // displays buttons after startup
}

String data;

void draw() {
  itCount++;
  if (itCount == 1) // required to prevent buttons from becoming too laggy
    delay(0); // delay between startup screen and main screen ONLY ON FIRST ITERATION OF DRAW
  if ((millis() > currentTime + 1000)) // refreshes screen 1 second after a button is pressed
    image(mainImg, 0, 0);

  dataC = myClient.readChar(); // code for reading in US sensor data

  // 'o' is received if object is spotted, 'z' is received if path is clear
  if ((dataC == 'o') || (dataC == 'z')) // filters out null and other chars being read in
    dataB = dataC;
  else if (dataC == '+') { // increment distance using a character read in
    travDistance += 0.2; // changed from 0.1 to 0.2 as it seemed to match actual distance travelled
    distanceTime = millis();
    distanceTimeDelta = distanceTime - prevDistanceTime;
    prevDistanceTime = distanceTime;
    distanceTimeDelta = distanceTimeDelta / 1000.00;
  } else if ( int (dataC) != 65535 ) // this seems to be constantly read in, so this line filters it out
    objDistance = ( int (dataC) ); // objectDistance is sent over from arduino as ASCII, convert back to get a distance measurement

  objectSpotted(); // checks if object is spotted or not

  if (stop || distanceTimeDelta == 0) { // some logic for handling displaying buggy speed
    buggySpeed = 0;
  } else
    buggySpeed = 0.1  / distanceTimeDelta;
    
  referenceSpeed = cp5.getController("Speed").getValue();
  referenceSpeed();

  textAlign(CENTER);
  fill(0);
  textFont(font);
  textSize(36);
  text ("R2-Z2", 400, 30);
  textSize(24);
  text("Connection:", 400, 60);
  if (followMode)
    text("Mode: Reference Object", 400, 90);
  else
    text("Mode: Reference Speed", 400, 90);
  text ("Object Distance (cm): " + objDistance, 400, 120);
  text("Distance Travelled (m): " + travDistance, 400, 150);
  text("Velocity (m/s): " + buggySpeed, 400, 180);
  text("Reference Speed (m/s): " + referenceSpeed, 400, 210);

  int connectionW = 485;
  int connectionH = 50;
  int connectionR = 15;
  if (myClient.active()) // if client is connected, draw a tick
    drawTick(connectionW-5, connectionH, connectionW+10, connectionH-10);
  else  // if client is not connected, draw an X
  drawX(connectionW, connectionH, connectionR);
  /* This can take some time to register, as I believe it tries to
   reconnect to the server after disconnecting, which takes quite some time */
}

void startup() {
  background(0, 0, 255);
  image(startupImg, 0, 0);
  textSize(56);
  textFont(font);
  text("Welcome to R2-Z2", 50, 120);
  text("Group Z2's 2E10 Project", 50, 150);
  text("Made by:", 50, 360);
  text("Billy Lee", 60, 410);
  text("Luca Genovese", 60, 440);
  text("Salifya Mtambo", 60, 470);
  text("Wafi Ahmed", 60, 500);
}

void addButtons() { // displays buttons
  cp5 = new ControlP5(this);
  cp5.addButton("START")
    .setPosition(100, 400)
    .setColorBackground(color(4, 84, 168))
    .setSize(100, 100)
    .setFont(font)
    ;
  cp5.addButton("STOP")
    .setPosition(600, 400)
    .setSize(100, 100)
    .setColorBackground(color(4, 84, 168))
    .setFont(font)
    ;
  cp5.addSlider("Speed")
    .setPosition(200, 230)
    .setSize(400, 50)
    .setRange(130, 200)
    .setColorBackground(color(4, 84, 168))
    .setNumberOfTickMarks(8)
    ;
  cp5.addButton("MODE")
    .setColorBackground(color(4, 84, 168))
    .setPosition(575, 70)
    .setSize(50, 24)
    ;
}
void MODE() { // logic for mode button
  followMode = !followMode;
  if (followMode)
    myClient.write('f');
  else myClient.write('r');
}

void Speed() { // logic for reference speed slider
}

void STOP() { // logic for stop button
  stop = true;
  buggySpeed = 0;
  textAlign(CENTER);
  currentTime = millis();
  fill(0, 0, 0);
  if (myClient.active()) {
    text("BUGGY STOPPED", 400, 370);
    myClient.write('0');
  } else noConnection() ;
}

void START() { // logic for start button
  textAlign(CENTER);
  currentTime = millis();
  fill(0, 0, 0);
  if (myClient.active()) {
    text("BUGGY STARTED", 400, 340);
    myClient.write('1');
  } else noConnection();
  stop = false;
}

void objectSpotted() {
  //dataB = 'p';
  if (dataB != 'z') { // this method allows popup to display UNTIL object is no longer in the way
    text("Objected Spotted!", 400, 310);
    image(c3poImg, 525, 285);
    stop = true;
  } else if (dataB == 'z')
    stop = false;
}

void referenceSpeed() {
  if (referenceSpeed != prevReferenceSpeed) { // whenever the reference speed slider is changed, send it to the arduino
    prevReferenceSpeed = referenceSpeed;
    myClient.write('v');
    delay(100);
    String speedStr = referenceSpeed + "v";
    myClient.write(speedStr);
  }
}
void noConnection() {
  textAlign(CENTER);
  text("NO CONNECTION", 400, 340);
}

void drawTick(float x1, float y1, float x2, float y2) { // draws a green tick
  stroke(0, 255, 0);
  strokeWeight(5);
  line(x1, y1, x1+5, y1+5);
  line(x1+5, y1+5, x2, y2);
}

void drawX(float x, float y, float size) { // draws a red x
  stroke(255, 0, 0);
  strokeWeight(5);
  line(x - size / 2, y - size / 2, x + size / 2, y + size / 2);
  line(x - size / 2, y + size / 2, x + size / 2, y - size /2);
}
