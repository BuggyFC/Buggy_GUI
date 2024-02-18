/*
 ******** FILES INCLUDED ********
 1. "r2d2hq.png" image of R2D2 for startup screen
 ******** LIBRARIES ADDED ********
 1. "ControlP5" adds buttons
 2. "UDP" by Stephane Cousot
 ******** KNOWN ISSUES ******** 
 1. Kinda just randomly breaks when running more than once
*/

import controlP5.*;  // gives button control
import hypermedia.net.*; // allows UDP sending to arduino

ControlP5 cp5;
UDP udp;

PFont font;
PImage img; 

String ipAddress = "192.168.1.114";  //  Arduino's IP address
int port = 123;

int stopState = 0; // 0 if stop button is not pressed, 1 if pressed
int startState = 0; // 0 if start button is not presssed, 1 if pressed
//boolean drs = false;
int counter = 0; // counter for refreshing screen
int itCount = 0; // iteration counter for draw loop
int r=255;
int g=255;
int b=255; 
int w = 800; // window width
int h = 600; // window height

void setup(){
  size (800,600,P3D); // (w,h, P3D adds 3d effect (not used) )
  udp = new UDP(this, port); 
  font = createFont("times new roman", 24); 
  img = loadImage("r2d2hq.png");
  
  startup(); // displays into screen
  addButtons(); // displays buttons after startup
  
}

void draw(){
  itCount++;
  if (itCount == 1){ // required to prevent buttons from becoming too laggy
    delay(5000); // delay between startup screen and main screen ONLY ON FIRST ITERATION OF DRAW
  }
  
  background(r,g,b);
  textSize(26);
  rectMode(CENTER);
  fill(0,0,255);
  rect(400,0,300,200);
  
  fill(r,g,b);
  textAlign(CENTER);
  text ("BUGGY CONTROL", 400, 50); // ("text", x, y)
  refreshScreen();
}

void startup(){
  background(0,0,255);
  image(img,0,0);
  textSize(56);
  textFont(font);
  text("Welcome to R2-Z2" ,50,120); 
  text("Group Z2's 2E10 Project", 50, 150);
  //text( "> Continue", 50, 300); // could add a continue button on start screen instead of timer
  //stroke(255,255,255);
  //line(70,305, 160,305);
  
  text("Made by:",50,360);
  text("Billy Lee", 60, 410);
  text("Luca Genovese", 60, 440);
  text("Salifya Mtambo", 60, 470);
  text("Wafi Ahmed", 60, 500);
}

void refreshScreen(){ // displays when button is pressed and refreshes screen after button pressed
 if (stopState == 1){ // if stop is pressed
    if (counter > 100){ // count till 100 then refresh
      stopState = 0;
      counter = 0;
      background (r,g,b);
    }
    else { // until counter == 100, display text
      counter++;
      fill(0,0,0);
      text("BUGGY STOPPED", 400,200);
    }
  }
  
  if (startState == 1){ // if start is presssed
    if (counter > 100){ // count till 100 then refresh
      startState = 0;
      counter = 0;
      background (r,g,b);
    }
    else { // until counter == 100, display text
      counter++;
      fill(0,0,0);
      text("BUGGY STARTED", 400,300);
    }
  }  
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
   
 //cp5.addSlider("SPEED") // might be able to use the .setValue() to display speed 
 //   .setFont(font)
 //   .setPosition(350, 400)
 //   .setSize(100, 100)
 //   //.setRange(0, 5)
 //   .setValue(3)
 //   .setColorCaptionLabel(color(20,20,20));
 //;
 //cp5.addToggle("DRS")
 //   .setFont(font)
 //   .setPosition(500,400)
 //   .setColorLabel( color(0,0,0))
 //;
}
void STOP(){ // logic for stop button
  stopState = 1;
  udp.send("STOP", ipAddress, port); // sends "stop" to arduino
}
void START(){ // logic for start button
  startState=1;
  udp.send("START", ipAddress, port);
}
//void DRS(){ // logic for (eventual) DRS button
//  drs = !drs;
//  udp.send("DRS", ipAddress, port);
//}
