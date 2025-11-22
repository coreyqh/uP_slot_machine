#ifndef MAIN_H_INCLUDED
#define MAIN_H_INCLUDED

#include "STM32L432KC.h"
#include <stm32l432xx.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#define COIN_PIN PA8
#define BUTTON_PIN PA10

#define BR   /* TODO */
#define CPOL /* TODO */
#define CPHA /* TODO */

#define LEMON_VALUE  2
#define CHERRY_VALUE 3
#define BELL_VALUE   5
#define BAR_VALUE    1 /* per bar (up to 9x total)*/
#define SEVEN_VALUE  10

#define REQ_SPIN    1
#define REQ_WIN     2
#define REQ_UPDATE  3

uint16_t binToBCD3(uint16_t binary_val);
uint8_t  random0to6();
uint16_t calcWinnings(uin8_t reel1, uin8_t reel2, uin8_t reel3);

#endif 