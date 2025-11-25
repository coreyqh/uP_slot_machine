
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
// Include the device header
#include "main.h"
#include <stm32l432xx.h>
#include "C:\Users\chickson\workspace\uP_slot_machine\mcu\lib\STM32L432KC.h"

uint8_t update_pending = 0;
uint8_t credit_count   = 10; // FIXME: 10 for debug
uint8_t button_push    = 0;
uint8_t  done = 0;

int main(void) {
  // Initialization code
  gpioEnable(GPIO_PORT_A);
  gpioEnable(GPIO_PORT_B);

  pinMode(BUTTON_PIN, GPIO_INPUT);
  pinMode(COIN_PIN,   GPIO_INPUT);
  pinMode(DONE_PIN,   GPIO_INPUT);

  initSPI(BR, CPOL, CPHA);


  // 1. Enable SYSCFG clock domain in RCC
  RCC->APB2ENR |= RCC_APB2ENR_SYSCFGEN;
  // 2. Configure EXTICR for the input button interrupt
  SYSCFG->EXTICR[2] |= _VAL2FLD(SYSCFG_EXTICR3_EXTI10, 0b000); // Select PA10
  SYSCFG->EXTICR[2] |= _VAL2FLD(SYSCFG_EXTICR3_EXTI9,  0b000); // Select PA9
  SYSCFG->EXTICR[2] |= _VAL2FLD(SYSCFG_EXTICR3_EXTI8,  0b000); // Select PA8

  // Enable interrupts globally
  __enable_irq();
  __NVIC_EnableIRQ(EXTI15_10_IRQn);
  __NVIC_EnableIRQ(EXTI9_5_IRQn);


  // 1. Configure mask bits
  EXTI->IMR1 |= (1 << gpioPinOffset(BUTTON_PIN)); // Configure the mask bit for button
  EXTI->IMR1 |= (1 << gpioPinOffset(COIN_PIN));   // Configure the mask bit for coin slot
  EXTI->IMR1 |= (1 << gpioPinOffset(DONE_PIN));   // Configure the mask bit for done signal

  // 2. Rising edge triggers
  EXTI->RTSR1 |=  (1 << gpioPinOffset(BUTTON_PIN));   // Enable rising edge trigger for button
  EXTI->RTSR1 |=  (1 << gpioPinOffset(DONE_PIN));     // Enable rising edge trigger for done
  EXTI->RTSR1 &= ~(1 << gpioPinOffset(COIN_PIN));     // Disable rising edge trigger for coin slot

  // 3. Falling edge triggers
  EXTI->FTSR1 &= ~(1 << gpioPinOffset(BUTTON_PIN));   // Disable falling edge trigger for button
  EXTI->FTSR1 &= ~(1 << gpioPinOffset(DONE_PIN));     // Disable falling edge trigger for button
  EXTI->FTSR1 |=  (1 << gpioPinOffset(COIN_PIN));     // Enable falling edge trigger for coin slot

  // 4. Turn on EXTI interrupt in NVIC_ISER
  NVIC->ISER[0] |= (1 << EXTI9_5_IRQn);           // enable EXTI interrupts for pin 8 an 9
  NVIC->ISER[1] |= (1 << (EXTI15_10_IRQn - 32));  // enable EXTI interrupts for pin 10  

  // Initialize
  initRNG();

  uint16_t winnings     = 0;
  uint16_t credits_BCD  = 0;
  uint16_t winnings_BCD = 0;
  uint8_t  reel1 = 0;
  uint8_t  reel2 = 0;
  uint8_t  reel3 = 0;
  uint8_t  wager = 1;
  uint8_t  spi_data_upper = 0;
  uint8_t  spi_data_lower = 0;

  credit_count = 100;
  while(1) {

    if (update_pending) {
      credits_BCD = binToBCD3(credit_count);
      // 2 most significant digits in bits 15:8
      spi_data_upper = credits_BCD >> 4;
      // least significant digit and update code in bits 7:0
      spi_data_lower = ((credits_BCD << 4) & 0x00FF) | REQ_UPDATE;

      // send update request
      digitalWrite(SPI_CE, PIO_HIGH);
      spiSendReceive(spi_data_upper);
      spiSendReceive(spi_data_lower);
      digitalWrite(SPI_CE, PIO_LOW);

      // clear pending flag
      update_pending = 0;
    }

    if (button_push) {
      if (credit_count >= wager) {
        reel1 = get_random_number() % 7;
        reel2 = get_random_number() % 7;
        reel3 = get_random_number() % 7;

        winnings     = wager * calcWinnings(reel1, reel2, reel3);
        winnings_BCD = binToBCD3((winnings >= 100) ? 99 : winnings); // saturate at 99 for 7-segs

        // sprite indeces for reel 1 and 2 bits 15:8
        spi_data_upper = ((reel1 & 0x000F) << 4) | (reel2 & 0x000F);
        // least significant digit and update code in bits 7:0
        spi_data_lower = ((reel3 & 0x000F) << 4) | REQ_SPIN;

        // send spin request
        digitalWrite(SPI_CE, PIO_HIGH);
        spiSendReceive(spi_data_upper);
        spiSendReceive(spi_data_lower);
        digitalWrite(SPI_CE, PIO_LOW);

        while (!done); // wait for done signal irq from FPGA
        done = 0;


        // most significant digits in bits 11:8
        spi_data_upper = winnings_BCD >> 4;
        // least significant digit and win code in bits 7:0
        spi_data_lower = ((winnings_BCD << 4) & 0x00FF) | REQ_WIN;

        // send win request
        digitalWrite(SPI_CE, PIO_HIGH);
        spiSendReceive(spi_data_upper);
        spiSendReceive(spi_data_lower);
        digitalWrite(SPI_CE, PIO_LOW);

        // trigger credit update for next loop iteration
        credit_count += winnings - wager;
        update_pending = 1;
      }

      button_push = 0;

    }

  }

}

