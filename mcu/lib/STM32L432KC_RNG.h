// STM32L432KC_RNG.h
// header for True Random Number Generator (TRNG) functions

#ifndef RNG_H
#define RNG_H

#include <stm32l432xx.h>
#include "STM32L432KC.h"
#include "STM32L432KC_RNG.h"
#include "STM32L432KC_RCC.h"


/* 
 * Enables the RNG peripheral and its clock.
 * The RNG uses an internal analog source and does not require GPIO configuration.
 * Note: The L4 series RNG is typically clocked by the HSI48 clock, 
 * which needs to be enabled and configured if not already part of your system_init.
 * Refer to the STM32L432KC reference manual for low-level clock configuration details.
 */ 
void initRNG(void);

/* 
 * Waits for a new true random 32-bit number to be ready and returns it.
 * -- return: a 32-bit true random number (uint32_t)
 */
uint32_t get_random_number(void);

#endif