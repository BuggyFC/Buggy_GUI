/* WORKS WITH LATEST CODE IN WIFI-COMMUNICATION, SENDS W WHEN START IS PRESSED, S WHEN STOP IS PRESSED
   Connect laptop to the AP created by the Arduino before running the Processing GUI.
 ******** FILES INCLUDED ********
 1. "r2d2hq.png" image of R2D2 for startup screen 
 ******** LIBRARIES ADDED ********
 1. "ControlP5" adds buttons
 2. "processing.net.*" allows wifi communication
 */

import controlP5.*;  // gives button control
import processing.net.*; // allows wifi communication

Client myClient; // GUI is client, Arduino is server
ControlP5 cp5;

PFont font;
PImage img; 

String data;
int port = 5200;

int currentTime; // counter for refreshing screen
int itCount = 0; // iteration counter for draw loop
int r=255;
int g=255;
int b=255; 
int w = 800; // window width
int h = 600; // window height

void setup(){
  size (800,600); // (width,height)
  myClient = new Client(this, "192.168.4.1", 5200); //port 5200
  myClient.write("new client");
  font = createFont("times new roman", 24); 
  img = loadImage("r2d2hq.png");
  startup(); // displays intro screen
  addButtons(); // displays buttons after startup
}

void draw(){
  itCount++;
  if (itCount == 1) // required to prevent buttons from becoming too laggy
    delay(5000); // delay between startup screen and main screen ONLY ON FIRST ITERATION OF DRAW
  if ((millis() > currentTime +1000)) // refreshes screen after a button is pressed
    background(r,g,b);
  data = myClient.readString(); // read data from arduino
  if (data != null) // prevents spamming "null";
    println(data);
  fill(0);
  textAlign(CENTER);
  text ("BUGGY CONTROL", 400, 50); // ("text", x, y)
  }

void startup(){ // maybe run it till connection established OR button pressed
  background(0,0,255);
  image(img,0,0);
  textSize(56);
  textFont(font);
  text("Welcome to R2-Z2" ,50,120); 
  text("Group Z2's 2E10 Project", 50, 150);
  text("Made by:",50,360);
  text("Billy Lee", 60, 410);
  text("Luca Genovese", 60, 440);
  text("Salifya Mtambo", 60, 470);
  text("Wafi Ahmed", 60, 500);
}

void addButtons(){ // displays buttons
  cp5 = new ControlP5(this);
  cp5.addButton("STOP")
    .setPosition(200,400)
    .setSize(100,100)
    .setFont(font)
 ;
 cp5.addButton("START")
    .setPosition(50,400)
    .setSize(100,100)
    .setFont(font)
 ;
}
void STOP(){ // logic for stop button
  currentTime = millis();  
  fill(0,0,0);
  text("BUGGY STOPPED", 400,200);
  myClient.write('s');
}
void START(){ // logic for start button
  currentTime = millis();
  fill(0,0,0);
  text("BUGGY STARTED", 400,300);
  myClient.write('w');
}
