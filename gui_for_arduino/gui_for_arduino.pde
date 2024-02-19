/*
 ******** FILES INCLUDED ********
 1. "r2d2hq.png" image of R2D2 for startup screen
 ******** LIBRARIES ADDED ********
 1. "ControlP5" adds buttons
 2. "UDP" by Stephane Cousot
*/

import controlP5.*;  // gives button control
import hypermedia.net.*; // allows UDP sending to arduino

ControlP5 cp5;
UDP udp;

PFont font;
PImage img; 

String ipAddress = "192.168.1.114";  //  Arduino's IP address
int port = 123;

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
  if ( millis() > (currentTime + 1000) ) // refreshes screen after a button is pressed
    background(r,g,b);
  int packetsize = udp.parsePacket();
   if (packetSize) {
    Serial.print("Received packet of size ");
    Serial.println(packetSize);
    Serial.print("From ");
    IPAddress remoteIp = Udp.remoteIP();
    Serial.print(remoteIp);
    Serial.print(", port ");
    Serial.println(Udp.remotePort());
    // read the packet into packetBufffer
    int len = Udp.read(packetBuffer, 255);
    if (len > 0) {
      packetBuffer[len] = 0;
    }
    Serial.println("Contents:");
    Serial.println(packetBuffer);
  fill(0);
  textAlign(CENTER);
  text ("BUGGY CONTROL", 400, 50); // ("text", x, y)
}

void startup(){
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
  stopState = 1;
  udp.send("STOP", ipAddress, port); // sends "stop" to arduino
}

void START(){ // logic for start button
  startState=1;
  udp.send("START", ipAddress, port);
}

