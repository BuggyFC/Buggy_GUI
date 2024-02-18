/*
 ******** FILES INCLUDED ********
 1. "r2d2hq.png" image of R2D2
 ******** LIBRARIES ADDED ********
 1. "ControlP5" adds buttons
 2. "Video Library for Processing 4" adds video control
 ******** KNOWN ISSUES ******** 
 1. Kinda just randomly breaks when running more than once
*/

import controlP5.*;  // gives button control
//import processing.video.*; // intro video to be added

ControlP5 cp5;
//Movie movie;
PFont font;
PImage img; 

int stopState = 0; 
int startState = 0;
boolean drs = false;
int counter = 0; // counter for refreshing screen
int itCount = 0; // iteration counter for draw loop
int r=255;
int g=255;
int b=255;
int w = 800;
int h = 600;

void setup(){
  size (800,600,P3D); // (w,h, adds 3d effect)
  font = createFont("times new roman", 24); 
  img = loadImage("r2d2hq.png");
  
  //movie = new Movie(this, "intro_video.mov");
  //movie.play();
  startup();
  addButtons();
  strokeWeight(20);
  stroke(0,0,255);
  line(0,10, w, 10);
  line(10,10, 10, h);
  line(w-10, 10, w-10, h);
  line(w-10, h-10, 0, h-10);
}

void draw(){
  itCount++;
  if (itCount == 1){ // required to prevent buttons from becoming too laggy
    delay(5000); // delay between startup screen and main screen ONLY ON FIRST ITERATION OF DRAW
  }
  
  background(r,g,b);
  //strokeWeight(20);
  //stroke(0,0,255);
  //line(0,10, w, 10);
  //line(10,10, 10, h);
  //line(w-10, 10, w-10, h);
  //line(w-10, h-10, 0, h-10);
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
  //text( "> Continue", 50, 300);
  //stroke(255,255,255);
  //line(70,305, 160,305);
  
  text("Made by:",50,360);
  text("Billy Lee", 60, 410);
  text("Luca Genovese", 60, 440);
  text("Salifya Mtambo", 60, 470);
  text("Wafi Ahmed", 60, 500);
}

void refreshScreen(){ // displays when button is pressed and refreshes screen after button pressed
 if (stopState == 1){
    if (counter > 100){
      stopState = 0;
      counter = 0;
      background (r,g,b);
    }
    else {
      counter++;
      fill(0,0,0);
      text("BUGGY STOPPED", 400,300);
    }
  }
  
  if (startState == 1){
    if (counter > 100){
      startState = 0;
      counter = 0;
      background (r,g,b);
    }
    else {
      counter++;
      fill(0,0,0);
      text("BUGGY STARTED", 400,400);
    }
  }
  if (drs)
    text("DRS ACTIVE", 200,200); 
  else {
    rectMode(CENTER);
    stroke(r,g,b);
    strokeWeight(10);
    fill(r,g,b);
    rect(200,200,100,100);
  }
}
void STOP(){ // logic for stop button
  stopState = 1;
}
void START(){ // logic for start button
  startState=1;
}
void DRS(){ // logic for (eventual) DRS button
  drs = !drs;
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
   
 cp5.addSlider("SPEED")
    .setFont(font)
    .setPosition(350, 400)
    .setSize(100, 100)
    //.setRange(0, 5)
    .setValue(3)
    .setColorCaptionLabel(color(20,20,20));
 ;
 //cp5.getController ("SPEED").getCaptionlabel().align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);
 cp5.addToggle("DRS")
    .setFont(font)
    .setPosition(500,400)
    .setColorLabel( color(0,0,0))
 ;
 
}
