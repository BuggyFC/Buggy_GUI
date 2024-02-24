/*
 ******** FILES INCLUDED ********
 1. "r2d2hq.png" image of R2D2 for startup screen
 2. "r2d2bg.png" pixel art r2d2 background for main screen
 ******** LIBRARIES ADDED ********
 1. "ControlP5" adds buttons
 2. "processing.net.*" allows wifi communication
 *********************************
 rgb for r2d2 blue (4,84,168) */
 
import controlP5.*;  // gives button control
import processing.net.*; // allows wifi communication

Client myClient; // GUI is client, Arduino is server
ControlP5 cp5;

PFont font;
PImage img; // r2d2 image for startup screen
PImage img2; // r2d2 image for main screen
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
float travDistance = 0;
  
void setup(){
  size (800,576); // (width,height)
  myClient = new Client(this, "192.168.4.1", 5200); //port 5200
  font = createFont("hooge 05_55", 24); 
  img = loadImage("r2d2hq.png"); 
  img2 = loadImage("r2d2bg.png");
  startup(); // displays intro screen
  addButtons(); // displays buttons after startup
}

void draw(){
  itCount++;
  if (itCount == 1) // required to prevent buttons from becoming too laggy
    delay(2000); // delay between startup screen and main screen ONLY ON FIRST ITERATION OF DRAW
  
  if ((millis() > currentTime +1000)) // refreshes screen after a button is pressed
    image(img2,0,0); 
  
  dataC = myClient.readChar(); // code for reading in US sensor data
  // 'o' is received if object is spotted, 'z' is received if path is clear
  if ((dataC == 'o') || (dataC == 'z')) // filters out null and other random chars being read in
  dataB = dataC;
  if (dataB != 'z')
    text("Objected Spotted!", 400,100);

    text("Distance Travelled:", 350,250);
    
  if(dataC == '+')
    travDistance += 0.1;
  
  text(travDistance,485,250);
  text('m',530,250);
   
  fill(0);
  textAlign(CENTER);
  text ("BUGGY CONTROL", 400, 50); 
  text("Connection: ", 400, 75);
  int connectionW = 480;
  int connectionH = 68;
  int connectionR = 15;
  
  if (myClient.active()) // if client is connected, draw a tick
    drawTick(connectionW-5, connectionH, connectionW+10, connectionH-10);
  else  // if client is not connected, draw an X
    drawX(connectionW, connectionH, connectionR);
  /* This can take some time to register, as I believe it tries to 
    reconnect to the server after disconnecting, which takes quite some time */
    
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
    .setPosition( 100 , 400)
    .setColorBackground( color(4,84,168) )
    .setSize(100,100)
    .setFont(font)
 ;
 cp5.addButton("START")
    .setPosition( 3*w / 4,400)
    .setSize(100,100)
    .setColorBackground( color(4,84,168) )
    .setFont(font)
 ;
}
void STOP(){ // logic for stop button
  currentTime = millis();  
  fill(0,0,0);
  if (myClient.active()){
    text("BUGGY STOPPED", 400,200);
    myClient.write('s');
  }
  else text("NO CONNECTION", 400, 200);
}
void START(){ // logic for start button
  currentTime = millis();
  fill(0,0,0);
  if (myClient.active()){
    text("BUGGY STARTED", 400,300);
    myClient.write('w');
  }
  else text("NO CONNECTION", 400, 300);
}
void drawTick(float x1, float y1, float x2, float y2) {
  stroke(0,255,0);
  strokeWeight(5);
  line(x1,y1,x1+5,y1+5);
  line(x1+5,y1+5,x2,y2);
}
void drawX(float x, float y, float size){
stroke(255,0,0);
strokeWeight(5);
line(x - size / 2, y - size / 2, x + size / 2, y + size / 2);
line(x - size / 2, y + size / 2, x + size / 2, y - size /2);

}
