import processing.sound.*;
Amplitude amp;  // volume analyzer
AudioIn in;

int x = 0;

int NUM2 =24;

//Line + Others
float scale=15;
float smooth_factor=0.1;
float smooth_factor2=0.01;
float sum;

//Pictures
PImage imgFly01;
PImage imgFly02;
PImage imgFly03;
PImage imgFly04;

//Perlin Noise
int cols, rows;
int scl = 80;
int w = 2400;
int h = 1600;
float flying = 0;
float[][] terrain;

//Cyrcle
int radius = 100;
int numLines = 300;
float nx = 0;
float ny = 0;
float smooth_factor3=0.001;
float smooth_factor4=0.001;

//Line
static final int NUM_LINES = 10;
float t;


///////STATEMENT - Animation State Machine

enum State {
  STATE_C, STATE_V, STATE_B, STATE_N, STATE_DEFAULT
};
State actualState = State.STATE_DEFAULT;

void setup() {
  //fullScreen(P3D, 2);
  size(1920, 1080, P3D);
  //background(255);
  //pixelDensity(2);


  amp = new Amplitude(this);
  in = new AudioIn(this, 0);
  in.start();
  amp.input(in);

  //Perlin Noise
  cols = w / scl;
  rows = h/ scl;
  terrain = new float[cols][rows];
  //Images
  imgFly01 = loadImage("sample_01.png");
  imgFly01.width = width;
  imgFly01.height = height;

  imgFly02 = loadImage("sample_02.png");
  imgFly02.width = width;
  imgFly02.height = height;

  imgFly03 = loadImage("sample_03.png");
  imgFly03.width = width;
  imgFly03.height = height;

  imgFly04 = loadImage("sample_04.png");
  imgFly04.width = width;
  imgFly04.height = height;
}      

void draw() {

  checkControls();
  switchState();
}

////STATE KEY BINDING
void checkControls() {
  if (key == 'c' || key == 'C') {
    actualState = State.STATE_C;
  } else if (key == 'v' || key == 'V') {
    actualState = State.STATE_V;
  } else if (key == 'b' || key == 'B') {
    actualState = State.STATE_B;
  } else if (key == 'n' || key == 'N') {
    actualState = State.STATE_N;
  }
}


////STATE CLASS STATEMENT
void switchState() {
  switch(actualState) {
  case STATE_C: 
    lounging();
    break;
  case STATE_V: 
    mikePattern();
    break;
  case STATE_B:
    amavama();
    break;
  case STATE_N:
    afterHour();
    break;
  default: 
    actualState = State.STATE_DEFAULT;
    break;
  }
}

//////////////////////////////////////sample_01
void lounging() {
  //println(amp.analyze());
  background(imgFly01);
  noStroke();


  translate(width / 2, height / 2);
  for (int i = 0; i < NUM2; i++) {


    sum += (amp.analyze() - sum) * smooth_factor4;
    float amp_scaled=sum*(height/1000)*scale;

    float angle = i * TWO_PI / NUM2;
    float v = pow(abs(sin(angle / 2 + frameCount * 0.03)), 4);
    float r = map(v, 0, 1, 10, 20);
    fill(lerpColor(color(255, 255, 255, 100), color(0, 0, 0, 100), v));
    ellipse((150 + r) * cos(angle)*amp_scaled, (150 + r) * sin(angle)*amp_scaled, r * 2*amp_scaled, r * 2*amp_scaled);
    //ellipse((300 + r)*amp_scaled/2 * cos(angle), (300 + r) * sin(angle), r * 8, r * 8);
    //ellipse((300 + r) * cos(angle), (300 + r) * sin(angle)*amp_scaled/5, r * 2, r*2 );
    //ellipse((300 + r) * cos(angle)*amp_scaled/5, (300 + r) * sin(angle), r * 2, r*2 );
  }
}





//////////////////////////////////////sample_02

void mikePattern() {
  //println(amp.analyze());
  background(imgFly02);
  stroke(255, 20);
  noFill();

  float angle = 0;
  pushMatrix();
  translate(width/2, height/2);
  for (int i = 0; i < numLines; i++) {

    sum += (amp.analyze() - sum) * smooth_factor3;
    float amp_scaled=sum*(height/500)*scale;

    float x1, x2, y1, y2;
    float randLength = map(noise(nx+i*.1, ny), 0, 1, 10, radius * 4)*amp_scaled;
    strokeWeight(map(randLength, 0, radius*3, 1, 6));
    x1 = radius * cos(angle);
    y1 = radius * sin(angle);
    x2 = x1 + randLength * cos(angle+PI/2);
    y2 = y1 + randLength * sin(angle+PI/2);
    line(x1, y1, x2, y2);
    angle+=TWO_PI/numLines;
  }
  popMatrix();
  nx+=.05;
  ny+=.01;
}


//////////////////////////////////////sample_03

void amavama() {
  //println(amp.analyze());
  background(imgFly03);



  stroke (255, 255, 255, 100);
  strokeWeight (4);

  translate (width/2, height/2);

  for (int i = 0; i < NUM_LINES; i++) {
    sum += (amp.analyze() - sum) * smooth_factor2;
    float amp_scaled=sum*(height/200)*scale;

    line(x1(t + i)*amp_scaled/10, y1(t + i), x2(t + i), y2(t + i)*amp_scaled/5);
  }
  t += 0.09;
}
float x1(float t) {
  return sin(-t / 1) * 100 + sin(t / 5) * 200;
}
float y1(float t) {
  return cos(t / 1)* 100 + sin(t/2) * 500;
}
float x2(float t) {
  return sin(t / 1) * 200 + sin(t) * 2 + cos(t) * 100;
}
float y2(float t) {
  return -cos(t / 2)* 200 + cos (t /12) * 200;
}




//////////////////////////////////////sample_04

void afterHour() {
  //println(amp.analyze());
  background(imgFly04);


  sum += (amp.analyze() - sum) * smooth_factor;
  float amp_scaled=sum*(height/300)*scale;

  flying -= 0.1;

  float yoff = flying;
  for (int y = 0; y < rows; y++) {
    float xoff = 0;
    for (int x = 0; x < cols; x++) {
      terrain[x][y] = map(noise(xoff, yoff), 0, 1, -30*amp_scaled, 30*amp_scaled);
      xoff += 0.2;
    }
    yoff += 0.2;
  }

  stroke(255, 255, 255, 50);
  noFill();
  strokeWeight (2);

  translate(width/2, height/2+50);
  rotateX(PI/3);
  translate(-w/2, -h/2);
  for (int y = 0; y < rows-1; y++) {
    beginShape(TRIANGLE_STRIP);
    for (int x = 0; x < cols; x++) {
      vertex(x*scl, y*scl, terrain[x][y]);
      vertex(x*scl, (y+1)*scl, terrain[x][y+1]);
      //rect(x*scl, y*scl, scl, scl);
    }
    endShape();
  }
}