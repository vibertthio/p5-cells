import controlP5.*;
import oscP5.*;
import netP5.*;
import themidibus.*;

import dmxP512.*;
import processing.serial.*;

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


color c = color(0, 160, 100);

void settings() {
  size(800, 400, P3D);
  PJOGL.profile=1;
}

void setup() {
  MidiBus.list();
  midi = new MidiBus(this, "from Max 1", -1);
  // midi = new MidiBus(this, 0, -1);

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

void draw() {
  background(0);
  system.render();
  // DMX output is used in last project, not this one
  // sendDmx();
}

void keyPressed() {
  if (int(key) >= 49 && int(key) <= 54) {
    system.pianoTrigger(int(key) - 49, 300);
  }
  if (key == '7') {
    system.blink();
  }
  if (key == ' ') {
    system.turnRandOneOnFor(50, 20);
    system.turnRandOneOnFor(50, 20);
  }
  if (key == 'z') {
    system.bangComplexAsyncSequence(2);
  }
  if (key == 'x') {
    // system.bangComplexSequence(5);
    system.triggerComplexSequence(5, 100);
  }
  if (key == 'q') {
    // system.bangComplexSequence(5);
    system.bangAsyncSequence(0);
  }
  if (key == 'w') {
    // system.bangComplexSequence(5);
    system.bangAsyncSequence(1);
  }
  if (key == 'e') {
    // system.bangComplexSequence(5);
    system.bangAsyncSequence(2);
  }
  if (key == 'r') {
    // system.bangComplexSequence(5);
    system.bangAsyncSequence(3);
  }
}


Toggle sw;
void gui() {

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
      sendSwitchOSC(int(theEvent.controller().getValue()));
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
        // system.triggerSequence(0, 100);
        system.triggerSequence(0, 200);
        break;
      case (6):
        system.triggerSequence(1, 100);
        // system.triggerSequence(1, 200);
        break;
      case (7):
        system.triggerSequence(2, 100);
        // system.triggerSequence(2, 200);
        break;
      case (8):
        // system.triggerComplexSequence(0);
        // system.triggerAsyncSequence(0);
        system.bangComplexAsyncSequence(2);
        break;
    }
  }
}

void sendSwitchOSC(int state) {
  String head = "/ls";
  OscMessage osc = new OscMessage(head);
  osc.add(state);
  oscP5.send(osc,  myRemoteLocation);
}

void sendDmx() {
  for (int i = 0; i < nOfDmxChannel; i++) {
    dmxOutput.set(i, dmxValue[i]);
  }
}

int triggerOn = 0;

//midi bus
int ch = 15;
void noteOn(int channel, int pitch, int velocity) {
  println();
  println("Note On:");
  println("--------");
  println("Channel:"+channel);
  println("Pitch:"+pitch);
  println("Velocity:"+velocity);

  if (channel == ch) {
    switch(pitch) {
      case(97) :
        if (velocity == 127) {
          if (triggerOn == 0) {
            system.triggerRandomMode();
            triggerOn = 1;
          }
        } else if (velocity == 0) {
          if (triggerOn == 1) {
            system.triggerRandomMode();
            triggerOn = 0;
          } else if (triggerOn == 2) {
            system.triggerSequence();
            triggerOn = 0;
          } else if (triggerOn == 3) {
            system.triggerComplexSequence(5, 100);
            triggerOn = 0;
          }
        }
        break;
      case(98) :
        if (velocity == 127) {
          if (triggerOn == 0) {
            system.triggerSequence(0, 200);
            triggerOn = 2;
          }
        } else if (velocity == 0) {
          if (triggerOn == 1) {
            system.triggerRandomMode();
            triggerOn = 0;
          } else if (triggerOn == 2) {
            system.triggerSequence();
            triggerOn = 0;
          } else if (triggerOn == 3) {
            system.triggerComplexSequence(5, 100);
            triggerOn = 0;
          }
        }
        break;
      case(99) :
        if (velocity == 127) {
          if (triggerOn == 0) {
            system.triggerComplexSequence(5, 100);
            triggerOn = 3;
          }
        } else if (velocity == 0) {
          if (triggerOn == 1) {
            system.triggerRandomMode();
            triggerOn = 0;
          } else if (triggerOn == 2) {
            system.triggerSequence();
            triggerOn = 0;
          } else if (triggerOn == 3) {
            system.triggerComplexSequence(5, 100);
            triggerOn = 0;
          }
        }
        break;


      case(100) :
        if (velocity == 127) {
          system.bangComplexAsyncSequence(2);
        }
        break;
      case(105) :
        if (velocity == 127) {
          system.turnRandOneOnFor(50, 20);
          system.turnRandOneOnFor(50, 20);
        }
        break;
      case(106) :
        if (velocity == 127) {
          system.turnRandOneOnFor(50, 20);
          system.turnRandOneOnFor(50, 20);
        }
        break;
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
        system.triggerComplexSequence(1);
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

void oscEvent(OscMessage theOscMessage) {
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
