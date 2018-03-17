import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import controlP5.*; 
import oscP5.*; 
import netP5.*; 
import themidibus.*; 
import dmxP512.*; 
import processing.serial.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Cells extends PApplet {









//oscP5
OscP5 oscP5;
NetAddress myRemoteLocation;

// controlP5
ControlP5 cp5;
Accordion accordion;

// DMX
DmxP512 dmxOutput;
int universeSize = 128;
boolean DMXPRO = true;
String DMXPRO_PORT="/dev/cu.usbserial-ENXKFAGI";//case matters ! on windows port must be upper cased.
int DMXPRO_BAUDRATE = 115200;
int[] dmxValue;
int nOfDmxChannel = 6;

//midi bus
MidiBus midi;

PGraphics canvas;

System system;
boolean localHost = false;

//state
boolean controlling = false;


int c = color(0, 160, 100);

public void settings() {
  size(800, 400, P3D);
  PJOGL.profile=1;
}

public void setup() {
  MidiBus.list();
  // midi = new MidiBus(this, "from Max 1", -1);
  midi = new MidiBus(this, 0, -1);

  background(20);
  canvas = createGraphics(600, 400, P3D);
  system = new System();

  // oscP5
  oscP5 = new OscP5(this,3000);
  myRemoteLocation = new NetAddress("127.0.0.1", 7300);

  // DMX
  dmxOutput = new DmxP512(this, universeSize, false);
  // dmxOutput.setupDmxPro(DMXPRO_PORT, 115200);
  dmxValue = new int[nOfDmxChannel];
  for(int i = 0; i < nOfDmxChannel; i++) {
    dmxValue[i] = 0;
  }

  gui();
}

public void draw() {
  background(0);
  system.render();
  sendDmx();
}

public void keyPressed() {
  if (PApplet.parseInt(key) >= 49 && PApplet.parseInt(key) <= 54) {
    system.pianoTrigger(PApplet.parseInt(key) - 49, 300);
  }
  if (key == '7') {
    system.blink();
  }
  if (key == '8') {
    println("press");
  }
}


Toggle sw;
public void gui() {

  cp5 = new ControlP5(this);

  // group number 1, contains 2 bangs
  Group g1 = cp5.addGroup("dim/blink")
    .setBackgroundColor(color(0, 64))
    .setBackgroundHeight(200)
  ;

  int[][] pos = {
    {10, 20},
    {30, 20},
  };
  cp5.addBang("dim on")
    .setPosition(10,20)
    .setSize(20,20)
    .moveTo(g1)
    .setId(0)
  ;
  cp5.addBang("dim off")
    .setPosition(10,70)
    .setSize(20,20)
    .moveTo(g1)
    .setId(1)
  ;
  cp5.addBang("bang_2")
    .setPosition(10,120)
    .setSize(20,20)
    .moveTo(g1)
    .setId(2)
  ;
  cp5.addBang("bang_3")
    .setPosition(50,20)
    .setSize(20,20)
    .moveTo(g1)
    .setId(3)
  ;
  cp5.addBang("bang_4")
    .setPosition(50,70)
    .setSize(20,20)
    .moveTo(g1)
    .setId(4)
  ;
  cp5.addBang("bang_5")
    .setPosition(50,120)
    .setSize(20,20)
    .moveTo(g1)
    .setId(5)
  ;
  cp5.addBang("bang_6")
    .setPosition(90,20)
    .setSize(20,20)
    .moveTo(g1)
    .setId(6)
  ;
  cp5.addBang("bang_7")
    .setPosition(90,70)
    .setSize(20,20)
    .moveTo(g1)
    .setId(7)
  ;
  cp5.addBang("bang_8")
    .setPosition(90,120)
    .setSize(20,20)
    .moveTo(g1)
    .setId(8)
  ;

  // group number 2
  Group g2 = cp5.addGroup("modes")
    .setBackgroundColor(color(0, 64))
    .setBackgroundHeight(150)
  ;


  sw = cp5.addToggle("switch")
    .setPosition(10,20)
    .setSize(20,20)
    .moveTo(g2)
  ;
  cp5.addToggle("m1")
    .setPosition(10,55)
    .setSize(20,20)
    .moveTo(g2)
  ;
  cp5.addToggle("m2")
    .setPosition(35,55)
    .setSize(20,20)
    .moveTo(g2)
  ;
  cp5.addToggle("m3")
    .setPosition(60,55)
    .setSize(20,20)
    .moveTo(g2)
  ;

  // create a new accordion
  // add g1, g2, and g3 to the accordion.
  accordion = cp5.addAccordion("acc")
              .setPosition(40,40)
              .setWidth(200)
              .addItem(g1)
              .addItem(g2)
  ;

  accordion.open(0, 1);

  // use Accordion.MULTI to allow multiple group
  // to be open at a time.
  accordion.setCollapseMode(Accordion.MULTI);

  // when in SINGLE mode, only 1 accordion
  // group can be open at a time.
  // accordion.setCollapseMode(Accordion.SINGLE);
}

public void controlEvent(ControlEvent theEvent) {
  if (theEvent.isController()) {
    println(
      "## controlEvent / id:"+theEvent.controller().getId()+
      " / name:"+theEvent.controller().getName()+
      " / value:"+theEvent.controller().getValue()
    );
    if (theEvent.controller().getName() == "switch") {
      sendSwitchOSC(PApplet.parseInt(theEvent.controller().getValue()));
    }
    switch(theEvent.controller().getId()) {
      case (0):
        system.turnOn(5000);
        break;
      case (1):
        system.turnOff(300);
        break;
      case (2):
        system.dimRepeat(3, 500);
        break;
      case (3):
          system.triggerBlinkMode();
        break;
      case (4):
        system.triggerRandomMode();
        break;
      case (5):
        system.triggerSequenceMode(0, 200);
        break;
      case (6):
        system.triggerSequenceMode(1, 200);
        break;
      case (7):
        system.triggerSequenceMode(2, 200);
        break;
      case (8):
        system.triggerComplexSequenceMode(0);
        break;
    }
  }
}

public void sendSwitchOSC(int state) {
  String head = "/ls";
  OscMessage osc = new OscMessage(head);
  osc.add(state);
  oscP5.send(osc,  myRemoteLocation);
}

public void sendDmx() {
  for (int i = 0; i < nOfDmxChannel; i++) {
    dmxOutput.set(i, dmxValue[i]);
  }
}

//midi bus
int ch = 15;
public void noteOn(int channel, int pitch, int velocity) {
  println();
  println("Note On:");
  println("--------");
  println("Channel:"+channel);
  println("Pitch:"+pitch);
  println("Velocity:"+velocity);

  if (channel == ch) {
    switch(pitch) {
      case(65) :
        if (velocity == 0) {
          sendSwitchOSC(0);
          sw.setValue(0);
          controlling = false;
        } else {
          sendSwitchOSC(1);
          sw.setValue(1);
          controlling = true;
        }
        break;
      case(69) :
        system.triggerBlinkMode();
        break;
      case(70) :
        system.randomTriggerOne();
        break;
      case(71) :
        if (velocity != 0) {
          system.turnOn();
          system.turnOff(200);
        }
        break;
      case(72) :
        system.triggerComplexSequenceMode(1);
        break;
      case(73) :
        if (velocity != 0) {
          system.turnOneOn(1);
          system.turnOneOff(1, 200);
          system.turnOneOn(2);
          system.turnOneOff(2, 200);
          system.turnOneOn(3);
          system.turnOneOff(3, 200);
          system.turnOneOn(4);
          system.turnOneOff(4, 200);
        }
        break;
      case(74) :
        if (velocity != 0) {
          system.turnOneOn(0);
          system.turnOneOff(0, 200);
          system.turnOneOn(1);
          system.turnOneOff(1, 200);
          system.turnOneOn(4);
          system.turnOneOff(4, 200);
          system.turnOneOn(5);
          system.turnOneOff(5, 200);
        }
        break;
      case(75) :
        if (velocity != 0) {
          system.turnOff();
          system.turnOn(9000);
        }
        break;
      case(76) :
        if (velocity != 0) {
          system.turnOff();
          system.turnOn(4000);
        }
        break;
      case(81) :
        break;
      case(82) :
        break;
    }
  }
}
// void noteOn(int channel, int pitch, int velocity) {
//   println();
//   println("Note On:");
//   println("--------");
//   println("Chan$nel:"+channel);
//   println("Pitch:"+pitch);
//   println("Velocity:"+velocity);
//
//   if (channel == 14) {
//     switch(pitch) {
//       case(72) :
//         if (!controlling) {
//           sendSwitchOSC(1);
//           sw.setValue(1);
//         } else {
//           sendSwitchOSC(0);
//           sw.setValue(0);
//         }
//         controlling = !controlling;
//         break;
//       case(73) :
//         system.turnOn(300);
//         break;
//       case(74) :
//         system.turnOff(300);
//         break;
//       case(75) :
//         system.dimRepeat(3, 500);
//         break;
//       case(76) :
//         system.triggerBlinkMode();
//         break;
//       case(77) :
//         system.triggerRandomMode();
//         break;
//       case(78) :
//         system.triggerSequenceMode(0, 200);
//         break;
//       case(79) :
//         system.triggerSequenceMode(1, 200);
//         break;
//       case(80) :
//         system.triggerSequenceMode(2, 200);
//         break;
//       case(81) :
//         system.triggerComplexSequenceMode(1);
//         break;
//       case(82) :
//         break;
//     }
//   }
// }

public void oscEvent(OscMessage theOscMessage) {
  if(theOscMessage.checkAddrPattern("/lanterns")) {
    if(theOscMessage.checkTypetag("iiiiii")) {
      println("value from max:");
      for (int i = 0; i < nOfDmxChannel; i++) {
        int val = theOscMessage.get(i).intValue();
        print(i + ":" + val + "   ");
        dmxValue[i] = val;
      }
      println("");
    }
  }
}
int lightColor = color (239, 72, 54);

class Light {
  int id;
  int position; //0, 1, 2, 3
  float angle;
  float xpos;
  float ypos;
  float length = 300;
  float sz;

  TimeLine dimTimer;

  // state
  boolean repeatBreathing = false;

  // temperary
  boolean dimming = false;
  float alpha = 255;
  float targetAlpha;
  float initialAlpha;

  // blink function
  boolean blink = false;
  TimeLine turnOnTimer;
  int blinkLimit = 20;

  Light(int _id, float _a, float _x, float _y, float _sz) {
    id = _id;
    position = id % 4;
    angle = _a;
    xpos = _x;
    ypos = _y;
    sz = _sz;

    // Timers
    dimTimer = new TimeLine(300);
    turnOnTimer = new TimeLine(50);
  }

  public void update() {
    if (dimming) {
      float ratio = 0;
      if (repeatBreathing) {
        ratio = dimTimer.repeatBreathMovement();
      } else {
        ratio = dimTimer.liner();
      }

      alpha = initialAlpha +
      (targetAlpha - initialAlpha) * ratio;

      if (!dimTimer.state) {
        // alpha = targetAlpha;
        dimming = false;
        repeatBreathing = false;
      }
    } else if (blink) {
      if (turnOnTimer.liner() == 1) {
        turnOff(blinkLimit);
        blink = false;
      }
    }
  }

  public void render() {
    if (controlling) {
      sendOSC();
    }
    canvas.pushMatrix();
    canvas.translate(xpos, ypos);

    // canvas.noStroke();
    // canvas.fill(lightColor, alpha);
    canvas.stroke(lightColor, alpha);
    // canvas.ellipse(0, 0, sz, sz);

    if (position == 0) {
      canvas.line(1 * sz, 5 * sz, 2 * sz, 6 * sz);
      canvas.line(2 * sz, 6 * sz, 2 * sz, 7 * sz);
    } else if (position == 1) {
      canvas.line(0, 0, 0, 3 * sz);
      canvas.line(0, 3 * sz, 1 * sz, 4 * sz);
      canvas.line(1 * sz, 4 * sz, 1 * sz, 7 * sz);
    }  else if (position == 2) {
      canvas.line(-sz, 0, -sz, 3 * sz);
      canvas.line(-sz, 3 * sz, -2 * sz, 4 * sz);
      canvas.line(-2 * sz, 4 * sz, -2 * sz, 7 * sz);
    }  else if (position == 3) {
      canvas.line(-2 * sz, 5 * sz, -3 * sz, 6 * sz);
      canvas.line(-3 * sz, 6 * sz, -3 * sz, 7 * sz);
    }

    canvas.popMatrix();
  }

  public void turnOn() {
    repeatBreathing = false;
    dimming = false;
    alpha = 255;
    initialAlpha = 255;
    targetAlpha = 255;
  }

  public void turnOn(int time) {
    repeatBreathing = false;
    dimming = true;
    dimTimer.limit = time;
    dimTimer.startTimer();
    initialAlpha = alpha;
    targetAlpha = 255;
  }

  public void turnOff() {
    repeatBreathing = false;
    dimming = false;
    alpha = 0;
    initialAlpha = 0;
    targetAlpha = 0;
  }

  public void turnOff(int time) {
    repeatBreathing = false;
    dimming = true;
    dimTimer.limit = time;
    dimTimer.startTimer();
    initialAlpha = alpha;
    targetAlpha = 0;
  }

  public void turnOnFor(int dur) {
    turnOnFor(dur, 20);
  }

  public void turnOnFor(int dur, int time) {
    repeatBreathing = false;
    blink = true;
    blinkLimit = time;
    turnOnTimer.limit = dur;
    turnOnTimer.startTimer();
    turnOn(blinkLimit);
  }

  public void blink() {
    turnOnFor(20);
  }

  public void setLimit(int ll) {
    dimTimer.limit = ll;
  }

  // dim 3 times
  public void dimRepeat(int time, int ll) {
    alpha = 0;
    repeatBreathing = true;
    dimming = true;
    initialAlpha = 0;
    targetAlpha = 255;
    dimTimer.limit = ll;
    dimTimer.repeatTime = time;
    dimTimer.breathState = false;
    dimTimer.startTimer();
  }
  public void dimRepeatInverse(int time, int ll) {
    alpha = 255;
    repeatBreathing = true;
    dimming = true;
    initialAlpha = 255;
    targetAlpha = 0;
    dimTimer.limit = ll;
    dimTimer.repeatTime = time;
    dimTimer.breathState = false;
    dimTimer.startTimer();
  }

  // oscP5
  public void sendOSC() {
    String head = "/l" + str(id);
    OscMessage osc = new OscMessage(head);
    osc.add(alpha);
    oscP5.send(osc,  myRemoteLocation);
  }
}
/**
 * System
 * TODO
 * . blinking mode (in a period of time or blink specific time)
 * . pattern trigger
 * . piano mode (always enable)
 * . random mode
 * . multiple pattern
 *
 * ControlP5 panel
 * . first panel should be the mode radio
 * . there should be bang panel below radio
 */
class System {
  Light[] lights;
  // int nOfLights = 6;
  int nOfLights = 16;

  // Modes
  boolean[] modes = {
    false, // sequence mode
    false, // blink mode
    false, // random mode
    false, // complex pattern mode
  };

  System() {
    lights = new Light[nOfLights];
    int middle = 300;
    // int[] gap = {60, 140, 140};
    int[] gap = {60, 180};
    // lights[0] = new Light(0, 0, middle - gap[2], 50, 30);
    // lights[1] = new Light(1, 0, middle - gap[1], 20, 25);
    // lights[2] = new Light(2, 0, middle - gap[0], 00, 20);
    // lights[3] = new Light(3, 0, middle + gap[0], 00, 20);
    // lights[4] = new Light(4, 0, middle + gap[1], 20, 25);
    // lights[5] = new Light(5, 0, middle + gap[2], 50, 30);

    lights[0] = new Light(0, 0, middle - gap[1], 20, 25);
    lights[1] = new Light(1, 0, middle - gap[1], 20, 25);
    lights[2] = new Light(2, 0, middle - gap[1], 20, 25);
    lights[3] = new Light(3, 0, middle - gap[1], 20, 25);

    lights[4] = new Light(4, 0, middle - gap[0], 0, 20);
    lights[5] = new Light(5, 0, middle - gap[0], 0, 20);
    lights[6] = new Light(6, 0, middle - gap[0], 0, 20);
    lights[7] = new Light(7, 0, middle - gap[0], 0, 20);

    lights[8] = new Light(8, 0, middle + gap[0], 0, 20);
    lights[9] = new Light(9, 0, middle + gap[0], 0, 20);
    lights[10] = new Light(10, 0, middle + gap[0], 0, 20);
    lights[11] = new Light(11, 0, middle + gap[0], 0, 20);
    lights[12] = new Light(12, 0, middle + gap[1], 20, 25);
    lights[13] = new Light(13, 0, middle + gap[1], 20, 25);
    lights[14] = new Light(14, 0, middle + gap[1], 20, 25);
    lights[15] = new Light(15, 0, middle + gap[1], 20, 25);

  }

  public void render() {
    canvas.beginDraw();
    canvas.background(0);

    // modes
    if (modes[0]) { // sequence
      sequenceMode();
    }
    if (modes[1]) { // blink
      blinkMode();
    }
    if (modes[2]) {
      randomMode();
    }
    if (modes[3]) {
      complexSequenceMode();
    }

    for (int i = 0; i < nOfLights; i++) {
      lights[i].update();
      lights[i].render();
    }

    image(canvas, 200, 100);
    canvas.endDraw();
  }

  public void turnOn() {
    for (int i = 0; i < nOfLights; i++) {
      lights[i].turnOn();
    }
  }

  boolean randomTriggerOn = false;
  int randomTriggerIndex;
  public void randomTriggerOne() {
    if (!randomTriggerOn) {
      int temp;
      do {
        temp = floor(random(nOfLights));
      } while (temp == randomTriggerIndex);
      randomTriggerIndex = temp;
      turnOneOn(randomTriggerIndex);
    } else {
      turnOneOff(randomTriggerIndex);
    }
    randomTriggerOn = !randomTriggerOn;
  }

  public void turnOn(int time) {
    for (int i = 0; i < nOfLights; i++) {
      lights[i].turnOn(time);
    }
  }

  public void turnOneOn(int id) {
    lights[id].turnOn();
  }

  public void turnOneOn(int id, int time) {
    lights[id].turnOn(time);
  }

  public void turnOneOnFor(int id, int time, int dur) {
    lights[id].turnOnFor(time, dur);
  }

  public void turnOff() {
    for (int i = 0; i < nOfLights; i++) {
      lights[i].turnOff();
    }
  }

  public void turnOff(int time) {
    for (int i = 0; i < nOfLights; i++) {
      lights[i].turnOff(time);
    }
  }

  public void turnOneOff(int id) {
    lights[id].turnOff();
  }

  public void turnOneOff(int id, int time) {
    lights[id].turnOff(time);
  }

  public void dimRepeat(int time, int ll) {
    for (int i = 0; i < nOfLights; i++) {
      lights[i].dimRepeat(time, ll);
    }
  }

  public void blink() {
    for (int i = 0; i < nOfLights; i++) {
      lights[i].blink();
    }
  }

  public void blink(int id) {
    lights[id].blink();
  }


  /**
   * Performance
   */
  public void pianoTrigger(int id, int release) {
    turnOneOn(id);
    turnOneOff(id, release);
  }

  int sequenceTime = 100;
  int sequenceDur = 50;
  int sequenceIndex = 0;
  int sequenceCount = 0;
  int sequenceCountLimit = 5;
  int[][] sequenceSet = {
    { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15 },
    { 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0 },
    { 7, 8, 6, 9, 5, 10, 4, 11, 3, 12, 2, 13, 1, 14, 0, 15 },
    { 0, 1, 0, 1, 5, 4, 5, 4, 3, 2, 3, 2 },
  };
  int[] sequence;
  public void triggerSequenceMode(int index, int time) {
    turnOff();
    modes[0] = !modes[0];
    sequenceTime = time;
    sequence = sequenceSet[index%sequenceSet.length];
    sequenceIndex = 0;
    sequenceCount = 0;
  }
  public void sequenceMode() {
    sequenceCount++;
    if (sequenceCount > sequenceCountLimit) {
      turnOneOnFor(sequence[sequenceIndex], sequenceDur, sequenceTime);
      sequenceIndex = (sequenceIndex + 1) % sequence.length;
      sequenceCount = 0;
    }
  }

  int blinkCount = 0;
  int blinkCountLimit = 5;
  public void triggerBlinkMode() {
    modes[1] = !modes[1];
  }
  public void blinkMode() {
    blinkCount++;
    if (blinkCount > blinkCountLimit) {
      blink();
      blinkCount = 0;
    }
  }

  int randomCount = 0;
  int randomCountLimit = 5;
  int randomIndex = 0;
  int randomTime = 200;
  int randomDuration = 50;
  public void triggerRandomMode() {
    modes[2] = !modes[2];
  }
  public void randomMode() {
    randomCount++;
    if (randomCount > randomCountLimit) {
      randomIndex = floor(random(nOfLights));
      turnOneOnFor(randomIndex, randomDuration, randomTime);
      randomCount = 0;
    }
  }

  int complexSequenceTime = 10;
  int complexSequenceDur = 50;
  int complexSequenceIndex = 0;
  int complexSequenceCount = 0;
  int complexSequenceCountLimit = 10;
  int[][][] complexSequenceSet = {
    {
      {0, 1, 2, 3},
      {12, 13, 14, 15},
      {4, 5, 6, 7, 8, 9, 10, 11},
    },
    {
      {2, 3},
      {1, 4},
      {0, 5},
    },
  };
  int[][] complexSequence;
  public void triggerComplexSequenceMode(int index) {
    modes[3] = !modes[3];
    complexSequence = complexSequenceSet[index%complexSequenceSet.length];
    complexSequenceIndex = 0;
    complexSequenceCount = 0;
  }
  public void complexSequenceMode() {
    complexSequenceCount++;
    if (complexSequenceCount > complexSequenceCountLimit) {
      for (int i = 0, n = complexSequence[complexSequenceIndex].length; i < n; i++) {
        turnOneOnFor(complexSequence[complexSequenceIndex][i], complexSequenceDur, complexSequenceTime);
      }
      complexSequenceIndex = (complexSequenceIndex + 1) % complexSequence.length;
      complexSequenceCount = 0;
    }
  }
}
class TimeLine {
  boolean state;
  int localtime;
  int limit;
  int elapsedTime;
  int repeatTime = 1;
  boolean breathState = false;
  boolean loop = false;

  float linerRate = 1;

  TimeLine(int sec) {
    limit=sec;
    state=false;
  }

  TimeLine(int sec, boolean _loop) {
    limit = sec;
    loop = _loop;
    state = _loop;
  }
  public void update() {
    if (state == true) {
      elapsedTime = currentTime() - localtime;

      if (elapsedTime>PApplet.parseInt(limit)) {
        if( !loop ) {
          elapsedTime = PApplet.parseInt(limit);
          state=false;
        }
        else {
          startTimer();
        }
      }
    }
  }

  public float liner() {
    update();
    float t = PApplet.parseFloat(elapsedTime)/limit;
    float ret = pow(t, linerRate);
    return min(1, ret);
  }
  public float getPowIn(float pow) {
    update();
    float t = PApplet.parseFloat(elapsedTime)/limit;
    float ret = pow(t, pow);
    return min(1, ret);
  }
  public float getPowOut(float pow) {
    update();
    float t = PApplet.parseFloat(elapsedTime)/limit;
    float ret = 1 - pow(1 - t, pow);
    return min(1, ret);
  }
  public float getPowInOut(float pow) {
    update();
    float t = PApplet.parseFloat(elapsedTime)/limit;
    float ret;
    if ((t*=2)<1) {
      ret = 0.5f * pow(t, pow);
    }
    else {
      ret = 1 - 0.5f * abs(pow(2-t, pow));
    }

    return min(1, ret);
  }
  public float sineIn() {
    update();
    float t = PApplet.parseFloat(elapsedTime)/limit;
    return min(1, 1 - cos(t * PI / 2));
  }
  public float sineOut() {
    update();
    float t = PApplet.parseFloat(elapsedTime)/limit;
    return min(1, sin(t * PI / 2));
  }
  public float sineInOut() {
    update();
    float t = PApplet.parseFloat(elapsedTime)/limit;
    return min(1, 0.5f*(1 - cos(PI*t)));
  }
  public float getBackIn(float amount) {
    update();
    float t = PApplet.parseFloat(elapsedTime)/limit;
    return t*t*((amount+1)*t-amount);
  }
  public float getBackOut(float amount) {
    update();
    float t = PApplet.parseFloat(elapsedTime)/limit;
    return (--t*t*((amount+1)*t + amount) + 1);
  }
  public float getBackInOut(float amount) {
    update();
    float t = PApplet.parseFloat(elapsedTime)/limit;
    if ((t*=2)<1) {
      return 0.5f*(t*t*((amount+1)*t-amount));
    }
    else {
      return 0.5f*((t-=2)*t*((amount+1)*t+amount)+2);
    }
  }
  public float circIn() {
    update();
    float t = PApplet.parseFloat(elapsedTime)/limit;
    return (1 - sqrt(1-t*t));
  }
  public float circOut() {
    update();
    float t = PApplet.parseFloat(elapsedTime)/limit;
    return sqrt(1-(--t)*t);
  }
  public float circInOut() {
    update();
    float t = PApplet.parseFloat(elapsedTime)/limit;
    if ((t*=2) < 1) {
      return -0.5f*(sqrt(1-t*t)-1);
    }
    else {
      return 0.5f*(sqrt(1-(t-=2)*t)+1);
    }
  }
  public float bounceIn() {
    update();
    float t = PApplet.parseFloat(elapsedTime)/limit;
    return 1 - bo(1-t);
  }
  public float bounceOut() {
    update();
    float t = PApplet.parseFloat(elapsedTime)/limit;
    return bo(t);
  }
  public float bounceInOut() {
    update();
    float t = PApplet.parseFloat(elapsedTime)/limit;
    if (t<0.5f) {
      return (1-bo(1-t*2))*0.5f;
    }
    else {
      return bo(t*2-1)*0.5f+0.5f;
    }
  }
  public float bo(float t) {
    if (t < 1/2.75f) {
			return (7.5625f*t*t);
		} else if (t < 2/2.75f) {
			return (7.5625f*(t-=1.5f/2.75f)*t+0.75f);
		} else if (t < 2.5f/2.75f) {
			return (7.5625f*(t-=2.25f/2.75f)*t+0.9375f);
		} else {
			return (7.5625f*(t-=2.625f/2.75f)*t +0.984375f);
		}
  }
  public float elasticIn() {
    update();
    float t = PApplet.parseFloat(elapsedTime)/limit;
    float b = 0;
    float c = 1;
    float d = 1;
    if (t == 0)
      return b;
    if ((t /= d) == 1)
      return b + c;
    float p = d * .3f;
    float a = c;
    float s = p / 4;
    return -(a * (float) Math.pow(2, 10 * (t -= 1)) * (float) Math.sin((t * d - s) * (2 * (float) Math.PI) / p)) + b;
  }
  public float elasticOut() {
    update();
    float t = PApplet.parseFloat(elapsedTime)/limit;
    float b = 0;
    float c = 1;
    float d = 1;
    if (t == 0)
      return b;
    if ((t /= d) == 1)
      return b + c;
    float p = d * .3f;
    float a = c;
    float s = p / 4;
    return (a * (float) Math.pow(2, -10 * t) * (float) Math.sin((t * d - s) * (2 * (float) Math.PI) / p) + c + b);
  }
  public float elasticInOut() {
    update();
    float t = PApplet.parseFloat(elapsedTime)/limit;
    float b = 0;
    float c = 1;
    float d = 1;
    if (t == 0)
      return b;
    if ((t /= d / 2) == 2)
      return b + c;
    float p = d * (.3f * 1.5f);
    float a = c;
    float s = p / 4;
    if (t < 1)
      return -.5f * (a * (float) Math.pow(2, 10 * (t -= 1)) * (float) Math.sin((t * d - s) * (2 * (float) Math.PI) / p)) + b;
    return a * (float) Math.pow(2, -10 * (t -= 1)) * (float) Math.sin((t * d - s) * (2 * (float) Math.PI) / p) * .5f + c + b;
  }

  // float getElasticIn(float amp, float period) {
  //   update();
  //   float t = float(elapsedTime)/limit;
  //   if (t==0 || t==1) {
  //     return t;
  //   }
  //   float s = period/(PI*2*asin(1/amp));
  //   return -(amp*pow(2,10*(t-=1))*sin((t-s)*PI*2/period));
  // }
  // float getElasticOut(float amp, float period) {
  //   update();
  //   float t = float(elapsedTime)/limit;
  //   if (t==0 || t==1) {
  //     return t;
  //   }
  //   float s = period/(PI*2*asin(1/amp));
  //   return (amp*pow(2,-10*t)*sin((t-s)*PI*2/period )+1);
  // }
  // float getElasticInOut(float amp, float period) {
  //   update();
  //   float t = float(elapsedTime)/limit;
  //   if (t==0 || t==1) {
  //     return t;
  //   }
  //   float s = period/(PI*2*asin(1/amp));
	// 	if ((t*=2)<1) return -0.5*(amp*pow(2,10*(t-=1))*sin( (t-s)*PI*2/period ));
	// 	return amp*pow(2,-10*(t-=1))*sin((t-s)*PI*2/period)*0.5+1;
  // }

  public float repeatBreathMovement() {
    if (state == true) {
      //println("check!!!!");
      elapsedTime = currentTime() - localtime;
      if (elapsedTime>PApplet.parseInt(limit)) {
        elapsedTime = PApplet.parseInt(limit);
        if(repeatTime < 2 && breathState) {
          state = false; }
        else {
          if(breathState == true) {
            repeatTime-- ;
          }
          breathState = !breathState;
          startTimer();
        }
      }
    }

    float t = PApplet.parseFloat(elapsedTime)/limit;
    if(!breathState) {
      return pow(t, linerRate); }
    else {
      return pow((1-t), linerRate); }
  }
  public float repeatBreathMovementEndless() {
    if (state == true) {
      //println("check!!!!");
      elapsedTime = currentTime() - localtime;
      if (elapsedTime>PApplet.parseInt(limit)) {
        elapsedTime = PApplet.parseInt(limit);
        if(repeatTime < 1 && breathState) {
          state = false; }
        else {
          breathState = !breathState;
          startTimer();
        }
      }
    }

    float t = PApplet.parseFloat(elapsedTime)/limit;
    if(!breathState) {
      return pow(t, linerRate); }
    else {
      return pow((1-t), linerRate); }
  }
  public void setLinerRate(float r) { linerRate = r; }
  public void setRepeatTime(int t) { repeatTime = t; }
  public boolean startTimer() {
    if (state == true) {
      localtime = currentTime();
      elapsedTime = 0;
      return false;
    }
    else {
      localtime = currentTime();
      state=true;
      elapsedTime = 0;
      return true;
    }
  }
  public void turnOffTimer() {
    localtime = currentTime() - limit;
    state = false;
  }

  public int currentTime() {
    return millis();
  }
  public void setLoop() { loop = true; }
  public void set1() { elapsedTime = limit; }
  public void set0() { elapsedTime = 0; }
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Cells" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
