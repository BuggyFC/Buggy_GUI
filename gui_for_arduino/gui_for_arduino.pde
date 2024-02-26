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
PImage startupImg; // r2d2 image for startup screen
PImage mainImg; // r2d2 image for main screen
PImage c3poImg; // c3po pops up during obstacle detection
PImage leftArrowImg;
PImage rightArrowImg;
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
  startupImg = loadImage("r2d2hq.png"); 
  mainImg = loadImage("r2d2bg.png");
  c3poImg = loadImage("c3po.png");
  leftArrowImg = loadImage("leftarrow.png");
  rightArrowImg = loadImage("rightarrow.png");
  startup(); // displays intro screen
  addButtons(); // displays buttons after startup
}

void draw(){
  itCount++;
  if (itCount == 1) // required to prevent buttons from becoming too laggy
    delay(2500); // delay between startup screen and main screen ONLY ON FIRST ITERATION OF DRAW
  
  if ((millis() > currentTime +1000)) // refreshes screen 1 second after a button is pressed
    image(mainImg,0,0); 
  
  dataC = myClient.readChar(); // code for reading in US sensor data
  // 'o' is received if object is spotted, 'z' is received if path is clear
  if ((dataC == 'o') || (dataC == 'z')) // filters out null and other chars being read in
    dataB = dataC;
  //dataB = 'o';
  if (dataB != 'z'){
    text("Objected Spotted!", 400,100);
    image(c3poImg,525,75);
  }
  
  if (dataC == 'r'){
    text("Turning", w - 55, 200);
    text("Right", w - 55, 220);
    //imageMode(CENTER);
    image(rightArrowImg, w-110, 100);
    currentTime = millis();
  }
  if (dataC == 'l'){
    text("Turning", 55, 200);
    text("Left", 55, 220);
    //imageMode(CENTER);
    image(leftArrowImg, 0, 100);
    currentTime = millis();
  }
  //dataC = '+';
  if(dataC == '+') // increment distance using a character read in
    travDistance += 0.1;
  text(travDistance,400,320);
  fill(0);
  text('m',460,320);
  textAlign(CENTER);
  text("Distance Travelled:", 400,300);
  textSize(36);
  text ("R2-Z2", 400, 50);
  textSize(24);
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
  //line(w/2,0, w / 2, h);
}

void startup(){ 
  background(0,0,255);
  image(startupImg,0,0);
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
    text("BUGGY STOPPED", 400,230);
    myClient.write('s');
  }
  else text("NO CONNECTION", 400, 230);
}
void START(){ // logic for start button
  currentTime = millis();
  fill(0,0,0);
  if (myClient.active()){
    text("BUGGY STARTED", 400,200);
    myClient.write('w');
  }
  else text("NO CONNECTION", 400, 200);
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
