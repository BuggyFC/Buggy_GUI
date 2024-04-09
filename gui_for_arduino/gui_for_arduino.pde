/*
 ******** FILES INCLUDED ********
 1. "r2d2hq.png" image of R2D2 for startup screen
 2. "r2d2bg.png" pixel art r2d2 background for main screen
 3. "c3po.png" pixel art c3po for Obstacle Detected pop-up
 ******** LIBRARIES ADDED ********
 1. "ControlP5.*" adds buttons
 2. "processing.net.*" allows wifi communication
 *********************************
 rgb for r2d2 blue (4,84,168) */

import controlP5.*;  // gives button control
import processing.net.*; // allows wifi communication

Client client; // GUI is client, Arduino is server
ControlP5 cp5;

PFont font;
PImage startup_image; // r2d2 image for startup screen
PImage main_image; // r2d2 image for main screen
PImage c3po_image; // c3po pops up during obstacle detection
char data_char; // read in from Server (Arduino)
char data_filter = 'z';  // filters out data_char for relevant chars
int port = 5200;
int current_time; // counter for refreshing screen
int it_count = 0; // iteration counter for draw loop
int r=255;
int g=255;
int b=255;
int w = 800; // window width
int h = 576; // window height
int connection_w = 485;
int connection_h = 50;
int connection_r = 15;
int obj_distance = 0;
float trav_distance = 0.0;
float reference_speed = 0.0;
float prev_reference_speed = 0.0;
float buggy_speed = 0.0;
boolean stop = true;
boolean follow_mode = false; // true = reference object, false = reference speed
String data_string = "";
String obj_string= "";
String spd_string = "";
String dis_string = "";
boolean tag1 = false;
boolean tag2 = false;
boolean tag3 = false;
boolean tag4 = false;

void setup() {
  size (800, 576); // (width,height)
  client = new Client(this, "192.168.4.1", 5200); //port 5200
  font = createFont("hooge 05_55", 24);
  startup_image = loadImage("r2d2hq.png");
  main_image = loadImage("r2d2bg.png");
  c3po_image = loadImage("c3po.png");
  startup(); // displays intro screen
  addButtons(); // displays buttons after startup
  client.write('l');
}

void draw() {
  it_count++;
  if (it_count == 1) // required to prevent buttons from becoming too laggy
    delay(2500); // delay between startup screen and main screen ONLY ON FIRST ITERATION OF DRAW
  if ((millis() > current_time + 1000)) { // refreshes screen 1 second after a button is pressed  
    image(main_image, 0, 0);
    //show_tag_data = !show_tag_data;
  }

  //println(log_string);
  receiveData();
  if (obj_string!= "")
    obj_distance = Integer.valueOf(obj_string);
  if (spd_string != "")
    buggy_speed = Float.valueOf(spd_string);
  if (dis_string != "")
    trav_distance = Float.valueOf(dis_string) / 100;

  objectSpotted(); // checks if object is spotted or not
  reference_speed = cp5.getController("Speed").getValue();
  reference_speed(); // sends reference speed to arduino
  displayTelemetry();

  if (client.active()) // if client is connected, draw a tick
    drawTick(connection_w-5, connection_h, connection_w+10, connection_h-10);
  else  // if client is not connected, draw an X
  drawX(connection_w, connection_h, connection_r);
  /* This can take some time to register, as I believe it tries to
   reconnect to the server after disconnecting, which takes quite some time */
}

void startup() {
  background(0, 0, 255);
  image(startup_image, 0, 0);
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
    .setRange(0.05, 0.15)
    .setColorBackground(color(4, 84, 168))
    .setNumberOfTickMarks(10)
    ;
  cp5.addButton("MODE")
    .setColorBackground(color(4, 84, 168))
    .setPosition(575, 70)
    .setSize(50, 24)
    ;
}
void MODE() { // logic for mode button
  follow_mode = !follow_mode;
  if (follow_mode)
    client.write('f');
  else client.write('r');
}

void Speed() { // logic for reference speed slider
}

void STOP() { // logic for stop button
  stop = true;
  textAlign(CENTER);
  current_time = millis();
  fill(0, 0, 0);
  if (client.active()) {
    text("BUGGY STOPPED", 400, 370);
    client.write('s');
  } else noConnection() ;
}

