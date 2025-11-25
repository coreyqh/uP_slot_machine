// Name: Sadhvi Narayanan
// Email: sanarayanan@g.hmc.edu

module select_toggle(
	input logic clk,
	input logic reset_n,
	output logic [4:0] freq_counter
);

  logic [23:0] counter;
  logic [2:0] freq_counter;
  
  // clock is toggling at 60Hz
  always_ff @(posedge clk, negedge reset_n) begin
    if(reset_n == 0) begin
        counter <= 0;
        freq_counter <= 0;
    end else if (counter == 2000000) begin
        counter <= 0;

		if (freq_counter == 3'd4) begin
			freq_counter <= 0;
		end else begin
			freq_counter <= freq_counter + 1;  // increments the ouput to create 60Hz frequency
		end
   end else begin
       counter <= counter + 1;
   end
  end
    
 
endmodule
