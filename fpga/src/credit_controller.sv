// E155, Lab 2 - Code to display two numbers on a time-multiplexed dual segment display

// Name: Sadhvi Narayanan
// Email: sanarayanan@g.hmc.edu
// Date: 09/03/2025


module credit_controller(
	input logic clk,
    input logic reset_n,
    input logic [3:0] won_amt1,
    input logic [3:0] won_amt2,
	input logic [3:0] credit_amt1,
	input logic [3:0] credit_amt2,
	input logic [3:0] credit_amt3,
    output logic [4:0] enable_sel,
    output logic [6:0] seg
);


  logic int_osc;
  logic [23:0] counter;
  logic clk_signal;
  logic [3:0] s;
  logic [2:0] freq_counter;
 
  // toggles the clock at 60Hz - frequency where humans cannot see flickers 
  select_toggle select_toggle_controller(clk, reset_n, freq_counter);
  
  seven_segment seven_segment_decoder2(s, seg);


  always_comb begin
       if (freq_counter == 0) begin
		   // determines which pnp transistor to provide a load to
			enable_sel = 5'b01111; // enable first 7-seg
			s = won_amt1; // chooses first DIP switch
       end else if (freq_counter == 1) begin
		    // determines which pnp transistor to provide a load to
			enable_sel = 5'b10111; // enable first 7-seg
			s = won_amt2; // chooses first DIP switch 
	   end else if (freq_counter == 2) begin
		    // determines which pnp transistor to provide a load to
			enable_sel = 5'b11011; // enable first 7-seg
			s = credit_amt1; // chooses first DIP switch
	   end else if (freq_counter == 3) begin
		    // determines which pnp transistor to provide a load to
			enable_sel = 5'b11101; // enable first 7-seg
			s = credit_amt2; // chooses first DIP switch
	   end else begin
		    // determines which pnp transistor to provide a load to
			enable_sel = 5'b11110; // enable first 7-seg
			s = credit_amt3; // chooses first DIP switch
	   end	
   end
 endmodule