void START() { // logic for start button
  textAlign(CENTER);
  current_time = millis();
  fill(0, 0, 0);
  if (client.active()) {
    text("BUGGY STARTED", 400, 340);
    client.write('w');
  } else noConnection();
  stop = false;
}
void receiveData() {
  data_char = client.readChar(); // code for reading in data
  //data_char = 'y';
  //println(data_char);
  //println(data_string);
  if ( (data_char >= '0') && (data_char <= '9') || (data_char == '.') ) // filters to read in integers and floats
    data_string = data_string + data_char;
  // 'o' is received if object is spotted, 'z' is received if path is clear
  if ( (data_char == 'o') || (data_char == 'z') ) // filters out null and other chars being read in
    data_filter = data_char;
  //println(data_filter);
  if (data_char == 'd') { // code for reading in obj_distance
    if (data_string != "")
      obj_string = data_string;
    data_string = "";
  }
  if (data_char == 'v') { // code for reading in measuredSpeed
    if (data_string != "")
      spd_string = data_string;
    data_string = "";
  }
  if (data_char == 't') { // code for reading in trav_distance
    if (data_string != "")
      dis_string = data_string;
    data_string = "";
  }
  if (data_char == 'm') {
    tag1 = true;
    tag2 = false;
    tag3 = false;
    tag4 = false;
  }
  if (data_char == 'n') {
    tag1 = false;
    tag2 = true;
    tag3 = false;
    tag4 = false;
  }
  if (data_char == 'p') {
    tag1 = false;
    tag2 = false;
    tag3 = true;
    tag4 = false;
  }
  if (data_char == 'q') {
    tag1 = false;
    tag2 = false;
    tag3 = false;
    tag4 = true;
  }
  if (data_char == 'k'){
    tag1 = false;
    tag2 = false;
    tag3 = false;
    tag4 = false;
  }
}

void objectSpotted() { // displays popup when object is detected
  //data_filter = 'p';
  //if (data_filter != ' ') { // this method allows popup to display UNTIL object is no longer in the way
  //  text("Objected Spotted!", 400, 310);
  //  image(c3po_image, 525, 285);
  //  stop = true;
  //} else if (data_filter == 'z'){
  //  stop = false;
  //  println("ZZZZZZZ");
  //}
  if (obj_distance <= 10) {
    text("Objected Spotted!", 400, 310);
    image(c3po_image, 525, 285);
    stop = true;
  } else
    stop = false;
}

void reference_speed() {
  if (reference_speed != prev_reference_speed) { // whenever the reference speed slider is changed, send it to the arduino
    prev_reference_speed = reference_speed;
    client.write('v');
    String speedStr = reference_speed + "v";
    client.write(speedStr);
  }
}
void displayTelemetry() {
  textAlign(CENTER);
  fill(0);
  textFont(font);
  textSize(36);
  text ("R2-Z2", 400, 30);
  textSize(24);
  text("Connection:", 400, 60);
  if (follow_mode)
    text("Mode: Reference Object", 400, 90);
  else
    text("Mode: Reference Speed", 400, 90);
  text ("Object Distance (cm): " + obj_distance, 400, 120);
  text("Distance Travelled (m): " + String.format("%.2f", trav_distance), 400, 150);
  text("Velocity (m/s): " + String.format("%.2f", buggy_speed), 400, 180);
  text("Reference Speed (m/s): " +  String.format("%.2f", reference_speed ), 400, 210);
  //if (show_tag_data && log_string != "")
  //text(log_string, 400, 340);
  //println(log_string);
  if (tag1) {
    text("Slowing Down", 400, 350);
  }
  if (tag2) {
    text("Speeding Up", 400, 350);
  }
  if (tag3) {
    text("Turning Right", 400, 350);
  }
  if (tag4) {
    text("Turning Left", 400, 350);
  }
}
void noConnection() { // popup when attempting to use buttons while disconnected from server
  textAlign(CENTER);
  text("NO CONNECTION", 400, 340);
}

void drawTick(float x1, float y1, float x2, float y2) { // draws a green tick
  stroke(0, 255, 0);
  strokeWeight(5);
  line(x1, y1, x1 + 5, y1 + 5);
  line(x1 + 5, y1 + 5, x2, y2);
}

void drawX(float x, float y, float size) { // draws a red x
  stroke(255, 0, 0);
  strokeWeight(5);
  line(x - size / 2, y - size / 2, x + size / 2, y + size / 2);
  line(x - size / 2, y + size / 2, x + size / 2, y - size /2);
}