// GPIO PINS 15-10 EXTERNAL INTERRUPT HANDLER FUNCTION
// PURPOSE: SERVICE INTERRUPT ON BUTTON_PIN BY CONFIRMING  
//          THAT AN INTERRUPT WAS TRIGGERED ON THAT PIN, THEN
//          THEN SET BUTTON PRESS FLAG
// SIDE EFFECTS: SETS `button_push` FLAG IN `main()`
//
void EXTI15_10_IRQHandler(void){
      // Check that Quad A was what triggered our interrupt
    if (EXTI->PR1 & (1 << gpioPinOffset(COIN_PIN))){
        // If so, clear the interrupt (NB: Write 1 to reset.)
        EXTI->PR1 |= (1 << gpioPinOffset(COIN_PIN));
        
        credit_count++;
        update_pending = 1;
    } 
}


// GPIO PINS 9-5 EXTERNAL INTERRUPT HANDLER FUNCTION
// PURPOSE: SERVICE INTERRUPT ON COIN_PIN BY CONFIRMING THAT 
//          THAT AN INTERRUPT WAS TRIGGERED ON THAT PIN, THEN
//          INCREMENT THE CREDIT COUNT AND SETS CREDIT UPDATE FLAG
// SIDE EFFECTS: INCREMENTS `credit_count` AND SETS `update_pending`
//               IN `main()`
void EXTI9_5_IRQHandler(void){

    if (EXTI->PR1 & (1 << gpioPinOffset(DONE_PIN))){
        // If so, clear the interrupt (NB: Write 1 to reset.)
        EXTI->PR1 |= (1 << gpioPinOffset(DONE_PIN));
        done = 1;
    } 
      // Check that thr button was what triggered our interrupt
    if (EXTI->PR1 & (1 << gpioPinOffset(BUTTON_PIN))){
        // If so, clear the interrupt (NB: Write 1 to reset.)
        EXTI->PR1 |= (1 << gpioPinOffset(BUTTON_PIN));
        button_push = 1;
    } 
}

/* AI CODE!!! UNTESTED!!! */
uint16_t binToBCD3(uint16_t binary_val) {
    // Define the saturation limit for a 3-digit BCD range (999)
    const uint16_t BCD_LIMIT = 999;
    
    // Saturate the input value
    if (binary_val > BCD_LIMIT) {
        binary_val = BCD_LIMIT;
    }

    uint16_t bcd_result = 0;
    uint16_t temp_val = binary_val;

    // Convert the saturated value to BCD using repeated modulo and division
    
    // Process the units digit (right-most digit)
    // Mask the last 4 bits and place them in the lowest nibble of bcd_result
    bcd_result |= (temp_val % 10);
    temp_val /= 10; // Remove the units digit

    // Process the tens digit (middle digit)
    // Mask the next digit, shift it left by 4 bits, and OR it into bcd_result
    bcd_result |= ((temp_val % 10) << 4);
    temp_val /= 10; // Remove the tens digit

    // Process the hundreds digit (left-most digit)
    // Mask the last digit, shift it left by 8 bits, and OR it into bcd_result
    bcd_result |= ((temp_val % 10) << 8);
    // No need to divide again as we only handle 3 digits

    return bcd_result;
}

uint16_t calcWinnings(uint8_t reel1, uint8_t reel2, uint8_t reel3) {
  return 42; // for debug
  // uint16_t winnings = 0;  
    // // general win scenario
    // if (reel1 == reel2 && reel2 == reel2) {
    //   winnings = winvals[reel1];
    // }

    // // special cases
    
  
}