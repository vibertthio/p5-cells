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
  // int nOfLights = 16;
  int nOfLights = 17;

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

    lights[16] = new Light(16, 0, middle, 0, 25);

  }

  void render() {
    canvas.beginDraw();
    canvas.background(0);

    updateSequence();
    updateComplexSequence();
    updateAsyncSequence();
    updateComplexAsyncSequence();

    // modes
    if (modes[1]) { // blink
      blinkMode();
    }
    if (modes[2]) {
      randomMode();
    }

    for (int i = 0; i < nOfLights; i++) {
      lights[i].update();
      lights[i].render();
    }

    image(canvas, 200, 100);
    canvas.endDraw();
  }

  void turnOn() {
    for (int i = 0; i < nOfLights; i++) {
      lights[i].turnOn();
    }
  }

  boolean randomTriggerOn = false;
  int randomTriggerIndex;
  void randomTriggerOne() {
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

  void turnOn(int time) {
    for (int i = 0; i < nOfLights; i++) {
      lights[i].turnOn(time);
    }
  }

  void turnOneOn(int id) {
    lights[id].turnOn();
  }

  void turnOneOn(int id, int time) {
    lights[id].turnOn(time);
  }

  void turnOneOnFor(int id, int time, int dur) {
    lights[id].turnOnFor(time, dur);
  }

  void turnOff() {
    for (int i = 0; i < nOfLights; i++) {
      lights[i].turnOff();
    }
  }

  void turnOff(int time) {
    for (int i = 0; i < nOfLights; i++) {
      lights[i].turnOff(time);
    }
  }

  void turnOneOff(int id) {
    lights[id].turnOff();
  }

  void turnOneOff(int id, int time) {
    lights[id].turnOff(time);
  }

  void dimRepeat(int time, int ll) {
    for (int i = 0; i < nOfLights; i++) {
      lights[i].dimRepeat(time, ll);
    }
  }

  void blink() {
    for (int i = 0; i < nOfLights; i++) {
      lights[i].blink();
    }
  }

  void blink(int id) {
    lights[id].blink();
  }

  void turnRandOneOnFor(int time, int ll) {
    turnOneOnFor(int(random(nOfLights)),time, ll);
  }

  /**
   * Performance
   */
  void pianoTrigger(int id, int release) {
    turnOneOn(id);
    turnOneOff(id, release);
  }

  boolean turnSequenceActivate = false;
  int sequenceTriggerIndex = 0;
  boolean bangSequence = false;
  int turnSequenceTime = 100;
  int turnSequenceDur = 50;
  int turnSequenceIndex = 0;
  int turnSequenceCount = 0;
  int turnSequenceCountLimit = 5;
  int[][] sequenceSet = {
    { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15 },
    { 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0 },
    { 7, 8, 6, 9, 5, 10, 4, 11, 3, 12, 2, 13, 1, 14, 0, 15 },
    { 0, 1, 0, 1, 5, 4, 5, 4, 3, 2, 3, 2 },
    { 0, 11, 4, 8 },
    { 9, 2, 1, 10 }, // 5
    { 0, 4, 8, 1, 5, 9 },
    { 10, 6, 2, 11, 7, 3 },
    { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11 },
    { 8, 9, 10, 11, 4, 5, 6, 7, 0, 1, 2, 3 },
    { 0, 1, 2, 3}, // 10
    { 3, 2, 1, 0},
    { 0, 3, 2, 1},
    { 0, 2, 1, 3},
    { 4, 5, 6, 7},
    { 7, 6, 5, 4}, // 15
    { 4, 7, 5, 6},
    { 7, 5, 6, 4},
    { 8, 9, 10, 11},
    { 11, 10, 9, 8},
    { 8, 11, 10, 9}, // 20
    { 8, 10, 9, 11},
    { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11},
    { 11, 10, 9, 8, 3, 2, 1, 0 },
    { 0, 1, 2, 3, 8, 9, 10, 11 },
    { 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ,0}, // 25
    { 0, 7, 8, 3, 4, 11},
    { 11, 4, 3, 8, 7, 0},
    { 0, 1, 2, 3, 7, 6, 5, 4, 8, 9, 10, 11,
      10, 9, 8, 4, 5, 6, 7, 3, 2, 1, 0 },
    { 3, 2, 1, 0, 4, 5, 6, 7, 11, 10, 9, 8,
      9, 10, 11, 7, 6, 5, 4, 0, 1, 2, 3 },
    { 0, 0, 0, 0}, // 30 // this one if for random sequence, don't modify it
  };
  int[] sequence;

  void triggerSequence() {
    triggerSequence(sequenceTriggerIndex);
    // turnSequenceActivate = !turnSequenceActivate;
    // turnSequenceCount = 0;
  }
  void triggerSequence(int index) {
    turnOff();
    // turnSequenceActivate = true;
    if (index == sequenceTriggerIndex) {
      turnSequenceActivate = !turnSequenceActivate;
    } else {
      turnSequenceActivate = true;
    }

    sequenceTriggerIndex = index;
    sequence = sequenceSet[index%sequenceSet.length];
    turnSequenceIndex = 0;
    turnSequenceCount = 0;
  }
  void triggerSequence(int index, int time) {
    triggerSequence(index);
    turnSequenceTime = time;
  }
  void bangSequence(int index) {
    triggerSequence(index);
    bangSequence = true;
  }
  void bangSequence(int index, int time) {
    triggerSequence(index, time);
    bangSequence = true;
  }
  void updateSequence() {
    if (turnSequenceActivate) {
      turnSequenceCount++;
      if (turnSequenceCount > turnSequenceCountLimit) {
        // int prev = (turnSequenceIndex > 0)? (turnSequenceIndex - 1) : (sequence.length - 1);
        // turnOneOn(sequence[turnSequenceIndex], turnSequenceTime);
        // turnOneOff(sequence[prev], turnSequenceTime);
        turnOneOnFor(sequence[turnSequenceIndex], turnSequenceDur, turnSequenceTime);
        turnSequenceIndex = (turnSequenceIndex + 1) % sequence.length;
        turnSequenceCount = 0;

        if (bangSequence && turnSequenceIndex == 0) {
          triggerSequence();
          bangSequence = false;
        }
      }
    }
  }


  boolean complexSequenceActivate = false;
  int complexSequenceTriggerIndex = 0;
  boolean bangComplexSequence = false;
  int complexSequenceTime = 600;
  int complexSequenceDur = 200;
  int complexSequenceIndex = 0;
  int complexSequenceCount = 0;
  int complexSequenceCountLimit = 5;
  int[][][] complexSequenceSet = {
    {
      {0, 1, 2, 3},
      {4, 5, 6, 7},
      {8, 9, 10, 11},
      {12, 13, 14, 15},
    },
    {
      {12, 13, 14, 15},
      {8, 9, 10, 11},
      {4, 5, 6, 7},
      {0, 1, 2, 3},
    },
    {
      {0, 4, 8, 12},
      {1, 5, 9, 13},
      {2, 6, 10, 14},
      {3, 7, 11, 15},
    },
    {
      {3, 7, 11, 15},
      {2, 6, 10, 14},
      {1, 5, 9, 13},
      {0, 4, 8, 12},
    },
    {
      {3, 7, 11, 15},
      {2, 6, 10, 14},
      {1, 5, 9, 13},
      {0, 4, 8, 12},
    },
    {
      {7, 8},
      {6, 9},
      {5, 10},
      {4, 11},
      {3, 12},
      {2, 13},
      {1, 14},
      {0, 15},
    },
  };
  int[][] complexSequence;
  void triggerComplexSequence() {
    triggerComplexSequence(complexSequenceTriggerIndex);
    // complexSequenceActivate = !complexSequenceActivate;
    // complexSequenceCount = 0;
  }
  void triggerComplexSequence(int index) {
    if (index == complexSequenceTriggerIndex) {
      complexSequenceActivate = !complexSequenceActivate;
    } else {
      complexSequenceActivate = true;
    }

    complexSequenceTriggerIndex = index;
    complexSequence = complexSequenceSet[index%complexSequenceSet.length];
    complexSequenceIndex = 0;
    complexSequenceCount = 0;
  }
  void triggerComplexSequence(int index, int time) {
    triggerComplexSequence(index);
    complexSequenceTime = time;
  }
  void bangComplexSequence(int index) {
    triggerComplexSequence(index);
    bangComplexSequence = true;
  }
  void updateComplexSequence() {
    if (complexSequenceActivate) {
      complexSequenceCount++;
      if (complexSequenceCount > complexSequenceCountLimit) {
        for (int i = 0, n = complexSequence[complexSequenceIndex].length; i < n; i++) {
          turnOneOnFor(complexSequence[complexSequenceIndex][i], complexSequenceDur, complexSequenceTime);
        }
        complexSequenceIndex = (complexSequenceIndex + 1) % complexSequence.length;
        complexSequenceCount = 0;

        if (bangComplexSequence && complexSequenceIndex == 0) {
          triggerComplexSequence();
          bangComplexSequence = false;
        }
      }
    }
  }

  // asynce sequence （同個數字要被cue到兩次才會開關。 一次亮暗一條）
  boolean asyncSequenceActivate = false;
  int asyncSequenceTriggerIndex = 0;
  boolean bangAsyncSequence = false;
  int asyncSequenceTime = 50;
  int asyncSequenceIndex = 0;
  int asyncSequenceCount = 0;
  int asyncSequenceCountLimit = 2;
  int[][] asyncSequenceSet = {
    { 0, 1, 2, 3, 3, 2, 1, 0 },     //0
    { 4, 5, 6, 7, 7, 6, 5, 4 },
    { 8, 9, 10, 11, 11, 10, 9, 8 },
    { 12, 13, 14, 15, 15, 14, 13, 12 },

    { 3, 2, 1, 0, 0, 1, 2, 3 },
    { 7, 6, 5, 4, 4, 5, 6, 7 },
    { 11, 10, 9, 8, 8, 9, 10, 11 },  //5

    { 0, 1, 2, 3, 7, 6, 5, 4, 8, 9, 10, 11,
      11, 10, 9, 8, 4, 5, 6, 7, 3, 2, 1, 0 },  //6
    { 3, 2, 1, 0, 4, 5, 6, 7, 11, 10, 9, 8,
      8, 9, 10, 11, 7, 6, 5, 4, 0, 1, 2, 3 },  //7
    {
      0, 1, 2, 3,
    },
  };
  boolean[] asyncRecord = {
    false, false, false, false,
    false, false, false, false,
    false, false, false, false,
    false, false, false, false,
    false, false, false, false,
  };
  int[] asyncSequence;

  void triggerAsyncSequence() {
    triggerAsyncSequence(asyncSequenceTriggerIndex);
    // asyncSequenceActivate = !asyncSequenceActivate;
    // asyncSequenceCount = 0;
  }
  void triggerAsyncSequence(int index) {
    for (int i = 0, n = nOfLights; i < n; i++) {
      asyncRecord[i] = false;
    }
    turnOff();
    if (index == asyncSequenceTriggerIndex) {
      asyncSequenceActivate = !asyncSequenceActivate;
    } else {
      asyncSequenceActivate = true;
    }

    asyncSequenceTriggerIndex = index;
    asyncSequence = asyncSequenceSet[index%asyncSequenceSet.length];
    asyncSequenceIndex = 0;
    asyncSequenceCount = 0;
  }
  void bangAsyncSequence(int index) {
    triggerAsyncSequence(index);
    bangAsyncSequence = true;
  }
  void updateAsyncSequence() {
    if (asyncSequenceActivate) {
      asyncSequenceCount++;
      if (asyncSequenceCount > asyncSequenceCountLimit) {

        if (asyncRecord[asyncSequence[asyncSequenceIndex]]) {
          turnOneOff(asyncSequence[asyncSequenceIndex], asyncSequenceTime);
        } else {
          turnOneOn(asyncSequence[asyncSequenceIndex], asyncSequenceTime);
        }
        asyncRecord[asyncSequence[asyncSequenceIndex]] = !asyncRecord[asyncSequence[asyncSequenceIndex]];
        asyncSequenceIndex = (asyncSequenceIndex + 1) % asyncSequence.length;
        asyncSequenceCount = 0;

        if (bangAsyncSequence && asyncSequenceIndex == 0) {
          triggerAsyncSequence();
          bangAsyncSequence = false;
        }
      }
    }
  }

  // complex async sequence （一次亮暗好幾條）
  boolean complexAsyncSequenceActivate = false;
  int complexAsyncSequenceTriggerIndex = 0;
  boolean bangComplexAsyncSequence = false;
  int complexAsyncSequenceTime = 60;
  int complexAsyncSequenceIndex = 0;
  int complexAsyncSequenceCount = 0;
  int complexAsyncSequenceCountLimit = 2;
  int[][][] complexAsyncSequenceSet = {
    {
      { 0, 4, 8, 12 },
      { 1, 5, 9, 13 },
      { 2, 6, 10, 14 },
      { 3, 7, 11, 15 },
      { 3, 7, 11, 15 },
      { 2, 6, 10, 14 },
      { 1, 5, 9, 13 },
      { 0, 4, 8, 12 },
    },
    {
      { 3, 7, 11, 15 },
      { 2, 6, 10, 14 },
      { 1, 5, 9, 13 },
      { 0, 4, 8, 12 },
      { 0, 4, 8, 12 },
      { 1, 5, 9, 13 },
      { 2, 6, 10, 14 },
      { 3, 7, 11, 15 },
    },
    {
      {7, 8},
      {6, 9},
      {5, 10},
      {4, 11},
      {3, 12},
      {2, 13},
      {1, 14},
      {0, 15},
      {7, 8},
      {6, 9},
      {5, 10},
      {4, 11},
      {3, 12},
      {2, 13},
      {1, 14},
      {0, 15},
      // { 0, 1, 2, 3, 4, 5, 6, 7,
      //   8, 9, 10, 11, 12, 13, 14, 15 },
    },
  };
  boolean[] complexAsyncRecord = {
    false, false, false, false,
    false, false, false, false,
    false, false, false, false,
    false, false, false, false,
    false, false, false, false,
  };
  int[][] complexAsyncSequence;

  void triggerComplexAsyncSequence() {
    triggerComplexAsyncSequence(complexAsyncSequenceTriggerIndex);
    // complexAsyncSequenceActivate = !complexAsyncSequenceActivate;
    // complexAsyncSequenceCount = 0;
  }
  void triggerComplexAsyncSequence(int index) {
    for (int i = 0, n = nOfLights; i < n; i++) {
      complexAsyncRecord[i] = false;
    }
    turnOff();
    if (index == complexAsyncSequenceTriggerIndex) {
      complexAsyncSequenceActivate = !complexAsyncSequenceActivate;
    } else {
      complexAsyncSequenceActivate = true;
    }

    complexAsyncSequenceTriggerIndex = index;
    complexAsyncSequence = complexAsyncSequenceSet[index%complexAsyncSequenceSet.length];
    complexAsyncSequenceIndex = 0;
    complexAsyncSequenceCount = 0;
  }
  void bangComplexAsyncSequence(int index) {
    if (bangComplexAsyncSequence) {
      triggerComplexAsyncSequence(index);
    }
    triggerComplexAsyncSequence(index);
    bangComplexAsyncSequence = true;
  }
  void updateComplexAsyncSequence() {
    if (complexAsyncSequenceActivate) {
      complexAsyncSequenceCount++;
      if (complexAsyncSequenceCount > complexAsyncSequenceCountLimit) {

        int[] cas = complexAsyncSequence[complexAsyncSequenceIndex];
        for (int i = 0, n = cas.length; i < n; i++) {
          if (complexAsyncRecord[cas[i]]) {
            turnOneOff(cas[i], complexAsyncSequenceTime);
          } else {
            turnOneOn(cas[i], complexAsyncSequenceTime);
          }
          complexAsyncRecord[cas[i]] = !complexAsyncRecord[cas[i]];
        }
        complexAsyncSequenceIndex = (complexAsyncSequenceIndex + 1) % complexAsyncSequence.length;
        complexAsyncSequenceCount = 0;

        if (bangComplexAsyncSequence && complexAsyncSequenceIndex == 0) {
          triggerComplexAsyncSequence();
          bangComplexAsyncSequence = false;
        }
      }
    }
  }


  /**
   * Others
   */
  int blinkCount = 0;
  int blinkCountLimit = 5;
  void triggerBlinkMode() {
    modes[1] = !modes[1];
  }
  void blinkMode() {
    blinkCount++;
    if (blinkCount > blinkCountLimit) {
      blink();
      blinkCount = 0;
    }
  }

  int randomCount = 0;
  int randomCountLimit = 15;
  int randomIndex = 0;
  int randomTime = 400;
  int randomDuration = 200;
  void triggerRandomMode() {
    modes[2] = !modes[2];
  }
  void randomMode() {
    randomCount++;
    if (randomCount > randomCountLimit) {
      randomIndex = floor(random(nOfLights));
      turnOneOnFor(randomIndex, randomDuration, randomTime);
      randomIndex = floor(random(nOfLights));
      turnOneOnFor(randomIndex, randomDuration, randomTime);
      randomCount = 0;
    }
  }

}
