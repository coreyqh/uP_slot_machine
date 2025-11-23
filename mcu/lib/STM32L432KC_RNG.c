// STM32L432KC_RNG.c
// Source code for True Random Number Generator (TRNG) functions

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
void initRNG(void) {
    // 1. Enable the HSI48 clock (required for the TRNG on this specific chip)
    // The specific register for HSI48 depends on the exact L4 sub-series.
    // For many L4 devices, it's in RCC->CR or RCC->CCIPR. 
    // This example assumes it's available and stable. A full implementation would check the HSI48RDY flag.

    // 2. Enable the clock access to the RNG peripheral (located on the AHB2 bus)
    RCC->AHB2ENR |= RCC_AHB2ENR_RNGEN; 
    
    // 3. Perform the conditional reset sequence required for L4+ series (safe to include for L432KC)
    // Write CONDRST=1 and RNGEN=0
    RNG->CR = RNG_CR_CONDRST;
    // Clear CONDRST bit and set RNGEN=1 to enable the generator
    RNG->CR &= ~RNG_CR_CONDRST;
    RNG->CR |= RNG_CR_RNGEN;
}

/* 
 * Waits for a new true random 32-bit number to be ready and returns it.
 * -- return: a 32-bit true random number (uint32_t)
 */
uint32_t get_random_number(void) {
    // Wait until the Data Ready (DRDY) flag is set in the Status Register (SR)
    // The TRNG generates a number in about 40 periods of its clock (e.g., 48 MHz)
    while(!(RNG->SR & RNG_SR_DRDY)); 

    // Check for errors (Clock error (CEIS) or Seed error (SEIS)) in the status register
    // A robust implementation would handle these flags. 
    // For simplicity, we just check if data is ready.
    if ((RNG->SR & (RNG_SR_CEIS | RNG_SR_SEIS)) != 0) {
        // Handle error (e.g., clear error flags, log error, return an error code)
        RNG->SR &= ~(RNG_SR_CEIS | RNG_SR_SEIS); // Clear error flags
        // You may want to re-initialize or signal a failure
    }

    // Read the generated 32-bit random number from the Data Register (DR)
    return RNG->DR;
}
