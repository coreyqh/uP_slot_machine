#ifndef MAIN_H_INCLUDED
#define MAIN_H_INCLUDED

#include <stm32l432xx.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
//#include "STM32L432KC.h"

#define COIN_PIN   PA10
#define BUTTON_PIN PA8
#define DONE_PIN   PA9

#define BR   1
#define CPOL 0
#define CPHA 0

#define LEMON_VALUE  2
#define CHERRY_VALUE 3
#define BELL_VALUE   5
#define BAR_VALUE    1 /* per bar (up to 9x total)*/
#define SEVEN_VALUE  10

#define LEMON_IDX  0
#define CHERRY_IDX 1
#define BELL_IDX   2
#define BAR_IDX    3
#define TPLBAR_IDX 4
#define SEVEN_IDX  5
#define WILD_IDX   6

#define REQ_SPIN    1
#define REQ_WIN     2
#define REQ_UPDATE  3

// winnings for simple 3 in a row line                          3 single bars 3 triple bars              all wild = max win
const uint8_t winvals[] = {LEMON_VALUE, CHERRY_VALUE, BELL_VALUE, 3*BAR_VALUE, 9*BAR_VALUE, SEVEN_VALUE, SEVEN_VALUE};

// const uint8_t reel1_seq[] = {LEMON_IDX, CHERRY_IDX, BELL_IDX,   BAR_IDX,    TPLBAR_IDX, SEVEN_IDX,  WILD_IDX  };
// const uint8_t reel2_seq[] = {BELL_IDX,  SEVEN_IDX,  LEMON_IDX,  WILD_IDX,   BAR_IDX,    CHERRY_IDX, TPLBAR_IDX};
// const uint8_t reel3_seq[] = {SEVEN_IDX, BAR_IDX,    CHERRY_IDX, TPLBAR_IDX, BELL_IDX,   LEMON_IDX,  WILD_IDX  };

uint16_t binToBCD3(uint16_t binary_val);
uint8_t  random0to6();
uint16_t calcWinnings(uint8_t reel1, uint8_t reel2, uint8_t reel3);

#endif 